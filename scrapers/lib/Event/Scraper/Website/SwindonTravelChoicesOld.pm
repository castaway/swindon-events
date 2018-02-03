package Event::Scraper::Website::SwindonTravelChoicesOld;

use strict;
use warnings;

use LWP::Simple;
use HTML::TreeBuilder;
use Time::ParseDate;
use DateTime;
use URI;

use base 'Event::Scraper::Website::Swindon';

my $top_uri = 'http://www.swindontravelchoices.co.uk/events.aspx';
sub get_events {
    my ($self, $config) = @_;

    my $tree = HTML::TreeBuilder->new_from_content(get($top_uri));
    my @event_rows = $tree->look_down(id => 'contentcol1')->look_down('_tag' => 'li');

    my @events;
    foreach my $e_row (@event_rows) {
        my $event;
        my $a_tag = $e_row->look_down('_tag' => 'h3')->look_down('_tag' => 'a');
        # Usually: Monday development road ride - Monday 31st August 2015
        my ($name, $date) = $a_tag->as_text =~ /(.*?)\s+-\s+(\w+\s+[\d\w]+\s+\w+\s+\d+)$/;
        if(!$name) {
            ## Some entries don't have name - date, there's no date:
            # Go Bananas! - Celebrate Cycle to work week!
            $name = $a_tag->as_text;
        }
        $event->{event_name} = $name;
        $event->{event_id} = $event->{event_url} = URI->new_abs($a_tag->attr('href'), $top_uri);
        $event->{event_desc} = $e_row->look_down('_tag' => 'p')->as_text;

        my $sub_page = HTML::TreeBuilder->new_from_content(get($event->{event_url}));
        my @e_desc = $sub_page->look_down(id => 'contentcol1')->look_down('_tag' => 'p');
        my $full_desc = join(' ', map { $_->as_text } @e_desc);
        $event->{event_desc} = $full_desc;
        $event->{venue} = __PACKAGE__->extract_venue($full_desc);

        if(!$event->{venue}) {
            warn "No venue in $full_desc";
        }
        my $e_date_str = $sub_page->look_down(class => 'eventdate')->as_text;

        my ($start_str, $end_str) = split(/\s+-\s+/, $e_date_str);
        my $start = parsedate($start_str);
        my $end = parsedate($end_str);

        $event->{times} = [ { start => DateTime->from_epoch(epoch => $start, time_zone => 'Europe/London'),
                              end => DateTime->from_epoch(epoch => $end, time_zone => 'Europe/London') }];
        push @events, $event;
        sleep 1;
    }

    return \@events;
}

1;
