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
use Geo::Distance;
use Geo::Coder::Mapquest;
use Geo::Coder::OSM;
use Geo::UK::Postcode::Regex;
use Storable 'retrieve';
use lib '/usr/src/events/HTML-Tagset/lib';
use HTML::Tagset; # v5

use lib 'lib';
use lib '../lib';
#use lib '/usr/src/perl/pubboards/lib';
use PubBoards::Schema;

## Provide a param to use only matching sources:
my $filter = shift;

## Config
my $conf = Config::General->new("events.conf");
my %config = $conf->getall();

## Keys
my $keyconf = { Config::General->new("keys.conf")->getall() };

## Coder:
my $mapquest_key = $keyconf->{Keys}{mapquest_key};
my $geocoder = Geo::Coder::Mapquest->new(
    apikey => $mapquest_key,
    open => 1,
);
my $osmcoder = Geo::Coder::OSM->new();
# my $oscodes = retrieve("oscodes.store");

## static maps:
my $map_image_path = $ENV{EVENTS_HOME}. '/app/static/images/maps/';

## Plugins
setmoduledirs('./lib');
#my @plugin_list = useall('Event::Scraper');
my @plugin_list = findallmod('Event::Scraper');
# if ($filter) {
#     @plugin_list = grep {$_ =~ /$filter/i} @plugin_list;
# }
my %plugins = map { my $name = $_; $name =~ s{Event::Scraper::}{}; ( $name => $_) } @plugin_list;

for (values %plugins) {
    eval "use $_; 1;" or die "can't load $_: $@"
}

print Dumper \%plugins;

## Database
my $schema = PubBoards::Schema->connect("dbi:$config{Setup}{dbi}:$config{Setup}{dbname}", $config{Setup}{dbuser}, $config{Setup}{dbpass});
#if(!-f $config{Setup}{dbfile}) {
#    $schema->deploy();
#}

## To calculate "Swindon" events (so we can add more blanket fb groups etc)

my $swindon_centre = $config{Setup}{centre};
my $max_dist       = $config{Setup}{max_dist}; #miles
my $geo_dist = Geo::Distance->new();
$geo_dist->formula('mt');

