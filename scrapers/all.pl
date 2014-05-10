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

#    next if $source->{plugin} eq 'Facebook';
    next if $source->{plugin} eq 'Facebook' && $source->{page_id} =~ /\D/;
    my $events = $plugin->get_events($source);

    my $ecount = 0;
    foreach my $event (@$events) {
        print Dumper($event);

        ## Skip past events:
        next if $event->{start_time} <= DateTime->now();
        
        if(!$event->{event_id}) {
            $event->{event_id} = "$source->{name}:$event->{start_time}";
        }

        my $next_venue_id;
        my $venue_data;
        if(exists $event->{venue_loc}) {
            $venue_data = $event->{venue_loc};
        } else {
            $venue_data = $source->{Venue};
        }
        
        ## We allow no venue at all? see hip routes fb events ?
        if(!$event->{venue_loc}{id}) {
            ## highly random:
            $next_venue_id = $schema->resultset('Venue')->count + 1;
            $next_venue_id = "eventy:$next_venue_id";
        }
        my $venue;
        if(defined $venue_data->{name}) {
            $venue = $schema->resultset('Venue')->find_or_new({
                name => $venue_data->{name},
                ( $venue_data->{id} ? ( id => $venue_data->{id} ) : () ),
                                                              });
        }
        my $db_event;
        my $event_data = {
            id => $event->{event_id},
            name => $event->{event_name},
            description => $event->{event_desc},
            ## moved to Time
#            start_time => $event->{start_time},
            url => $event->{event_url},
        };
        $event->{times} = [ { start => $event->{start_time}, end => undef} ]
            if(!$event->{times} && $event->{start_time});
        if($venue && !$venue->in_storage) {
            ## This oughta be something more sane
            $venue->last_verified(DateTime->now());
            if(!$venue->id) {
                $venue->id($next_venue_id);
            }
            $venue->latitude($venue_data->{latitude});
            $venue->longitude($venue_data->{longitude});
            $venue->address(join(", ", ( map { $venue_data->{$_} || () }
                                         (qw/street city zip country/)
                                 )));
            $venue->insert;
            $db_event = $venue->create_related('events', $event_data);
        } else {
            my $dtp = $schema->storage->datetime_parser;
            if($venue) {
                $db_event = $venue->events->find_or_new({
                    start_time => $dtp->format_datetime($event->{start_time}),
                                                    });
            } else {
                $db_event = $schema->resultset('Event')->find_or_new({
                    start_time => $dtp->format_datetime($event->{start_time}),
                                                                     });
            }
            if(!$db_event->in_storage) {
                $db_event->id($event->{event_id});
                $db_event->name($event->{event_name});
                $db_event->insert;
            } else {
                warn "Updating event we already knew about, based on Venue/Starttime";
            }
            $db_event->update($event_data);
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
