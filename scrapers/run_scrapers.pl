#!/usr/bin/perl

use strict;
use warnings;

## 1. Pull in config file with list of sources and data to load
## appropriate plugins
## 2. Read in all plugins
## 3. Loop over list, find appropriate plugin for entry, run plugin, dump data
## 4. insert events, venues, acts into db. de-dupe on venue/date/time.

use Data::Dumper;
use Config::General;
use Module::Find;
use Try::Tiny;
use GIS::Distance;
use JSON;
use Geo::Coder::OSM;
use Data::GUID;
use LWP::Simple;
use LWP::UserAgent;
use Getopt::Long;
use Cwd;
use lib '/usr/src/events/HTML-Tagset/lib';
#use HTML::Tagset; # v5

use lib 'lib';
use Event::Scraper::Website::Swindon;
use lib '../mobilizon_api/lib';
use Mobilizon::WebAPI::HAL;

## Options:
my $filter = '';
my $debug = 0;
my $dry_run = 0;

GetOptions(
    dry_run    => \$dry_run,
    debug      => \$debug,
    'filter:s' => \$filter,
) or die "Missing command line args";

## Config
my $conf = Config::General->new(getcwd() . "/events.conf");
my %config = $conf->getall();

## Scraper Keys
my $keyconf = { Config::General->new(getcwd() . "/keys.conf")->getall() };

## mobi Keys
my $keys = { Config::General->new("keys.conf")->getall() };
my $guide_base = 'https://swindonguide.org.uk/';
my $webapi_user = $keys->{WebAPI};

# HAL rest api
my $api_client = Mobilizon::WebAPI::HAL->new(
    user => $webapi_user->{user},
    pass => $webapi_user->{pass},
    host => $guide_base,
);

my ($actor, $group, @addresses, @medias, $old_events, $osmcoder);
if(!$dry_run) {
    # import actor:
    $actor = $api_client->find_actor('Facebook Imports');

    # import group
    $group = $api_client->find_group('Imported Events');

    # find known addresses
    @addresses = @{$api_client->get('address', with => 'count')};

    # existing images
    @medias = @{$api_client->get('media', with => 'count')};

    # find existing events
    $old_events = $api_client->get('event', with => 'count');

    ## Coder:
    $osmcoder = Geo::Coder::OSM->new();
    # my $oscodes = retrieve("oscodes.store");
}

## static maps:
#my $map_image_path = $ENV{EVENTS_HOME}. '/app/static/images/maps/';

## Scraper Plugins
setmoduledirs(getcwd() . '/lib');
#my @plugin_list = useall('Event::Scraper');
my @plugin_list = findallmod('Event::Scraper');
if ($filter) {
    @plugin_list = grep {$_ =~ /$filter/i} @plugin_list;
}
my %plugins = map { my $name = $_; $name =~ s{Event::Scraper::}{}; ( $name => $_) } @plugin_list;

for (values %plugins) {
    eval "use $_; 1;" or die "can't load $_: $@"
}

print Dumper \%plugins;

## To calculate "Swindon" events (so we can add more blanket fb groups etc)

my $swindon_centre = $config{Setup}{centre};
my $max_dist       = $config{Setup}{max_dist}; #miles
my $geo_dist       = GIS::Distance->new();

