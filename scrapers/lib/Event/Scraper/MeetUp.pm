package Event::Scraper::MeetUp;

use strict;
use warnings;

use LWP::Simple 'get';
use LWP::UserAgent;
use DateTime;
use Data::Dumper;
use JSON;

my $api_base = 'https://api.meetup.com';

sub get_events {
    my ($self, $config) = @_;
    my $api_key = $config->{key};

    ## Find local groups (Swindon + 5mi)
    my $groups_str = get("$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&key=$api_key&page=50");
#    my $resp = LWP::UserAgent->new()->get("$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&key=$api_key");
#    print $resp->status_line;
#    print $resp->content;
#    my $groups_str = $resp->decoded_content;
    print "$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&key=$api_key\n";
    print Dumper($groups_str);
    my $groups = decode_json($groups_str);

    my @events;
    foreach my $group (@$groups) {
        my $events_str = get("$api_base/$group->{urlname}/events");
        my $events = decode_json($events_str);

        foreach my $m_event (@$events) {
            print Dumper($m_event);
            next unless $m_event->{visibility} eq 'public';
            
            my %event = ();
            $event{event_id} = $m_event->{id};
            $event{event_name} = $m_event->{name};
            $event{event_url} = $m_event->{link};
            $event{event_desc} = $m_event->{description};
            $event{updated_time} = DateTime->from_epoch(epoch => $m_event->{updated} / 1000, time_zone => 'Europe/London');
            $event{venue} = {
                name => $m_event->{venue}{name},
                city => $m_event->{venue}{city},
                latitude => $m_event->{venue}{lat},
                longitude => $m_event->{venue}{lon},
                street => $m_event->{venue}{address_1},
                country => 'United Kingdom',
            };
            $event{times} = [{
                start => DateTime->from_epoch(epoch => $m_event->{time} / 1000, time_zone => 'Europe/London')
                             }];

            push @events, \%event;
        }
    }

#    print Dumper(\@events);
    return \@events;
}

