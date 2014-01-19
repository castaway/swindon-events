#!/usr/bin/perl

use strict;
use warnings;

use Data::ICal;
use Data::ICal::Entry::Event;
use Data::ICal::DateTime;
use Config::General;
use lib 'lib';
use Data::ICal::Property::Raw;
use Event::Schema;
use Data::Dump::Streamer 'Dump', 'Dumper';
use Text::Unidecode;

## Config
my $conf = Config::General->new("events.conf");
my %config = $conf->getall();

## Database
my $schema = Event::Schema->connect("dbi:$config{Setup}{dbi}:$config{Setup}{dbfile}");
if(!-f $config{Setup}{dbfile}) {
    die "No database!";
}

my $events_rs = $schema->resultset('Event')->search({},
                                                    {
                                                        order_by => [ { '-desc' => 'start_time' } ],
                                                        prefetch => ['venue', { event_acts => 'act' }],
                                                    });

my $calendar = Data::ICal->new();

## http://www.ietf.org/rfc/rfc2445.txt
while(my $event = $events_rs->next) {
    my $i_event = Data::ICal::Entry::Event->new();
    $i_event->add_properties(
        summary => unidecode $event->name,
        description => unidecode $event->description,
        location => unidecode join(", ", $event->venue->name, $event->venue->address),
#        geo => join(';', $event->venue->latitude, $event->venue->longitude),
        # start/end handled below.
        ( map { ('resources' => unidecode $_->act->name) } ($event->event_acts->all ) ),
        ## related to? 
        ( $event->url ? (url => $event->url) : ()),
        );

    # Geo is special field; it contains a ; which needs to be not backslashed.
    if($event->venue->latitude) {
        my $geo_prop = Data::ICal::Property::Raw->new('geo',
                                                      join(';', $event->venue->latitude, $event->venue->longitude));
        $i_event->properties->{geo} = [$geo_prop];
    }

    # We need to cheat with the end time, since iCal seems to require it, but
    # we don't know it.
    $i_event->start($event->start_time);
    my $end = $event->start_time->add(hours => 3);
    $i_event->end($end);
    $calendar->add_entry($i_event);
}

print $calendar->as_string;