## Run
foreach my $source (@{$config{Source}}) {
    my $plugin = $plugins{$source->{plugin}};
    if(!$plugin) {
        # warn "Can't find plugin named Event::Scraper::$source->{plugin} for source $source->{name}";
        next;
    }

#    next unless $source->{plugin} =~ /Beehive/;
#    next if $source->{plugin} eq 'Facebook';
#    next if $source->{plugin} eq 'Facebook' && $source->{page_id} =~ /\D/;
    next if $filter && $source->{plugin} !~ /$filter/i;
    # next if $filter && $source->{name} !~ /$filter/i;

    if($source->{is_oo}) {
        $plugin = $plugin->new();
    }
    my $events = $plugin->get_events($source, $keyconf->{Keys}{ $source->{plugin} });

    # some APIs (eg ents24), says dont keep data (for > 1hr)
    # so we delete all existing before we add
    if($source->{dont_keep_old_data}) {
        my $dont_url = $source->{dont_keep_match};
        # times
        $schema->resultset('Time')->search_rs(
            {
                'event.url' => { '-like' => "$dont_url%" },
            },
            {
                join => 'event',
            }
            )->delete;
        # categories
        $schema->resultset('EventCategories')->search_rs(
            {
                'events.url' => { '-like' => "$dont_url%" },
            },
            {
                join => 'events',
            }
            )->delete;
        # Keep user's starred events (I assume we're re-inserting with same event ids!)
        # Keep venues..
        # venues
        # $schema->resultset('Venue')->search_rs(
        #     {
        #         'events.url' => { '-like' => "$dont_url%" },
        #     },
        #     {
        #         join => 'events',
        #     }
        #     )->delete;
        # events
        $schema->resultset('Event')->search_rs(
            {
                'me.url' => { '-like' => "$dont_url%" },
            },
            {
            }
            )->delete;
    }

    my $ecount = 0;
    foreach my $event (@$events) {
        # print Dumper($event);

        ## Skip past events:
        next if $event->{start_time} && $event->{start_time} <= DateTime->now();
        
        if(!$event->{event_id}) {
            my $start = $event->{start_time} || $event->{times}[0]{start};
            $event->{event_id} = "$source->{name}:$start";
        }

        my $next_venue_id;
        my $venue_data;
        ## This oughta be normalised in the Scrapers!
#        $venue_data = $event->{venue} ||  $source->{Venue};
        $venue_data = $event->{venue_loc} || $event->{venue} ||  $source->{Venue};
        
        ## We allow no venue at all? see hip routes fb events ?
        if(!$venue_data->{id}) {
            ## highly random:
            $next_venue_id = $schema->resultset('Venue')->count + 10;
            $next_venue_id = "eventy:$next_venue_id";
        }
        my $db_venue;
        if(defined $venue_data->{name}) {
            $venue_data->{name} =~ s/\.$//;
            print "Venue search: name $venue_data->{name}\n";
            $db_venue = $schema->resultset('Venue')->find({
                name => [ $venue_data->{name},
                          { '-ilike' => $venue_data->{name} }
                    ],
                ( $venue_data->{id} ? ( id => $venue_data->{id} ) : () ),
                                                              });
            if(!$db_venue) {
                my $url_name = venue_url($venue_data->{name});
                print "Venue search: url $url_name\n";
                $db_venue = $schema->resultset('Venue')->find_or_new({
                    name => $venue_data->{name},
                    url_name => $url_name,
                    ( $venue_data->{id} ? ( id => $venue_data->{id} ) : () ),
                                                                     }, {
                                                                     key => 'url_name'});
            }                
        }

        if($db_venue) {
            update_venue($venue_data, $db_venue);
        }
        $event->{times} = [ { start => $event->{start_time}, end => undef} ]
            if(!$event->{times} && $event->{start_time});

        print STDERR Dumper($event->{times});
        ## Don't bother attempting to insert events that already happened:
        my $now = DateTime->now();
        my $event_data = {
            id => $event->{event_id},
            name => $event->{event_name},
            description => $event->{event_desc},
            url => $event->{event_url},
            times => [ map { $_->{start} >= $now 
                                 ? { 
                                     start_time => $_->{start},
                                     end_time   => $_->{end},
                                     all_day    => ($_->{all_day} || 0),
                             }
                       : ()} @{ $event->{times} } ],
            event_categories => [ map { { name => $_ } } (split(/,/, $source->{genre})) ],
        };

        ## Only import events that are within our "area" (defined in config)
        if($db_venue && $db_venue->latitude) {
            my $dist = $geo_dist->distance('mile', $swindon_centre->{lat}, $swindon_centre->{lng}, $db_venue->latitude, $db_venue->longitude);
            next if $dist > $max_dist;
        }
        
        ## what if there are now no times set at all?
        ## remove dupe times!
        my $db_event = find_or_create_event($schema, $db_venue, $event_data, $event->{future_times_delete});
        
        $db_event->update({ url => $event->{event_url} });
        $db_event->find_or_create_related('event_categories', $_) for (@{$event_data->{event_categories}});
        
        if($db_venue) {
            if(!$db_venue->id) {
                $db_venue->id($next_venue_id);
            }
            if(!$db_venue->in_storage) {
                $db_venue->name($venue_data->{name});
                $db_venue->insert;
            } else {
                $db_venue->update;
            }
            print STDERR Dumper({$db_venue->get_columns});
            print STDERR Dumper({$db_event->get_columns});
            $db_event->venue($db_venue);
            $db_event->update()
        }

        # insert_acts($db_event, $event->{event_name});
        $ecount++;
    }

    if(!$ecount) {
        warn "No future events to put in DB for: " . Dumper($source);
    }
#    print Dumper($events);
}

