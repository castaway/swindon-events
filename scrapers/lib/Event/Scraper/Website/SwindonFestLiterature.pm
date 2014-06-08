package Event::Scraper::Website::SwindonFestLiterature;

use strictures 1;

#BEGIN {
#	 push @INC, sub {
#	my ($self, $filename) = @_;
#	my $mod = $filename =~ s!.pm$!!r;
#	$mod =~ s!/!::!g;
#	system('cpanm', '-S', $mod);
#	 };
#}

use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';

$|=1;

binmode(STDERR, ':utf8');
binmode(STDOUT, ':utf8');

sub get_events {
	my ($self, $source_info) = @_;

    ## From base class
	state $known_venues = __PACKAGE__->venues();

	## Just look at all of May until we find em:
	my $page_date = DateTime->now()->set(month => 5, day => 1);
	my $url_part = sprintf("%02d-%s", $page_date->day, lc($page_date->day_abbr));
	my $page_url = "http://www.swindonfestivalofliterature.co.uk/${url_part}.html";

	my $end_date = DateTime->new(year => $page_date->year,
                                 month => 6,
                                 day => 1)->subtract(days => 1);
    my @events;
	while($page_date <= $end_date) {
        print "Fetching $page_url\n";
		my $html = get($page_url);

        if ($html) {
            my $tree = HTML::TreeBuilder->new_from_content($html);
            ## JMM magic goes here!

            print "WHOLE PAGE TREE\n";
#		$tree->dump;
            
            for my $h2 ($tree->look_down(_tag => 'h2', sub {$_[0]->look_up(class => 'event')})) {
#                print "h2 dump\n";
#                $h2->dump;

                my $info_para = $h2->right;

                my $e = {};
                $e->{event_name} = $h2->as_text;
                my $id = $h2->look_up(id => qr/./)->attr('id');
                $e->{event_url} = $page_url . '#' . $id;
                $e->{event_id} = $e->{event_url};
                use utf8;
                my $date_str = $info_para->address('.4');
#                my ($time, $date, $price) = split / • /, $info_para->address('.4');

                # 10am – 4pm 11 May £5 adult • £4 child
                my ($hour, $minute, $ampm, $end_hour, $end_min, $end_ampm, $day, $month, $price) = 
                    $date_str =~ m/(\d+)\.?(\d+)?(am|pm)     # start time
                              (?:\D+?(\d+)\.?(\d+)?(am|pm))? # - optional end time
                              \D+?(\d+)\s([A-Z]+)                # date month
                              (.*)                           # prices
                              /xi
                    or die "Can't parse time-of-day '$date_str'";
#                my ($hour, $minute, $ampm, $end_hour, $end_min, $end_ampm) = $time =~ m/(\d+)\.?(\d+)?(am|pm)(?:\D+(\d+)\.?(\d+)?(am|pm))?/i
#                    or die "Can't parse time-of-day '$time'";
                $minute //= 0;
                $end_min //= 0;
                if (lc $ampm eq 'pm' && $hour < 12) {
                    $hour += 12;
                }
                if ($end_ampm && lc $end_ampm eq 'pm' && $end_hour < 12) {
                    $end_hour += 12;
                }
                # '5 May'
#                my ($day, $month) = $date =~ m/(\d+) ([A-Z]+)/i or die "Can't parse date '$date'";
                die "Huh date: $date_str" if $month ne 'May';
                                
                $e->{start_time} = DateTime->new(year => 2014,
                                                 month => 5,
                                                 day => $day,
                                                 hour => $hour,
                                                 minute => $minute,
                                                 second => 0,
                                                 time_zone => 'Europe/London',
                                                 locale => 'en_GB',
                    );
                $e->{tz_hint} = 'Europe/London';
                if($end_hour) {
                    $e->{end_time} = DateTime->new(year => 2014,
                                                   month => 5,
                                                   day => $day,
                                                   hour => $end_hour,
                                                   minute => $end_min,
                                                   second => 0,
                                                   time_zone => 'Europe/London',
                                                   locale => 'en_GB',
                    );
                }                    
                my $venue = $info_para->address('.0');
                
                my ($venue_name) = split(/,/, $venue);

                if (!$known_venues->{$venue_name} && !__PACKAGE__->find_venue($venue_name)) {
                    die "Don't know details for venue '$venue_name' (from '$venue')";
                }
                $e->{venue} = $known_venues->{$venue_name} || __PACKAGE__->find_venue($venue_name);

                
#                Dump($e)->Freezer('DateTime', 'iso8601')->Out();

                push @events, $e;
            }
        }

		$page_date->add(days => 1);
		$url_part = sprintf("%02d-%s", $page_date->day, lc($page_date->day_abbr));
		$page_url = "http://www.swindonfestivalofliterature.co.uk/${url_part}.html";
	}

    return \@events;
}

# perl -Ilib -MEvent::Scraper::Website::SwindonFestLiterature -MData::Dumper -le'my $events = Event::Scraper::Website::SwindonFestLiterature->get_events; print Dumper($events)' | less
