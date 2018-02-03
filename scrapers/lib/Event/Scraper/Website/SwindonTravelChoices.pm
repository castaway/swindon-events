package Event::Scraper::Website::SwindonTravelChoices;

use strict;
use warnings;

use LWP::Simple;
use Data::ICal;
use Data::Dumper;
use DateTime::Format::Strptime;
use DateTime;

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $config) = @_;

    my $ical = Data::ICal->new(data => get($config->{uri}));
    my $event_objs = $ical->entries;

    my @events;
    my $dtptime = DateTime::Format::Strptime->new(pattern => '%Y%m%dT%H%M%S',
        time_zone => 'Europe/London');
    my $dtpday = DateTime::Format::Strptime->new(pattern => '%Y%m%d',
        time_zone => 'Europe/London');
    foreach my $e_row (@$event_objs) {
        my %event;
#        print STDERR Data::Dumper::Dumper($e_row->properties);
        my $id = $e_row->property('uid');
        my $url = $e_row->property('url');
        my $name = $e_row->property('summary');
        my $desc = $e_row->property('description');
        my $loc = $e_row->property('location');
        my $dtstart = $e_row->property('dtstart');
        my $dtend = $e_row->property('dtend');

        $dtstart = $dtstart->[0]->value;
        $dtstart =~ s/Z$//;
        $dtend = $dtend->[0]->value;
        $dtend =~ s/Z//;
        $event{event_id} = $id->[0]->value;
        $event{event_url} = $url->[0]->value;
        $event{event_name} = $name->[0]->value;
        $event{event_desc} = $desc->[0]->value;
        $event{venue}{zip} = $loc && $loc->[0]->value;
        my ($start,$end) = map { $dtptime->parse_datetime($_) } ($dtstart,$dtend);
        my $all_day = 0;
        if(!$start && !$end) {
            # maybe no times?
            ($start,$end) = map { $dtpday->parse_datetime($_) } ($dtstart,$dtend);
            if($start == $end) {
                $end = undef;
                $all_day = 1;
            }
        }
        $event{times}[0] = {
            start => $start,
            end => $end,
            all_day => $all_day,
        };
        

        push @events, \%event;
    }

#    print STDERR Data::Dumper::Dumper(\@events);
#    return [];
    return \@events;
}

1;
