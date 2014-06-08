package Event::Scraper::Website::SwindonBC;
use strictures 1;
use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';

$|=1;

# perl -Ilib -MEvent::Scraper::Website::SwindonBC -MData::Dumper -le'my $events = Event::Scraper::Website::SwindonBC->get_events; print Dumper($events)' | less


## Sharepoint! internal / next page links are all javascript, bah!
# daily event page links:3rd:  www.swindon.gov.uk/events/Pages/eventslisting.aspx?d=635347584000000000
# 1st: 635344992000000000 = datetime "ticks" (nanoseconds), convert to epoch: ticks of 1 jan 1970= 621355968000000000

my $ua = LWP::UserAgent->new();

sub get_events {
    my ($self, $source_info) = @_;

    my $events_by_id = {};
    
    my @ret;

    my $days = 1;
    my $pagedate = DateTime->now()->subtract(days => 1);
    $pagedate->set(hour => 0, minute => 0, second => 0, nanosecond => 0);
    my $csharp_time = dt_to_csharp($pagedate);
    my $page_url = "http://www.swindon.gov.uk/events/Pages/eventslisting.aspx?d=$csharp_time";
    while (1) {
        my $html = get($page_url);
        my $tree = HTML::TreeBuilder->new_from_content($html);
#        $tree->dump;

        for my $event_top ($tree->look_down(class => qr/\bEventsListingItem\b/)) {
#            $event_top->dump;
            my $a = $event_top->look_down(_tag => 'a');
            my $sub_url = URI->new_abs($a->attr('href'), $page_url);
#            print "Event: $sub_url\n";
            if (exists $events_by_id->{$sub_url}) {
                print "Skipping, already exists\n";
                next;
            }
            elucidate($sub_url, $events_by_id, $pagedate);

            sleep 1;

#            last;
        }

        my $pagedate = $pagedate->add(days => 1);
        $csharp_time = dt_to_csharp($pagedate);
        $page_url = "http://www.swindon.gov.uk/events/Pages/eventslisting.aspx?d=$csharp_time";
#        print "Next page: $pagedate - $page_url\n";
        ## next 2 months days:
        last if $days++ >= 60;
    }

    return [ values %$events_by_id ];
}

sub dt_to_csharp {
    my ($dt) = @_;

    state $csharp_unix_epoch = 621355968000000000;
    return ($dt->epoch * 10000000) + $csharp_unix_epoch;
}

sub elucidate {
    my ($url, $events, $pagedate) = @_;

    my $known_venues = __PACKAGE__->venues();
    state $formatter = DateTime::Format::Strptime->new(pattern => "%A %d %B %Y");

    my $resp = $ua->get($url);
    my $tree;
    if($resp->is_success) {
        $tree = HTML::TreeBuilder->new_from_content($resp->content);
    } else {
        print "Failed to fetch $url, ", $resp->status_line, "\n";
	return;
    }
#    my $html = get($url) or die "Can't load HTML from $url";
#    my $tree = HTML::TreeBuilder->new_from_content($html);
    $tree = $tree->look_down('class' => qr/\bEventsListingView\b/) || die "Can't find EventsListingView", $tree->dump;
#    $tree->dump;
    my $ret;

    ## First span, genre image+text
    $ret->{event_genre} = $tree->look_down(_tag => 'span')->as_text;
    $ret->{event_desc} = join "\n", map {$_->format} $tree->look_down(class => 'sbc-rteElement-sbcP');

    $ret->{event_id} = $url;
    $ret->{event_url} = $url;
    $ret->{event_name} = $tree->look_down(_tag => 'h1')->as_text;
#    print "Name: $ret->{event_name}\n";
    my $venue = $tree->look_down(_tag => 'h3');
    my $venue_name = $venue->as_text;
#    if(!$venue_name) {
#        $venue_name = '<unknown>';
#    }
    my ($meeting) = $ret->{event_desc} =~/^\s*Meet at (.*)$/m;
#    print "Meeting: $meeting\n" if $meeting;
    $ret->{venue} = $known_venues->{$venue_name} || __PACKAGE__->find_venue($venue_name, $ret->{event_name}, $meeting);
    if (!$ret->{venue}) {
        $ret->{venue} = $known_venues->{'<unknown>'};
        warn "Don't know info for SBC venue '$venue_name'";
    }

    ## Date of page we were on in case the ubpage doesn't have a specific one
    ## Overall start and end dates of entire run
    my $start_text = $tree->look_down(_tag => 'h2')->as_text;
    my @dates = split (/\s?-\s?/, $start_text);
    my ($start, $end) = map { $formatter->parse_datetime($_) } @dates;
    $end ||= '';
#    print "Start: $start, End: $end\n";
    my @times;

    ## Actual times, possible days, sometimes neither
    # Time is the first tag after venue that has text of \d ?[ap]m (IE 3pm, 3:00am)
    my $time = $venue->right;
    until ($time->as_text =~ m/\d ?[ap]m/i) {
        $time = $time->right;
        if (!$time) {
            print "Fell off end looking for time\n";
            last;
        }
    }
    if ($time) {
        $time = $time->as_text;
#        print "Time: $time\n";
        @times = get_times($start, $end, $time);
    } else {
	# FIXME: Why are these two cases so different?  Why isn't an
	# event that happens once just an event, that happens, one
	# time.
	@times = {start => $start, end => undef};
    }
    ## cheating a bit?
    #$ret->{start_time} = @times ? $times[0]{start} : $pagedate;
#    Dump(\@times)->Freezer('DateTime' => sub {shift.""})->Out;
    $ret->{times} = \@times if @times;

    Dump($ret);
    $events->{$url} = $ret;
    return $ret;
}

