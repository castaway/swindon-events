package Event::Scraper::Website::SwindonDance;

use strict;
use warnings;

use base 'Event::Scraper::Website::Swindon';

## Would use this, but it only has name/description as microdata, not times!
# use HTML::Microdata;

use HTML::TreeBuilder;
use LWP::Simple;
use Time::ParseDate 'parsedate';
use DateTime;

sub get_events {
    my ($self, $source) = @_;

    my $content = get($source->{uri});
    my $tree = HTML::TreeBuilder->new_from_content($content);

    my @event_divs = $tree->look_down(_tag => 'div',
                                      class => qr/type-tribe_events/);
    my @events;

    foreach my $e_div (@event_divs) {
        my $img = $e_div->look_down(class => 'grid-image')->look_down(_tag => 'img');
        my $img_link = $img ? $img->attr('src') : '';
        my $act_link = $e_div->look_down(class => 'tribe-events-list-event-title');
        my $event_link = $act_link->look_down(_tag => 'a')->attr('href');
        my $act_name = $act_link->as_text;
#        my $title = $act_link->right->look_down(_tag => 'strong');
#        $title = $title ? $title->as_text : '';
        my $date_str = $e_div->look_down(class => 'tribe-event-schedule-details')->as_text;
        #   20 - 4 Aug, 2022 11:00 - 20:00
        #   3 - 4 Sep, 2022 10:30 - 19:00
        #   16 Sep, 2022 16:30 - 18:00
        my ($start_day, $end_day, $month, $year, $start_time, $end_time) =
            $date_str =~ /\s*(\d{1,2})(?:\s*-\s*(\d{1,2}))\s*(\w+),\s*(\d{4})\s*(\d{1,2}:\d{1,2})\s*-\s*(\d{1,2}:\d{1,2})\s*/;
        if (!$start_day) {
            warn "Can't parse date for event: $date_str\n";
            next;
        }
        my $start_str = "$start_day $month $year $start_time";
        my $end_str = "$end_day $month $year $end_time";       
        my $start_epoch = parsedate($start_str);
        my $end_epoch = parsedate($end_str);
        if ($end_epoch < $start_epoch) {
            warn "End date before start date? $date_str\n";
            next;
        }
        my $start = DateTime->from_epoch(epoch => $start_epoch,
                                         time_zone => 'Europe/London');
        my $end = DateTime->from_epoch(epoch => $end_epoch,
                                         time_zone => 'Europe/London');
        my @times = ();
        while($start->day <= $end->day) {
            my $this_end = $start->clone;
            $this_end->set_hour($end->hour);
            $this_end->set_minute($end->minute);
            push @times, {
                start => $start->clone,
                end => $end,
            };
            $start->add(days => 1);
        }
        my $d_start = $e_div->look_down(class => qr/tribe-events-list-event-description/);
        my $desc = join(' ', map { $_->as_HTML} ($d_start->content_list));
        my $venue_name = $e_div->look_down('class' => qr/author\s+location/)->look_down(_tag => 'h4')->as_text;
#        print STDERR "venue name $venue_name\n";

        my %event;
#        $event{event_name} = "$act_name - $title";
        $event{event_name} = "$act_name";
        $event{event_id} = $event{event_url} = $event_link;
        $event{image_url} = $img_link;
#        $event{times} = [{start => DateTime->from_epoch(epoch => $start_epoch,
        #                             time_zone => 'Europe/London') }];
        $event{times} = \@times;
        $event{event_desc} = $desc;
        $event{venue} = __PACKAGE__->find_venue($venue_name);
        
        print STDERR Data::Dumper::Dumper(\%event);
        push @events, \%event;
    }
    return \@events;
}

1;