sub find_or_create_event {
    my ($schema, $db_venue, $event_data, $future_times_delete) = @_;

    ## Find an event with matching times/venue, add any missing times
    ## or create new event
#    my $dtf = $schema->storage->datetime_parser;
    my $times_rs = $schema->resultset('Time');
    my $db_event;
    my $events_rs;
    my $times = delete $event_data->{times};

    ## NB: as we've set "timezone" on the Time fields, magic should
    ## convert to UTC on insert/select (inflate/deflate) of timezones,
    ## but .. that doesn't apply to manual use of format_datetime for
    ## searches.. grr

    my @time_search = (
            {
                'times.start_time' => { 
#                    '-in' => [ map { $dtf->format_datetime($_->{start_time}) } @{@$times} ]
                    '-in' => [ map { 
                        $times_rs->format_datetime('start_time', 
                                                   $_->{start_time}) 
                               } (@$times) ]
                },
            },
            {
                columns => [ 'id', 'unique_id' ],
                distinct => 1,
                join    => 'times',
            }
        );
    $schema->storage->txn_do(sub {
        if($db_venue && $db_venue->in_storage) {
            $events_rs = $db_venue->related_resultset('events')->search(@time_search);
        } else {
            $events_rs = $schema->resultset('Event')->search({
                %{$time_search[0]},
                'me.id' => $event_data->{id}
                                                             },
                                                             $time_search[1]);
        }

        my $event_count = $events_rs->count;
        if($event_count > 1) {
            warn "Multiple events at same venue at same time!? $event_data->{name}";
        }
        if($event_count == 1) {
            ## We found it! Replace/Update all the known times:
            $db_event = $events_rs->first;
        }

        $db_event ||= $schema->resultset('Event')->find_or_create($event_data);
        ## Don't delete, we don't know if the next set of data removes old ones, also we have an FK to starred_events - which should cascade?
        ## Remove event times in the future, but keep starred?
        # a) collect existing times in-future (key)
        # b) update/create new times
        # c) remove/cascade items in A that didnt get added/updated in B
        # $db_event->times->delete;
        ## Delete future events if the source allows:
        if($future_times_delete) {
            $db_event->times->search({ start_time => { '>=' => $schema->storage->datetime_parser->format_datetime(DateTime->now) } })->delete;
        }
        ## Should probably eliminate dupe times.. somehow ;)
        
        my %orig_times = map { $_->start_time->iso8601 => $times_rs->format_datetime('start_time', $_->start_time) } ($db_event->times_rs->search({
            'start_time' => { '>=' => $times_rs->format_datetime('start_time', DateTime->now) },
                                                                                                                                                  }));
    
        # Special "fun with timezones" check!
        foreach my $t (@$times) {
            warn "Looking for: ", $t->{start_time}->iso8601(), "\n";
            delete $orig_times{$t->{start_time}->iso8601()};
            
            my $minus_one = $t->{start_time}->clone->subtract(hours => 1);
            my $plus_one = $t->{start_time}->clone->add(hours => 1);
            if($db_event->times_rs->search({ start_time => $times_rs->format_datetime('start_time', $minus_one) })->count) {
                warn "TIMEZONE ERROR ? -1 " . $db_event->id . " " . $minus_one->iso8601;
            }
            my $plus_rs = $db_event->times_rs->search({ start_time => $times_rs->format_datetime('start_time', $plus_one) });
            if($plus_rs->count) {
                warn "TIMEZONE ERROR ? +1 FIXING " . $db_event->id . " " . $plus_one->iso8601;
                $plus_rs->related_resultset('starred_events')->delete;
                $plus_rs->delete;
            }
        }
        print STDERR "Left over!", Data::Dumper::Dumper(\%orig_times);
        $db_event->times_rs->search({
            start_time => { '-in' => [ values %orig_times ] }
                                    })->related_resultset('starred_events')->delete;
        $db_event->times_rs->search({
            start_time => { '-in' => [ values %orig_times ] }
                                    })->delete;

        # So we have to find_or_create (essentially an exists_or_create as we dont care about the result) and only add the new ones
        $db_event->times_rs->find_or_create(
            { 
                start_time => $times_rs->format_datetime('start_time', $_->{start_time}),
                end_time => $_->{end_time} ? $times_rs->format_datetime('end_time', $_->{end_time}) : undef,
                time_key => $event_data->{id} . $_->{start_time}->ymd . $_->{start_time}->hms,
                ($_->{all_day} ? (all_day => $_->{all_day}) : () ),
            },
            
                                            { key => 'primary' })
            for (@{ $times });
        # $db_event->times_rs->create({ start_time => $_->{start},
        #                               end_time => $_->{end} }) for (@{ $event_data->{times} });

        ## Update/set time_key on times table (post insert as needs events unique_id)
        foreach my $t ($db_event->times) {
            print STDERR "Updating time_key for: ", $t->start_time->iso8601, "\n";
            try {
                $t->update({ time_key => sprintf("%s_%04d_%02d_%02d_%02d_%02d", 
                                                 $db_event->unique_id,
                                                 $t->start_time->year,
                                                 $t->start_time->month,
                                                 $t->start_time->day,
                                                 $t->start_time->hour, 
                                                 $t->start_time->minute)
                           });
            } catch {
                warn "$_;"
            };
        }
    });
    return $db_event;
}

