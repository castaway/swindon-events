package Event::Scraper::Cineworld;

use strict;
use warnings;
use Data::Dumper;
use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;
use DateTime;

## docs: https://www.cineworld.co.uk/developer/api
my $api_base = 'https://www.cineworld.com/api/quickbook';
my $cineworld_key;

## what fun, we need to get cinema ids, film ids and date ids, to retrieve performances. NB. Dates are just YYYYMMDD

sub get_events {
    my ($self, $config) = @_;

    $cineworld_key ||= $config->{key};
    if (!$cineworld_key) {
        die "No cineworld key!";
    }
    print $self->_build_uri('cinemas', { full => 'true'}), "\n";
    my $ua = LWP::UserAgent->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36 Vivaldi/1.94.1008.44');
    my $response = $ua->get($self->_build_uri('cinemas', { full => 'true'}));
    my $result;
    if($response->is_success) {
        $result = decode_json($response->decoded_content);
    } else {
        print STDERR "Failed to fetch: ", $self->_build_uri('cinemas', { full => 'true'}), " ", $response->status_line, " ", $response->content, "\n";
    }
#    print STDERR get($self->_build_uri('cinemas', { full => 'true'}));
#    my $result = {};
#    return [];
#    my $result = decode_json(get($self->_build_uri('cinemas', { full => 'true'})));
    if ($result->{errors}) {
        warn join "\n", @{$result->{errors}};
        return [];
    }
    
    my @swinemas;
    foreach my $cinema (@{$result->{cinemas}}) {
        push @swinemas, $cinema if $cinema->{name} =~ /swindon/i;
    }

    my @events;
    my $events_by_event_id = {};
    foreach my $cinema (@swinemas) {
        my $films_uri = $self->_build_uri('films', { full => 'true',
                                                     cinema => $cinema->{id} 
                                          });
        print STDERR "Get films: $films_uri\n";
        my $response = $ua->get($films_uri);
        my $result;
        if($response->is_success) {
            $result = decode_json($response->decoded_content);
        } else {
            print STDERR "Failed to fetch: $films_uri ", $response->status_line, " ", $response->content, "\n";
        }
        
#        my $result = decode_json(get($films_uri));

        my $date = DateTime->now(time_zone => 'UTC');
        my $date_end = $date->clone->add(days => 21);
        while ($date < $date_end) {
            foreach my $film (@{$result->{films}}) {
                my $event = {};
                my $event_id = "cineworld://".$film->{edi}."/".$cinema->{name};
                if (!exists $events_by_event_id->{$event_id}) {
                    $events_by_event_id->{$event_id} = {};
                }
                $event = $events_by_event_id->{$event_id};

                $event->{event_id} = $event_id;
                $event->{event_name} = $film->{title};
                $event->{image_url} = $film->{poster_url};
                $event->{event_desc} = '';
                $event->{event_url} = $film->{film_url};
                $event->{updated_time} = DateTime->now();
                my $c_name = $cinema->{name};
                $c_name =~ s/Swindon\s+-\s+//;
                $c_name =~ s/-/ /g;
                $event->{venue} = {
                    name => "Cineworld $c_name",
                    city => 'Swindon',
                    zip  => $cinema->{postcode},
                    street => $cinema->{address} || '',
                    country => 'United Kingdom',
                    url => $cinema->{cinema_url},
                };
                $event->{future_times_delete} = 1;
                
                my $response = $ua->get($self->_build_uri(
                                           'performances',
                                           { cinema => $cinema->{id}+0,
                                             film   => $film->{edi}+0,
                                             date   => $date->ymd('')+0,
                                           }));
                my $perf_content;
                if($response->is_success) {
                    $perf_content = $response->decoded_content;
                } else {
                    print STDERR "Failed to fetch: ", $self->_build_uri(
                                           'performances',
                                           { cinema => $cinema->{id}+0,
                                             film   => $film->{edi}+0,
                                             date   => $date->ymd('')+0,
                                           }), " ", $response->status_line, " ", $response->content, "\n";
                }
                # $perf_content = get($self->_build_uri(
                #                            'performances',
                #                            { cinema => $cinema->{id}+0,
                #                              film   => $film->{edi}+0,
                #                              date   => $date->ymd('')+0,
                #                            }));
                print Dumper $perf_content;
                next if !$perf_content;
                my $result = decode_json($perf_content);
                foreach my $perf (@{ $result->{performances} }) {
                    ## doh, this is per-performance, not event
#                    $event->{event_url} ||= $perf->{booking_url};
                    my ($hour, $minute) = $perf->{time} =~ /(\d+):(\d+)/;
                    my $start = $date->clone;
                    $start->set_hour($hour);
                    $start->set_minute($minute);
                    $start->set_second(0);
                    $start->set_time_zone('Europe/London');
                    push @{ $event->{times} }, { start => $start };
                }
                print Dumper $event;
                push @events, $event if exists $event->{times};
            }
            $date->add(days => 1);
        }
    }

    return \@events;
}

sub _build_uri {
    my ($self, $path, $args) = @_;
    $args ||= {};

    my $uri = URI->new("$api_base/$path");
    $uri->query_param('key' => $cineworld_key);
    $uri->query_param($_ => $args->{$_}) for keys %$args;

    return $uri->as_string;
}

1;
