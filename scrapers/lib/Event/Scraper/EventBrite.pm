package Event::Scraper::EventBrite;

use strict;
use warnings;

use LWP::UserAgent;
use URI;
use URI::QueryParam;
use JSON;
use DateTime::Format::Strptime;
## for venues:
use base 'Event::Scraper::Website::Swindon';
 
my $start_url = 'https://www.eventbrite.co.uk/d/united-kingdom--swindon/all-events/';
# use this page to get event ids
# https://www.eventbrite.co.uk/api/v3/destination/events/?event_ids=203690262057,219332688977,220279149867,81945825169,225918316767,213705989367,197847556367,238296861327,225113389207,217010643677,216998988817,147020172293,236699092357,231432901037,232226083467,183951161877,211852826507,175571397777,225116117367,176311671957&expand=event_sales_status,image,primary_venue,saves,ticket_availability,primary_organizer&page_size=20


my $api_base = 'https://www.eventbriteapi.com/v3';
my $client_secret;
my $oauth_token;
my $ua;
# http://developer.eventbrite.com/docs/auth/, http://www.eventbrite.com/myaccount/apps/

sub get_events {
    my ($self, $config, $keyconf) = @_;

    $client_secret ||= $keyconf->{secret};
    $oauth_token ||= $keyconf->{oauth_token};

  #  https://www.eventbriteapi.com/v3/events/search/?token=MVB5IGEA3EGDWFJONGCG&location.latitude=51.559758&location.longitude=-1.781163&location.within=2mi
# https://www.eventbriteapi.com/v3/events/search/?token=MVB5IGEA3EGDWFJONGCG&venue.city=Swindon&venue.country=GB

    my $parser = DateTime::Format::Strptime->new(
        pattern => "%FT%T", 
        on_error => 'croak', 
        time_zone => 'Europe/London');

    my $page = 1;
    my $pages = 30;
    my %venues;
    my @events;
    while ($page <= $pages) {
        my $response = $self->get_page($page);
        $pages = $response->{pagination}{page_count};
        my $events_json = $response->{events};
        foreach my $event_j (@$events_json) {
            my $event = {};
            $event->{event_name} = $event_j->{name}{text};
            $event->{event_desc} = $event_j->{description}{html};
            $event->{event_id} = "http://eventbrite/" . $event_j->{id};
            $event->{event_url} = $event_j->{url};
            my $start = $parser->parse_datetime($event_j->{start}{local});
            my $end = $parser->parse_datetime($event_j->{end}{local});
            $event->{times} = [ { start => $start, end => $end } ];

            print STDERR "Looking for venue: ", $event_j->{venue_id}, "\n";
            if(!$venues{$event_j->{venue_id}}) {
                $venues{$event_j->{venue_id}} = $self->get_venue($event_j->{venue_id});
            }
            $event_j->{venue} = $venues{$event_j->{venue_id}};
            print STDERR "Looking for venue: ", Data::Dumper::Dumper($event_j->{venue}), "\n";
            my $venue = __PACKAGE__->find_venue($event_j->{venue}{name}) ||
                __PACKAGE__->find_venue($event_j->{venue}{address}{address_1});
            if(!$venue) {
                $venue = {
                    name => $event_j->{venue}{name},
                    street => $event_j->{venue}{address}{address_1},
                    city => $event_j->{venue}{address}{city},
                    zip => $event_j->{venue}{address}{postal_code},
                    country => 'United Kingdom',
                    latitude => $event_j->{venue}{latitude},
                    longitude => $event_j->{venue}{longitude},
                };
            }
            $event->{venue} = $venue;
            $event->{category} = $event_j->{category}{name};
            $event->{image_url} = $event_j->{logo}{url};

            push @events, $event;
            $page++;
        }
    }

    return \@events;
}

# search API deprecated in Dec 2019 - use venue API instead!? (grr)
# venues only "by organisation", for which we dont have the ids..?
# guess we scrape the user ui instead :(
sub get_page {
    my ($self, $page) = @_;
    $page ||= 1;

    my $uri = $self->_build_uri('events/search', 
                                { 
                                    'location.latitude' => '51.559758',
                                    'location.longitude' => '-1.781163',
                                    'location.within' => '5mi',
                                    'page' => $page,
                                });
    my $res = $ua->get($uri);
    return {} if(!$res->is_success);

    return decode_json($res->decoded_content);
}

sub get_venue {
    my ($self, $vid) = @_;

    my $uri = $self->_build_uri("venues/$vid");
    my $res = $ua->get($uri->as_string);
    
    return {} if(!$res->is_success);

    return decode_json($res->decoded_content);
}

sub _build_uri {
    my ($self, $path, $args) = @_;
    $args ||= {};

    $ua ||= LWP::UserAgent->new();
    $ua->default_header( 'Authorization' => "Bearer $oauth_token");

    my $uri = URI->new("$api_base/$path/");
    $uri->query_param($_ => $args->{$_}) for keys %$args;
    return $uri;
}

1;

