package Event::Scraper::Website::CreateStudios;

use strictures 1;
use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';

my $ua = LWP::UserAgent->new();

sub get_events {
    my ($self, $source_info) = @_;

    my $events_by_id = {};
    
}
1;
