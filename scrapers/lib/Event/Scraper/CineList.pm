package Event::Scraper::CineList;

use strict;
use warnings;

use Data::Dumper;
use JSON;
use LWP::Simple 'get';
use DateTime;
use URI;

use base 'Event::Scraper::Website::Swindon';
# http://www.cinelist.co.uk/
# https://api.cinelist.co.uk/search/cinemas/postcode/sn13pr - list of cinemas locally
# times = https://api.cinelist.co.uk/get/times/cinema/8511?day=N (days in advance)

my $base_uri = 'https://api.cinelist.co.uk/get/times/cinema/';
sub get_events {
    my ($self, $config) = @_;

    # {"postcode":"sn13pr","cinemas":[{"name":"Cineworld Swindon - Regent Circus, ","id":"8674","distance":0.76},{"name":"Empire Swindon (Greenbridge), Swindon","id":"8511","distance":1.82},{"name":"Cineworld Swindon - Shaw Ridge, ","id":"8668","distance":2.06},{"name":"Palace Cinema Devizes, Devizes","id":"10494","distance":16.55}]}

    my @swindon_cinemas = ({ id => 8674, name => 'Cineworld Regent Circus' },
                           { id => 8511, name => 'Empire Greenbridge' },
                           { id => 8668, name => 'Cineworld Shaw Ridge' });

    my %events;
    foreach my $day (0..20) {
        my $start_date = DateTime->now(time_zone => 'Europe/London')->clone->add(days => $day);
        foreach my $c (@swindon_cinemas) {
            my $listings_j = get("${base_uri}$c->{id}");
            my $listings = decode_json($listings_j);
            
            foreach my $show (@{ $listings->{listings} }) {
                my $id = "cinelist_$c->{name}_$show->{title}";
                my $event = $events{$id} || {};
                $event->{event_id} = $id;
                # eg http://www.imdb.com/find?ref_=nv_sr_fn&q=The+LEGO+Batman+Movie&s=tt
                $event->{event_url} = URI->new('http://www.imdb.com/find');
                $event->{event_url}->query_form(
                    ref_ => 'nv_sr_fn',
                    q => $show->{title},
                    s => 'tt'
                );
                $event->{event_name} = $show->{title};
                $event->{times} ||= [];
                $event->{venue} = __PACKAGE__->find_venue($c->{name});
                foreach my $time (@{ $show->{times} }) {
                    my ($hr,$min) = $time =~ /^(\d{2}):(\d{2})$/;
                    my $start = $start_date->clone->set_hour($hr);
                    $start->set_minute($min);
                    push @{ $event->{times} }, { start => $start } ;
                    $events{$id} = $event;
                }
            }
        }
    }

#    print Dumper(values %events);
#    return [];
    return [ values %events ];
}

1;

