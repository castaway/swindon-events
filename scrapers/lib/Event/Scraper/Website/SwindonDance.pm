package Event::Scraper::Website::SwindonDance;

use strict;
use warnings;

use base 'Event::Scraper::Website::Swindon';

## Would use this, but it only has name/description as microdata, not times!
# use HTML::Microdata;

use HTML::TreeBuilder;
use LWP::Simple;
use Time::ParseDate 'parsedate';
use DateTime;

sub get_events {
    my ($self, $source) = @_;

    my $content = get($source->{uri});
    my $tree = HTML::TreeBuilder->new_from_content($content);

    my @event_divs = $tree->look_down(_tag => 'div',
                                      class => qr/tribe-events-event-entry/);
    my @events;

    foreach my $e_div (@event_divs) {
        my $img = $e_div->look_down(class => 'grid-image')->look_down(_tag => 'img');
        my $img_link = $img ? $img->attr('src') : '';
        my $act_link = $e_div->look_down('itemprop' => 'name');
        my $event_link = $act_link->look_down(_tag => 'a')->attr('href');
        my $act_name = $act_link->as_text;
        my $title = $act_link->right->look_down(_tag => 'strong');
        $title = $title ? $title->as_text : '';
        my $date_str = $e_div->look_down(class => 'event-day')->as_text;
        my $start_epoch = parsedate($date_str);
        my $d_start = $act_link->right;
        my $desc = '';
        while($d_start->right && $d_start->right->tag eq 'p') {
            $desc .= $d_start->right->as_HTML;
            $d_start = $d_start->right;
        }
        my $venue_name = $e_div->look_down('class' => 'index-entry')->look_down(_tag => 'p')->as_text;
#        print STDERR "venue name $venue_name\n";

        my %event;
        $event{event_name} = "$act_name - $title";
        $event{event_id} = $event{event_url} = $event_link;
        $event{image_url} = $img_link;
        $event{times} = [{start => DateTime->from_epoch(epoch => $start_epoch,
                             time_zone => 'Europe/London') }];
        $event{event_desc} = $desc;
        $event{venue} = __PACKAGE__->find_venue($venue_name);
        
#        print STDERR Data::Dumper::Dumper(\%event);
        push @events, \%event;
    }
    return \@events;
}

1;
