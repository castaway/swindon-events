package Event::Scraper::Website::SwindonFestPoetry;

use strict;
use warnings;

use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';


sub get_events {
    my ($self, $source) = @_;

    my $content = get($source->{uri});
    my $tree = HTML::TreeBuilder->new_from_content($content);

    # Inconsistent and very manual layout, see Manual!
    
    my @events;
    return \@events;
}

1;
