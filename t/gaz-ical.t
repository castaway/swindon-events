#!/usr/bin/perl

use strict;
use warnings;

use Events::Scraper::GazBrookfield;

my $scraper = Events::Scraper::GazBrookfield->new("file://t/data/gazb-2011-08-20.html");

## ->run returns an Events::Calendar object:
my $cal = $scraper->run();
isa_ok($cal, 'Events::Calendar');
## Both Calendar and entry objects have an 'artist' field, set at cal level if entire thing is one artist
is($cal->artist, 'Gaz Brookfield');
## ->entries is an arrayref of Events::Entry:
my $entries = $scraper->run->entries();
isa_ok($entries, 'ARRAY');

is($#$entries, 44, 'Got 44 Gaz events');
my $first = $entries->[0];
isa_ok($first, 'Events::Entry');
is($first->location, "Belusi's, Bath");
# is($first->location->{place}, 'Bath');
is($first->url, 'http://belushis.com/bars/bath');
is($first->date, '2011-08-24');
is($first->starttime, '');
is($first->endtime, '');

is($entries->[1]->location, 'The Fortescue Inn, Salcombe, Devon');
# is($entries->[1]->location->{place}, 'Salcombe, Devon');

is($entries->[4]->starttime, '13:30');
is($entries->[4]->endtime, '14:30');

is($entries->[25]->other, 'with Leon Fender Walker and Rob & The Rules');