# Might have multiple URLs, from swindon.gov and facebook?
# attempt to geocode the address into lat,lon, if not present
sub update_venue {
    my ($venue, $db) = @_;

    my $addr = join(",", $venue->{street}||'', $venue->{city}||'', $venue->{zip}||'', $venue->{country}||'');
    my $postcode_re = qr/[A-Z]{1,2}\s*[0-9]\s*(?:[0-9]|[A-Z])?\s*[0-9]\s*[A-Z]{2}/;
    #print STDERR "Postcode re: $postcode_re\n";
    my $pcode = '';
    if($addr !~ /\w/) {
        # facebook, entire venue addr sometimes in name field
        $addr = $venue->{name};
        $addr =~ s/($postcode_re)/, $1/x;
        $pcode = $1;
        $addr .= ', United Kingdom';
    }
    if(!$addr || $addr !~ /\w/) {
        print STDERR Data::Dumper::Dumper(["Can't geocode, no commas/content", $venue]);
    }
    print STDERR "Geocoding $addr\n";
    # check for $loc post geocoding, as we get undef if we have done
    # too many in a day!
#    my $osmres = $osmcoder->geocode(location => $addr);
#    print STDERR Data::Dumper::Dumper($osmres);
    if(!$venue->{longitude} && !$db->longitude) {
        my $loc = $geocoder->geocode(location => $addr);
#        print STDERR Data::Dumper::Dumper([$addr, $loc]);
        while($loc && $loc->{geocodeQualityCode} !~ /^(P1|L1|I1|B1|B2|B3|Z1)/ && $addr) {
            $addr =~ s/^([^,]*,\s*)//;
            $loc = $geocoder->geocode($addr);
#            print STDERR "MAPQ: ", Data::Dumper::Dumper([$addr, $loc]);
#            $osmres = $osmcoder->geocode(location => $addr);
#            print STDERR "OSM: ", Data::Dumper::Dumper($osmres);
            last if !$addr || $addr !~ /,/;
        }
#        $osmres = $osmcoder->geocode(location => $addr);
#        print STDERR Data::Dumper::Dumper($osmres);
        print STDERR Data::Dumper::Dumper([$addr, $loc]);
        if($loc && $loc->{displayLatLng} && $loc->{displayLatLng}{lat}
            && $loc->{geocodeQualityCode} =~ /^(P1|L1|I1|B1|B2|B3|Z1)/) {
            $venue->{latitude} = $loc->{displayLatLng}{lat};
            $venue->{longitude} = $loc->{displayLatLng}{lng};
        } else {
            # Attempt to get Lat/Lng for postcode, from OS data:
            if($pcode) {
                $pcode =~ s/\s+//g;
                my $lookup = $schema->resultset('OSCodes')->find({ code => uc ($pcode) });
                next if !$lookup;
                $venue->{latitude} ||= $lookup->latitude;
                $venue->{longitude} ||= $lookup->longitude; 
                # $oscodes->{uc ($pcode) }[1];
                ## Enforce skipping of this venue if we have its postcode
                # but it isnt in SN (oscodes only has SN as loading the whole
                # thing took up much memory
                $venue->{latitude} ||= 0;
                $venue->{longitude} ||= 0;
                
                print STDERR "Post code lat/lng: ($pcode) $venue->{latitude} $venue->{longitude}\n";
            }
        }
    }
    
    $db->url($venue->{url}) if(!$db->url && $venue->{url});
    my $address = join("\n", @{$venue}{qw/street city zip/});
    $db->address($address);
    $db->latitude($venue->{latitude});
    $db->longitude($venue->{longitude});
    my $url_name = venue_url($venue->{name});
    print STDERR "URL name for $venue->{name} is $url_name\n";
    $db->url_name($url_name) if(!$db->url_name && $url_name);

    # has_food, has_wifi, is_outside etc
    if(exists $venue->{flags}) {
        foreach my $flag (keys %{$venue->{flags}}) {
            if($venue->{flags}{$flag} && $db->can($flag)) {
                $db->$flag(1);
            }
        }
    }

    ## Attempt to create a static map for this venue (if lat/lon exists)
    $db->store_map($map_image_path, $mapquest_key);
}

