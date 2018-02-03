package Event::Scraper::Website::FriendsOfTwigs;

use strict;
use warnings;

use LWP::Simple 'get';
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $source_info) = @_;

    my $page = get($source_info->{uri});
    ## hmm, the wordpress has some anti-scraping stuff on it?
    return [] if (!$page);

    my $tree = HTML::TreeBuilder->new_from_content($page);
    my @event_divs = $tree->look_down('class' => 'entry-content')
        ->look_down(_tag => 'div',
                    'class' => 'rt-block');

    my $dtp = DateTime::Format::Strptime->new(pattern => '%a %d %b %Y',
                                              time_zone => 'Europe/London',
        );
    my @events;
    my $now  = DateTime->now();
    my %months => ( 'January' => 1, February => 2, March => 3, April => 4, May => 5, June => 6, July => 7, August => 8, September => 9, October => 10, November => 11, December => 12);
    foreach my $div (@event_divs) {
        my $name = $div->look_down('class' => 'module-title');
        next if !$name;
        my $desc = $div->look_down('class' => 'module-content')->as_text;
        my @date_info = $div->look_down('_tag' => 'ul');
        foreach my $date_str (@date_info) {
            # 12 February 11am to 3pm
            # 21 January Wassail
            # 12 February Snowdrop Day
            my ($day, $month, $time, $title) = $desc =~ /(\d{1,2})\s(\w+)(?:\s(\d{1,2}[ap]m to \d{1,2}[ap]m))|(?:([\w\s]+))/mi;

            my $start_date = $now->clone();
            $start_date->set_day($day);
            $start_date->set_month($months{$month});

            my @times;
            if($time) {
                @times = $time =~ /(\d+)(a|p)m.+(\d+)(a|p)m/;
                if($times[1] eq 'p') {
                    if($times[0] < 12) {
                        $times[0] += 12;
                    } else {
                        $times[0] = 0;
                    }
                }
                if($times[3] eq 'p') {
                    if($times[2] < 12) {
                        $times[2] += 12;
                    } else {
                        $times[2] = 0;
                    }
                }
            } else {
                @times = (0,'',0,'');
            }

            my $start = $start_date->clone();
            $start->set_hour($times[0]);
            $start->set_minute(0);
            $start->set_second(0);

            my $end = $start_date->clone();
            $start->set_hour($times[2]);
            $start->set_minute(0);
            $start->set_second(0);

            my %event;
            $event{event_name} = $name->as_text();
            $event{event_url} = $source_info->{uri};
            $event{event_id} = $source_info->{uri} . "$start";
            $event{start_time} = $start;
            $event{end_time} = $end;
            $event{venue} = __PACKAGE__->find_venue('Twigs');
            push @events, \%event;
        }
    }

    print STDERR Data::Dumper::Dumper(\@events);
    return [];
    return \@events;
}

1;
