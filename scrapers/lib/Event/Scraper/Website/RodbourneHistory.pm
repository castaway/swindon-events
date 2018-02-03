package Event::Scraper::Website::RodbourneHistory;

use strict;
use warnings;

use LWP::Simple 'get';
use HTML::TreeBuilder;
use Data::Dumper;
use DateTime;
# use DateTime::Format::Strptime;

use base 'Event::Scraper::Website::Swindon';

# 29th June 7 to 8pm
sub get_events {
    my ($self, $source_info) = @_;

    my $page = get($source_info->{uri});
    return [] if !$page;
    my $tree = HTML::TreeBuilder->new_from_content($page);
    my @headings = $tree->look_down('_tag' => 'h4');

    my @events;
    foreach my $heading (@headings) {
        my $block = $heading->right();
        next if $block->tag ne 'blockquote';
        my @times = $heading->as_text =~ /(\d+)(?:th|st|nd|rd)\s+(\w+)\s+(\d+)\s?([ap]m)?\s+to\s+(\d+)\s?([ap]m)?/;
        next if !@times;
        print STDERR "h4: ", $heading->as_text, "\n";
        my $now = DateTime->now(time_zone => 'Europe/London');
        if(($times[3] && $times[3] eq 'pm') || !$times[3] && $times[2] < 12) {
            $times[2] += 12;
        }
        if($times[5] eq 'pm' && $times[4] < 12) {
            $times[4] += 12;
        }
        my $month = {Janurary => 1,
                     February => 2,
                     March => 3,
                     April => 4,
                     May => 5,
                     June => 6,
                     July => 7,
                     August => 8,
                     September => 9,
                     October => 10,
                     November => 11,
                     December => 12}->{$times[1]};
        my $start = DateTime->new(day => $times[0],
                                  month => $month,
                                  year => $now->year,
                                  hour => $times[2],
                                  minute => 0,
                                  second => 0
            );
        my $end = $start->clone;
        $end->set_hour($times[4]);

        my $title = '';
        my @subelems = $block->content_list;
        $title = $subelems[0]->as_text;
        my $desc = join('', (map { $_->as_text } splice(@subelems, 1)));

        my %event;
        $event{event_name} = $title;
        $event{event_uri} = $source_info->{uri};
        $event{event_desc} = $desc;
        $event{venue} = __PACKAGE__->find_venue('Even Swindon Community Centre');
        $event{times} = [{start => $start, end => $end}];
        push @events, \%event;
    }

#    print Dumper(\@events);
    return \@events;
}

1;
