package Event::Scraper::Website::SchemaOrg;
# http://schema.org/Event
use strict;
use warnings;

use DateTime::Format::Strptime;

=head2 parse_schema

Extract http://schema.org/Event bits out of given HTML::TreeBuilder tree.

=cut

sub parse_schema {
    my ($page_tree, %extra) = @_;

    my @html_events = $page_tree->look_down(
        'itemscope' => 'itemscope',
        'itemtype' => 'https://schema.org/Event'
    );

    my @events;
    my $dt_parser = DateTime::Format::Strptime->new(
        pattern => '%FT%TZ',
        time_zone => 'Europe/London',
        on_error  => 'croak',
    );
    foreach my $s_event (@html_events) {
        my %event;
        my $image = $s_event->look_down(
            itemprop => 'image'
        );
        $event{image_url} = $image->attr('src');
        my $uri = $s_event->look_down(
            '_tag' => 'meta',
            'url' =~ qr/^http/,
            );
        $event{event_url} = $uri->attr('url');
        $event{event_id} = $uri->attr('url');
        my $start = $s_event->look_down(
            itemprop => 'startDate'
        );
        my $end = $s_event->look_down(
            itemprop => 'endDate',
        );

        
        if($start) {
            $start = $start->attr('content') || $start->attr('datetime');
            $event{times}[0]{start} = $dt_parser->parse_datetime($start);
        }
        if($end) {
            $end = $end->attr('content') || $end->attr('datetime');
            $event{times}[0]{end} = $dt_parser->parse_datetime($end);
        }

        foreach my $more (keys %extra) {
            $event{$more} = $s_event->look_down(%{ $extra{$more} })->as_text;
        }
        
        push @events, \%event;
    }

    return @events;
}


1;
