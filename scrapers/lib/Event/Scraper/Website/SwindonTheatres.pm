package Event::Scraper::Website::SwindonTheatres;

use strict;
use warnings;

use LWP::Simple 'get';
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use Time::HiRes;
use JSON '-support_by_pp';
use Data::Printer;
use Encode 'decode', 'encode';
use Try::Tiny;

use base 'Event::Scraper::Website::Swindon';

#'https://swindontheatres.co.uk/Online/allevents';
#$top_uri = 'https://swindontheatres.co.uk/Online/june2015';

my $formatter = DateTime::Format::Strptime->new(
    pattern => '%a %d %b %Y - %l.%M %p',
    on_error => 'croak', time_zone => 'Europe/London');
sub get_events {
    my ($self, $source_info) = @_;

    my @ret;

    my $top_uri = $source_info->{uri};
    my $page = get($top_uri);
    p $top_uri;
#    p $page;
    return [] if !$page;
    my ($main_content) = ($page=~m/var articleContext = ({.*?});/s);
    $main_content = encode('utf8', $main_content);
    my $json_parser = JSON->new->allow_barekey;
    $json_parser->loose(1);

    ## This chunk of JSON doesn't contain an entry for every instance of every event
    ## in fact I think its just one per event, to get the date range, so we need to
    ## visit each page to get all the entries.
    $main_content = $json_parser->decode($main_content);
    my @sub_pages = map { URI->new_abs($_->[14], $top_uri)} @{ $main_content->{searchResults} };

    foreach my $page_uri (@sub_pages) {
        my $s_time = time();
        my $page = get($page_uri);
        p $page_uri;
#        p $page;
        next if !$page;
        $s_time = time() - $s_time;
        my ($article_content) = ($page=~m/var articleContext = ({.*?});/s);
        $article_content = encode('utf8', $article_content);
        try {
            $article_content = $json_parser->decode($article_content);
        } catch {
            warn "Can't parse JSON: $article_content\n";
            next;
        };

        my $results = [];
        for my $result (@{$article_content->{searchResults}}) {
            my $result_hr = {};
            for my $i (0..@$result-1) {
                next if !$result->[$i];
                $result_hr->{$article_content->{searchNames}[$i]} = $result->[$i];
            }

            ## Results contains one row for each actual event, so snow white over several days will have several entries, one for each date/performance - ids are different
            ## article_ids (urls in additional_info) aren't though!
            ## we want to collect the set, so.. use the url for the id

            ## series_data4          "Sat 5 December - Sun 3 January",
            ## start_date            \"Sat 2 Jan 2016 - 1.00 PM\",
            ## series_data4          \"Sat 5 December - Sun 3 January\",
            ## start_date            \"Tue 15 Dec 2015 - 10.30 AM\",
            ## series_data4          \"Sat 5 December - Sun 3 January\",
            ## start_date            \"Sun 3 Jan 2016 - 5.00 PM\",

            ## We only have one example of an end_date:
            ## end_date              \"until 7.30 PM\",

            ## start_date Friday 21 Aug 2015 at 6:30pm

            $result_hr->{start_date} =~ s{ at }{ - };
            $result_hr->{start_date} =~ s{(\d{1,2}):(\d{1,2})([ap]m)}{$1.$2 $3}i;

#      p $result_hr;

            my $start = $formatter->parse_datetime($result_hr->{start_date});
            my $link = URI->new_abs($result_hr->{additional_info}, $top_uri);

            my ($existing_event) = grep { $_->{event_id} eq $result_hr->{additional_info} }
            @ret;

            my $event = $existing_event || {};
#            $event->{event_id} ||= $result_hr->{additional_info};
            $event->{event_id} ||= 'SwindonTheatres://' . $result_hr->{id};
            $event->{event_name} ||= $result_hr->{short_description} || $result_hr->{description};
#            $DB::single=1 if($event->{event_name} eq 'Mercury');
            $event->{image_url} ||= $result_hr->{image1};
            $event->{event_url} ||= $link;
            $event->{venue} ||= $self->find_venue($result_hr->{venue_description});
            if(!$event->{venue}) {
                warn "Can't find venue for $result_hr->{venue_description}\n";
                $DB::single=1;
            }
            $event->{prices} ||= [$result_hr->{min_price}, $result_hr->{max_price}];
            if(! grep { $start->iso8601() eq $_->{start}->iso8601 } @{ $event->{times} }) {
                push @{ $event->{times} }, { start => $start, end => undef };
            }

#            p $event;
            push @$results, $result_hr;
            push @ret, $event if (!$existing_event);
        }

        sleep $s_time;
    }
#    p $results;
#    p @ret;

    ## start date, start time, end date, end time,
    ## event name
    ## event location (venue inc. address?)
    ## event id
    ## event link
    ## event long desc

    return \@ret;
}

__END__

    my $tree = HTML::TreeBuilder->new_from_content($page) or die;
    $tree->dump;

    my $search_results = $tree
        ->look_down(id => 'search_results');
    my @event_rows = $search_results->look_down('_tag' => 'tr');

    my @events;
    foreach my $e_row (@event_rows) {
        my $event = {};
        my $date_str = $e_row->look_down(class => 'date-list')->as_text;
        my $link = $e_row->look_down(class => 'info-link')->look_down('_tag' => 'a');
        my $name = $e_row->look_down(class => 'performance-short-description')->as_text;
        my $desc = $e_row->look_down(class => 'performance-description')->look_down('_tag' => 'a')->as_text;
        my $image_uri = $e_row->look_down(class => 'performance-image')->look_down('_tag' => 'img')->attr('src');
        $image_uri = URI->new_abs($image_uri, $top_uri);
        my $uri = $link->attr('href');
        $uri = URI->new_abs($uri, $top_uri);
        my $loc = $e_row->look_down('class' => 'performance-location')->as_text;
        my $dates = $e_row->look_down('class' => 'date-list')->as_text;
        
        $event->{event_name} = $name;
        $event->{event_desc} = $desc;
        $event->{event_id} = $event->{event_url} = $uri;
        $event->{image_url} = $image_uri;
        $event->{venue} = $self->find_venue($loc);
        $event->{times} = $self->get_dates($dates, $uri);

        push @events, $event;
        sleep 1;
    }

    return @events;
}

sub get_dates {
    my ($self, $date_str, $sub_page) = @_;

    my @times;
    my $page = get($sub_page);
    my $tree = HTML::TreeBuilder->new_from_content($page);
    for my $showing ($tree->look_down(id => 'search_results')
                     ->look_down('_tag' => 'tbody')
                     ->look_down('_tag' => 'tr')) {
        my $time_str = $showing->looK_down(class => 'performance-date')->as_string;
        push @times, parsedate($time_str,
                               UK => 1, zone => 'Europe/London');
        print "$time_str: $times[-1]\n";
    }



=for comment

this doesn't actually give full detail, the list at the bottom of the sub-page
does, so use that.


    my $year = DateTime->now->year;

    if(my ($start_date, $start_mo, $end_date, $end_mo) = $date_str 
       =~ /^\w+\s+(\d)+(?:\s+(\w+))?\s-\s\w+\s(\d+)\s+(\w+)$/) {
        my $start = $formatter->parse_date(sprintf("%d %s %d",
                                                   $start_date,
                                                   $start_mo || $end_mo,
                                                   $year));
        my $end = $formatter->parse_date(sprintf("%d %s %d",
                                                 $end_date,
                                                 $end_mo,
                                                 $year));

        my @times;
        while($start <= $end) {
            push @times, { start => $start };
            $start->add(days => 1);
        }
    }

=cut

    return @times;
}

1;