sub venue_url {
    my ($name) = @_;

    return $schema->resultset('Venue')->venue_url($name);
}

sub insert_acts {
    my ($db_event, @acts) = @_;

    @acts = map {if (m/^(.*) presents: ?(.*)/) {
        # x presents: ... -- how do we list x?  It's not really an
        # act, so we shouldn't have it in @acts, and we already have
        # the event name as a whole.  When we have a recommendation
        # engine, revisit this?
        ($2);
                 } else {
                     ($_);
                 }}
    @acts;

    @acts = map {split(/ \+ /, $_)} @acts;
    @acts = map {split(/, /, $_)} @acts;
        

    foreach my $act (@acts) {
#            my $db_act = $db_event->event_acts->related_resultset('act')->find_or_create({
#        my $db_act = $schema->resultset('Act')->search({ name => $act });
        my $db_act = $schema->resultset('Act')->find_or_create({
            name => $act,
                                                               });
        $db_event->find_or_create_related('event_acts', { act => $db_act });
    }   
}

sub venue_url {
    my ($name) = @_;

    return $schema->resultset('Venue')->venue_url($name);
}

sub insert_acts {
    my ($db_event, @acts) = @_;

    @acts = map {if (m/^(.*) presents: ?(.*)/) {
        # x presents: ... -- how do we list x?  It's not really an
        # act, so we shouldn't have it in @acts, and we already have
        # the event name as a whole.  When we have a recommendation
        # engine, revisit this?
        ($2);
                 } else {
                     ($_);
                 }}
    @acts;

    @acts = map {split(/ \+ /, $_)} @acts;
    @acts = map {split(/, /, $_)} @acts;
        

    foreach my $act (@acts) {
#            my $db_act = $db_event->event_acts->related_resultset('act')->find_or_create({
#        my $db_act = $schema->resultset('Act')->search({ name => $act });
        my $db_act = $schema->resultset('Act')->find_or_create({
            name => $act,
                                                               });
        $db_event->find_or_create_related('event_acts', { act => $db_act });
    }   
}