sub get_times {
    my ($start, $end, $time) = @_;

    #          Fortnightly Saturdays, 10.00am - 4.00pm
    #          Wednesday - Saturday 11.00am-3.00pm
    #          1pm-3pm
    #          2pm
#    print "get_times: \n";
#    print " start: $start\n";
    if ($end) {
#        print " end: $end\n";
    } else {
#        print " endless\n";
    }
#    print " time: '$time'\n";

    my ($start_day, $end_day, $start_hour, $start_min, $start_daypart, $end_hour, $end_min, $end_daypart) = 
#        $time =~ /([a-zA-Z]+)?(?:\s?-\s?)?([a-zA-Z]+)?s?,?\s?(\d+)\.?(\d+)?[ap]m(?:\s?-\s?)?(\d+)?\.?(\d+)?(?:[ap]m)?/;
        $time =~ /([a-zA-Z]+)?        # Start day, or possibly "fortnightly"
                  (?:\s?-\s?)?        # day separator
                  ([a-zA-Z]+)?s?      # End day, maybe
                  ,?\s?               # days times separator 
                  (\d+)\.?(\d+)?([ap]m|noon) # Start time
                  (?:\s?-\s?|\sto\s|\D+)? # time separator
                  (?:(\d+)\.?(\d+)?([ap]m|noon))?  # end time
                 /x or die "Regex didn't match for '$time'";
    $start_min ||= 0;
    $end_min ||= 0;

    if (lc $start_daypart eq 'pm' and $start_hour != 12) {
        $start_hour += 12;
    }
    if ($end_hour and lc $end_daypart eq 'pm' and $end_hour != 12) {
        $end_hour += 12;
    }

    ## Only one day, so words should be just times?
    if(!$end) {
	{
	    no warnings 'uninitialized';
	    print "No end defined, so singleton $start_hour:$start_min - $end_hour:$end_min\n";
	}
        $start->set(hour => $start_hour, minute => $start_min);
        if($end_hour) {
            $end = $start->clone;
            $end->set(hour => $end_hour, minute => $end_min);
        }
        return ({ start => $start, end => $end });
    }
    my @times;
    my $loop_date = $start->clone;
    my @all_days = qw/Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday Monday Tuesday Wednesday Thursday Friday Saturday/;
    my @on_days = @all_days;
    if($start_day && $end_day) {
	my $found = 0;
        @on_days = grep { $found = 1 if($_ eq $start_day);
                          my @ds = $found ? ($_) : ();
                          $found = 0 if($_ eq $end_day);
                          @ds;
                              } @all_days;
        }
#    Dump \@on_days;
    while ($loop_date->ymd ne $end->ymd) {
        if(grep { $loop_date->day_name eq $_ } @on_days) {
            my $t_start = $loop_date->clone;
            $t_start->set(hour => $start_hour, minute => $start_min);
            my $t_end = $t_start->clone;
            $t_end->set(hour => $end_hour, minute => $end_min);
            push @times, { start => $t_start, end => $t_end };
        }
        $loop_date = $loop_date->add(days => 1);
    }
    return @times;
}

'Long live Izzy Brunel!';

