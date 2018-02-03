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

# Client secret 	 4JFMGGNXK7IQQBZFI66A6PBFTV63GZ74MVITKW6Z2VV55SWZHB 
# Your personal OAuth token 	 GMUOPLGTS4TAG3IFOHIC 
# Anonymous access OAuth token 	 MVB5IGEA3EGDWFJONGCG 
 
my $api_base = 'https://www.eventbriteapi.com/v3';
my $client_secret;
my $oauth_token;
my $ua;
# http://developer.eventbrite.com/docs/auth/, http://www.eventbrite.com/myaccount/apps/

sub get_events {
    my ($self, $config) = @_;

    $client_secret ||= $config->{secret};
    $oauth_token ||= $config->{oauth_token};

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

