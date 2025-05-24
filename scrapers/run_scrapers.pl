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
#use Geo::Coder::Mapquest;
use Geo::Coder::OSM;
# use Geo::UK::Postcode::Regex;
use Data::GUID;
#use Storable 'retrieve';
use lib '/usr/src/events/HTML-Tagset/lib';
#use HTML::Tagset; # v5

use lib '/usr/src/events/scrapers/lib';
use Event::Scraper::Website::Swindon;

use lib 'lib';
use Mobilizon::WebAPI::HAL;

## Provide a param to use only matching sources:
my $filter = shift;

## Config
my $conf = Config::General->new("/usr/src/events/scrapers/events.conf");
my %config = $conf->getall();

## Scraper Keys
my $keyconf = { Config::General->new("/usr/src/events/scrapers/keys.conf")->getall() };

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

# import actor:
my $actor = $api_client->find_actor('Facebook Imports');

# import group
my $group = $api_client->find_group('Imported Events');

# find known addresses
my @addresses = @{$api_client->get('address', with => 'count')};

# find existing events
my $old_events = $api_client->get('event', with => 'count');

## Coder:
my $osmcoder = Geo::Coder::OSM->new();
# my $oscodes = retrieve("oscodes.store");

## static maps:
#my $map_image_path = $ENV{EVENTS_HOME}. '/app/static/images/maps/';

## Plugins
setmoduledirs('/usr/src/events/scrapers/lib');
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
my $geo_dist       =  GIS::Distance->new();

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
        # print Dumper($event);

        ## Skip past events:
        next if $event->{start_time} && $event->{start_time} <= DateTime->now();
        
        my $next_venue_id;
        my $venue_data;
        ## This oughta be normalised in the Scrapers!
#        $venue_data = $event->{venue} ||  $source->{Venue};
        $venue_data = $event->{venue_loc} || $event->{venue} ||  $source->{Venue};
        if(!$venue_data && !$event->{is_online}) {
            next;
        }
        die if ref $venue_data;
        
        my $known_addr = Event::Scraper::Website::Swindon->find_venue($venue_data);
        my $addr_str = $known_addr->{name} || $venue_data;
        if(!$addr_str) {
            warn "No Location for this event: $addr_str\n";
            next;
        }

        my ($address) = grep { $_->{description} && ($_->{description} =~ /$addr_str/ || $addr_str =~ /$_->{description}/)} @addresses;
        if(!$address) {
            my $lookup = $addr_str;
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

        $event->{times} = [ { start => $event->{start_time}, end => undef} ]
            if(!$event->{times} && $event->{start_time});

        if(!$event->{times}[0]{start}) {
            warn "No start time for this event $event->{event_name}!\n";
            next;
        }

        print STDERR Dumper($event->{times});

        my $title = $event->{event_name};
        $title =~ s{\s+$}{};
        my ($already) = grep { $_->{title} eq $title } @$old_events;
        next if $already;

        # fun with content/newlines + html fields:
        my $long_desc = sprintf('<p>%s</p>', $event->{event_desc});
        $long_desc =~ s{\n\n}{</p><p>}g;

        my $uuid = lc(Data::GUID->new->as_string);
        my $event_vars = {
            title => $title,
            description => $long_desc,
            begins_on => $event->{times}[0]{start}->iso8601,
        ( $event->{times}[0]{end} ? (ends_on => $event->{times}[0]{end}->iso8601) : ()),
            status => lc($event->{status} || 'confirmed'),
            visibility => lc($event->{visibility} || 'public'),
            join_options => 'free',
            uuid => $uuid,
            url => $guide_base . 'events/' . $uuid,
        ( $event->{event_ticket_url} ? (
              external_participation_url => $event->{event_ticket_url}
          ) : ()),
            participant_stats => '{"creator": 1, "rejected": 0, "moderator": 0, "participant": 0, "not_approved": 0, "administrator": 0, "not_confirmed": 0}',
            # No m2m rel because no PK in eventstag
            # tags => ['facebook','import'],
            organizer_actor_id => $actor->{id},
        ( $address ? ( physical_address_id => $address->{id} ) : ()),
            attributed_to_id => $group->{id},
            # max cap 0 = no max cap?
            # json
        ( $event->{is_online} ? (options => '{"maximum_attendee_capacity":0,"anonymous_participation":true,"is_online":true}')
          : (options => '{"maximum_attendee_capacity":0,"anonymous_participation":true}')),
            # picture_id !?
        };
        # options: show_end_time: false (if no end time)

        my $result = $api_client->post('/event', { event => $event_vars});
        $ecount++;
    }

    if(!$ecount) {
        warn "No future events to put in DB for: " . Dumper($source);
    }
    # print Dumper($events);
}