## Run
foreach my $source (@{$config{Source}}) {
    my $plugin = $plugins{$source->{plugin}};
    if(!$plugin) {
        # warn "Can't find plugin named Event::Scraper::$source->{plugin} for source $source->{name}";
        next;
    }

    next if $filter && $source->{plugin} !~ /$filter/i;
    # next if $filter && $source->{name} !~ /$filter/i;

    if($source->{is_oo}) {
        $plugin = $plugin->new();
    }
    my $events = $plugin->get_events($source, $keyconf->{Keys}{ $source->{plugin} });

    my $ecount = 0;
    foreach my $event (@$events) {
        if($debug) {
            print Dumper($event);
        }

        ## Skip past events:
        if($debug) {
            print "Skipping if old: ", $event->{start_time} && $event->{start_time} <= DateTime->now(), "\n";
        }
        next if $event->{start_time} && $event->{start_time} <= DateTime->now();
        
        my $next_venue_id;
        my $venue_data;
        ## This oughta be normalised in the Scrapers!
#        $venue_data = $event->{venue} ||  $source->{Venue};
        $venue_data = $event->{venue_loc} || $event->{venue} ||  $source->{Venue};
        if(!$venue_data && !$event->{is_online}) {
            if($debug) {
                print "Skipping: No venue data found and not online\n";
            }
            next;
        }
        my $venue_name = $venue_data;
        $venue_name = $venue_data->{name} if ref $venue_data;
        next if !$venue_name;

        # normalise name
        $venue_data = Event::Scraper::Website::Swindon->find_venue($venue_name);
        my $addr_str = $venue_data->{name} || $venue_name;
        if(!$addr_str) {
            if($debug) {
                print "Skipping: No Location for this event: $addr_str\n";
            }
            next;
        }

        my ($address) = grep { $_->{description} && ($_->{description} =~ /$addr_str/ || $addr_str =~ /$_->{description}/)} @addresses;
        if(!$dry_run) {
            if(!$address) {
                my $lookup = ref $venue_data
                    ? join(', ', $venue_data->{name}, $venue_data->{street}, $venue_data->{zip}, 'Swindon')
                    : $addr_str;
                if($lookup !~ /Swindon/i) {
                    $lookup .= ', Swindon';
                }
                my $detail = $osmcoder->geocode(
                    location => $lookup
                );
                if(!$detail || $detail->{description}) {
                    warn "No nominatim entry for this address: $lookup\n";
                    next;
                }

                my $dist_from_centre = $geo_dist->distance($swindon_centre->{lat}, $swindon_centre->{lng}, $detail->{lat}, $detail->{lon});
                if($dist_from_centre->miles > $max_dist) {
                    warn "This place $addr_str seems to be outside of Swindon\n";
                    next;
                }

                ##  Did we add this nominatim id already?
                $address = grep { $_->{origin_id} && ($_->{origin_id} eq "nominatim:$detail->{osm_id}") } @addresses;
                if(!$address) {
                    # create from nominatim, cos the ActiveModel doesnt do cascades (hal+jsonapi do tho)
                    my $result = $api_client->post(
                        'address',
                        { address => {
                            geom => join(';', $detail->{lat}, $detail->{lon}),
                            description => $detail->{address}{$detail->{class}},
                            origin_id => 'nominatim:' . $detail->{osm_id},
                            country => $detail->{address}->{country},
                            region => $detail->{address}{state},
                            postal_code => $detail->{address}{postcode},
                            locality => $detail->{address}{town},
                            street => $detail->{address}{road},
                            type => $detail->{class},
                            url => $guide_base . 'address/' . lc(Data::GUID->new->as_string),
                          }}
                    );
                    if($result) {
                        push @addresses, $result->{address};
                        $address = $result->{address};
                    }
                }
            }
        }
        # {
        #   "actor_id": 7618,
        #   "file": "{\"id\": \"34cd3966-d9fe-4cbe-b2d0-03b742d6cda0\", \"url\": \"https://swindonguide.org.uk/media/e4b44eb21ed958e35c5189948892867445353deb0f61ad35d2832321ffed48e2.jpg?name=19-1400x788.jpg\", \"name\": \"19-1400x788.jpg\", \"size\": 75497, \"updated_at\": \"2025-05-25T12:08:23\", \"inserted_at\": \"2025-05-25T11:57:19\", \"content_type\": \"image/jpeg\"}",
        #   "id": 4,
        #   "inserted_at": "2025-05-25 11:57:19",
        #   "metadata": "{\"width\": 1400, \"height\": 788, \"blurhash\": \"MEA7xh1v$iR*SgNuW:sBsCW;J7xFJ8,@Ez\"}",
        #   "updated_at": "2025-05-25 12:08:23"
        # }

        $event->{times} = [ { start => $event->{start_time}, end => undef} ]
            if(!$event->{times} && $event->{start_time});

        if(!$event->{times}[0]{start}) {
            if($debug) {
                print Dumper($event->{times});
                print "No start time for this event $event->{event_name}!\n";
            }
            next;
        }


        my $title = $event->{event_name};
        $title =~ s{\s+$}{};

        my $ticket_url = $event->{event_ticket_url} || $event->{event_url};
        my ($already) = grep { $_->{external_participation_url} eq $ticket_url || $_->{title} eq $title } @$old_events;
        next if $already;

        # fun with content/newlines + html fields:
        my $long_desc = sprintf('<p>%s</p>', $event->{event_desc});
        $long_desc =~ s{\n\n}{</p><p>}g;

        my $ua = LWP::UserAgent->new();
        $ua->agent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 SwindonGuide');
        foreach my $time (@{$event->{times}}) {
            next if $time->{start} <= DateTime->now();
            # image:
            my $pic_id = 0;
            if($event->{event_image}) {
                # slightly ugly, file is a jsonb field:
                my $uri = URI->new($event->{event_image}{url});
                my $img_name = ($uri->path_segments)[-1];
                my ($has_media) = grep { $_->{file} =~ /$img_name/ } @medias;
                if(!$has_media) {
                    my $filename = lc(Data::GUID->new->as_hex);
                    my ($ext) = $event->{event_image}{url} =~ /(\.[\w]+)$/;
                    $filename =~ s/^0x//;
                    my $url_filename = $filename . $ext;
                    $filename = $keys->{Config}{uploads_path} . $filename . $ext;
                    # try/catch? (this doesnt seem to have a fail mode?!)
                    #getstore($event->{event_image}{url}, $filename);
                    $ua->get($event->{event_image}{url}, ':content_file' => $filename);
                    if(!-e $filename) {
                        print "Skipping image: Can't store image file at $filename\n";
                        next;
                    }

                    if(!$dry_run) {
                        my $image_uuid = lc(Data::GUID->new->as_string);
                        my $media_vars = {
                            actor_id => $actor->{id},
                            file => encode_json(
                                {
                                    id => $image_uuid,
                                    url => 'https://swindonguide.org.uk/media/' . $url_filename,
                                    size => $event->{event_image}{size},
                                    content_type => $event->{event_image}{type},
                                }),
                            metadata => encode_json(
                                {
                                    width => $event->{event_image}{width},
                                    height => $event->{event_image}{height},
                                }),
                        };
                        my $result = $api_client->post('media', { media => $media_vars});
                        if($result) {
                            $result->{media}= $result->{media}->[0] if ref $result->{media} eq 'ARRAY';
                            $pic_id = $result->{media}{id};
                        }
                    }
                } else {
                    $pic_id = $has_media->{id};
                }
            } else {
                if($debug) {
                    print "Missing event_image URL?\n";
                }
            }
            my $uuid = lc(Data::GUID->new->as_string);
            my $options = {
                show_end_time => $time->{end} ? $JSON::true : $JSON::false,
                is_online => $event->{is_online} ? $JSON::true : $JSON::false,
                maximum_attendee_capacity => 0,
                anonymous_participation => $JSON::true,
            };
            my $event_vars = {
                title => $title,
                description => $long_desc,
                begins_on => $time->{start}->iso8601,
                ends_on => ($time->{end} ? $time->{end}->iso8601 : undef),
                status => lc($event->{status} || 'confirmed'),
                visibility => lc($event->{visibility} || 'public'),
                join_options => 'free',
                uuid => $uuid,
                picture_id => $pic_id ? $pic_id : undef,
                url => $guide_base . 'events/' . $uuid,
                online_address => $event->{event_url},
            ( $event->{event_ticket_url} ? (
                  external_participation_url => $ticket_url
              ) : ()),
                participant_stats => '{"creator": 1, "rejected": 0, "moderator": 0, "participant": 0, "not_approved": 0, "administrator": 0, "not_confirmed": 0}',
                # No m2m rel because no PK in eventstag
                # tags => ['facebook','import'],
                organizer_actor_id => $actor->{id},
            ( $address ? ( physical_address_id => $address->{id} ) : ()),
                attributed_to_id => $group->{id},
                # max cap 0 = no max cap?
                # json
                options => encode_json($options),
            # ( $event->{is_online} ? (options => '{"maximum_attendee_capacity":0,"anonymous_participation":true,"is_online":true}')
            #   : (options => '{"maximum_attendee_capacity":0,"anonymous_participation":true}')),
                # picture_id !?
            };
            # options: show_end_time: false (if no end time)

            if($debug) {
                print "Creating event.. \n";
                print Dumper($event_vars);
            }
            if(!$dry_run) {
                my $result = $api_client->post('/event', { event => $event_vars});
            }
            $ecount++;
        }
    }

    if(!$ecount) {
        warn "No future events to put in DB for: " . Dumper($source);
    }
    # print Dumper($events);
}

