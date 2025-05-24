package Event::Scraper::MeetUp;

use strict;
use warnings;

use Moo;
use LWP::UserAgent;
use LWP::UserAgent;
use DateTime;
use Data::Dumper;
use JSON;

with 'Event::OAuthHandler';

has service => (is => 'ro', default => sub {  'meetup' });
has ua => ( is => 'ro', default => sub { LWP::UserAgent->new() });

my $api_base = 'https://api.meetup.com';

sub get_events {
    my ($self, $config, $keyconf) = @_;
    my $access_token = $self->authenticate($keyconf);

    return [];
    ## Find local groups (Swindon + 5mi)
    my $groups_str = get("$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&access_token=$access_token&page=50");
#    my $resp = LWP::UserAgent->new()->get("$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&key=$api_key");
#    print $resp->status_line;
#    print $resp->content;
#    my $groups_str = $resp->decoded_content;
#    print "$api_base/find/groups?lat=51.5613683&lon=-1.7856853&radius=5&page=50&format=json&sign=true&access_token=$access_token\n";
    print Dumper($groups_str);
    my $groups = decode_json($groups_str);

    my @events;
    foreach my $group (@$groups) {
        my $events_str = get("$api_base/$group->{urlname}/events");
        print Dumper($events_str);
        if(!$events_str) {
            warn "Meetup returned empty event info!?\n";
            next;
        }
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
# https://gist.github.com/yosun/5729f99f8a4b14598b73bf211938b8cf
# query event {
#   event(id: "276754274") {
#     title
#     description
#     host {
#       email
#       name
#     }
#     dateTime
#   }
# }
  # query($lat: Float,$lon: Float) {
  #   findLocation(lat: $lat,lon: $lon) {
  #     city
  #     name_string 
  #   }
  # }
  
  # {"lat":37.774929,"lon":-122.419418}
# query ($query: String!, $lat: Float!, $lon: Float!, $radius: Int!) {
#   keywordSearch(
#     filter: {query: $query, lat: $lat, lon: $lon, radius: $radius, source: EVENTS, eventType: PHYSICAL}
#   ) {
#     count
#     edges {
#       node {
#         id
#         result {
#           ... on Event {
#             title
#             dateTime
#             eventUrl
#             onlineVenue {
#               type
#               url
#             }
#             venue {
#               id
#               name
#               address
#             }
#           }
#         }
#       }
#     }
#   }
# }


# {
#   "query": "knitting ",
#   "lat": 37.774929,
#   "lon": -122.419418,
#   "radius": 50
# }
sub gsql_query {
    my ($self, $token, @args) = @_;
    # $self->ua->post(
    #     'Content-Type' => 'application/json',
    #     'Authorization' => 'Bearer ' . $token,
    #     'Content' => $query
    #     );
}
