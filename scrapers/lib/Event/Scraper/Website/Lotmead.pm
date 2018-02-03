package Event::Scraper::Website::Lotmead;
# Lotmead Farm - various events
use strict;
use warnings;

use URI;
use LWP::Simple;
use HTML::TreeBuilder;
use DateTime;
use Time::ParseDate;
use Data::Dumper;

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $config) = @_;

    my $top_uri = $config->{uri};
    my $tree = HTML::TreeBuilder->new_from_content(get($top_uri));
    my @event_divs = $tree->look_down('class' => qr/^eventBox/);

    my @events;
    my ($start_time, $end_time) ;
    foreach my $levent (@event_divs) {
        my $img = $levent->look_down('_tag' => 'img');
        my $id = $img->attr('id');
        my $name = $img->attr('alt');
        my $desc = map { $_->as_text } $levent->look_down('_tag' => 'p');
        my $date_str = $levent->look_down('_tag' => 'h4')->as_text;

        if($date_str =~ /Opening 7 days a week from (\d{1,2}\.\d{1,2}am) - (\d{1,2}\.\d{1,2}pm)/) {
            ($start_time, $end_time) = ($1, $2);
            $start_time =~ s{\.}{:};
            $end_time =~ s{\.}{:};
            next;
        }

        my $year;
        my ($day1, $day2, $month) = $date_str =~ /Weekend\s(\d+)-(\d+)\s(\w+)/i;
        if(!$day1) {
            ($day1, $month, $year) = $date_str =~ /(\d+)\s(\w+)\s(\d{4})/;
        }
        $year ||= '';
        
        next if !$day1;

        my $epoch_start = parsedate("$day1 $month $year $start_time", PREFER_FUTURE => 1);
        my $epoch_end = parsedate("$day1 $month $year $end_time", PREFER_FUTURE => 1);
        ## No times posted! Unknown = 00:00
        my $start_date = DateTime->from_epoch (epoch => $epoch_start);
        $start_date->set_time_zone('Europe/London');
        my $end_date = DateTime->from_epoch (epoch => $epoch_start);
        $end_date->set_time_zone('Europe/London');
        my @times = ({ start => $start_date, end => $end_date });
        if($day2) {
            $epoch_start = parsedate("$day2 $month $year $start_time", PREFER_FUTURE => 1);
            $epoch_end = parsedate("$day2 $month $year $end_time", PREFER_FUTURE => 1);
            my $start_date2 = DateTime->from_epoch (epoch => $epoch_start);
            $start_date2->set_time_zone('Europe/London');
            my $end_date2 = DateTime->from_epoch (epoch => $epoch_end);
            $end_date2->set_time_zone('Europe/London');
            push @times, { start => $start_date2, end => $end_date2 };
        }

        my $event;
        $event->{event_id} = "http://www.lotmeadfarm.co.uk/$id";
        $event->{event_url} = $top_uri;
        $event->{event_name} = $name;
        $event->{event_desc} = $desc;
        $event->{times} = \@times;
        $event->{venue} = __PACKAGE__->find_venue('Lotmead Farm');

        push @events, $event;
    }

    return \@events;
}

1;
