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
use lib 'lib';
use lib '/usr/src/perl/pubboards/lib';
use PubBoards::Schema;

## Config
my $conf = Config::General->new("events.conf");
my %config = $conf->getall();

## Plugins
setmoduledirs('./lib');
my @plugin_list = useall('Event::Scraper');
my %plugins = map { my $name = $_; $name =~ s{Event::Scraper::}{}; ( $name => $_) } @plugin_list;

print Dumper \%plugins;

## Database
my $schema = PubBoards::Schema->connect("dbi:$config{Setup}{dbi}:$config{Setup}{dbfile}");
if(!-f $config{Setup}{dbfile}) {
    $schema->deploy();
}

## Run
foreach my $source (@{$config{Source}}) {
    my $plugin = $plugins{$source->{plugin}};
    if(!$plugin) {
        warn "Can't find plugin named Event::Scraper::$source->{plugin} for source $source->{name}";
        next;
    }

#    next unless $source->{plugin} eq 'Facebook';
    next if $source->{plugin} eq 'Facebook' && $source->{page_id} =~ /\D/;
    my $events = $plugin->get_events($source);

    my $ecount = 0;
    foreach my $event (@$events) {
        print Dumper($event);

        ## Skip past events:
        next if $event->{start_time} && $event->{start_time} <= DateTime->now();
        
        if(!$event->{event_id}) {
            $event->{event_id} = "$source->{name}:$event->{start_time}";
        }

        my $next_venue_id;
        my $venue_data;
        ## This oughta be normalised in the Scrapers!
#        $venue_data = $event->{venue} ||  $source->{Venue};
        $venue_data = $event->{venue_loc} || $event->{venue} ||  $source->{Venue};
        
        ## We allow no venue at all? see hip routes fb events ?
        if(!$venue_data->{id}) {
            ## highly random:
            $next_venue_id = $schema->resultset('Venue')->count + 1;
            $next_venue_id = "eventy:$next_venue_id";
        }
        my $db_venue;
        if(defined $venue_data->{name}) {
            $db_venue = $schema->resultset('Venue')->find_or_new({
                name => $venue_data->{name},
                ( $venue_data->{id} ? ( id => $venue_data->{id} ) : () ),
                                                              });
        }
        if($db_venue) {
            update_venue($venue_data, $db_venue);
        }
        $event->{times} = [ { start => $event->{start_time}, end => undef} ]
            if(!$event->{times} && $event->{start_time});
        my $event_data = {
            id => $event->{event_id},
            name => $event->{event_name},
            description => $event->{event_desc},
            url => $event->{event_url},
            times => [ map { { 
                start_time => $_->{start},
                end_time   => $_->{end},
                } } @{ $event->{times} } ],
        };

        my $db_event = find_or_create_event($schema, $db_venue, $event_data);
        if($db_venue) {
            if(!$db_venue->id) {
                $db_venue->id($next_venue_id);
            }
            if(!$db_venue->in_storage) {
                $db_venue->insert;
            } else {
                $db_venue->update;
            }
            $db_event->venue($db_venue);
            $db_event->update()
        }

        my @acts = $event->{event_name};

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
            my $db_act = $db_event->event_acts->related_resultset('act')->find_or_create({
                name => $act,
                                                                                         });
            $db_event->find_or_create_related('event_acts', { act => $db_act });
        }
        $ecount++;
    }

    if(!$ecount) {
        warn "No future events to put in DB for: " . Dumper($source);
    }
#    print Dumper($events);
}

sub find_or_create_event {
    my ($schema, $db_venue, $event_data) = @_;

    ## Find an event with matching times/venue, add any missing times
    ## or create new event
    my $dtf = $schema->storage->datetime_parser;
    my $db_event;
    my $events_rs;
    my @time_search = (
            {
                'times.start_time' => { 
                    '-in' => [ map { $dtf->format_datetime($_->{start_time}) } @{$event_data->{times} } ]
                },
            },
            {
                columns => [ 'id' ],
                distinct => 1,
                join    => 'times',
            }
        );
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
        ## We found it!
        $db_event = $events_rs->first;
        $db_event->times->delete;
        $db_event->times_rs->create($_) for (@{ $event_data->{times} });
        # $db_event->times_rs->create({ start_time => $_->{start},
        #                               end_time => $_->{end} }) for (@{ $event_data->{times} });
    }
    
    
    $db_event ||= $schema->resultset('Event')->find_or_create($event_data);
    return $db_event;
}

# Might have multiple URLs, from swindon.gov and facebook?
sub update_venue {
    my ($venue, $db) = @_;

    $db->url($venue->{url}) if(!$db->url && $venue->{url});
    my $address = join("\n", $venue->{qw/street city zip/});
    $db->address($address);
    $db->latitude($venue->{latitude});
    $db->longitude($venue->{longitude});
    my $url_name = lc $venue->{name};
    $url_name =~ s/[^\w\d\s]//g;
    $url_name =~ s/\s+/ /g;
    $url_name =~ s/\s/-/g;
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
}
