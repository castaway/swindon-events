package Event::Scraper::Website::SwindonGov;

use strict;
use warnings;

use LWP::Simple 'get';
use URI;
use URI::QueryParam;
use HTML::TreeBuilder;
use Time::HiRes 'time';
use DateTime;
use DateTime::Format::Strptime;

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $source) = @_;

    # http://ww5.swindon.gov.uk/moderngov/mgCalendarMonthView.aspx?XXR=0&M=11&DD=2015&ACT=Go
    my $today = DateTime->now(time_zone => 'Europe/London');
    my $page_url = URI->new($source->{uri});
    my @events;
    foreach my $adv_month (0..2) {
        my $next_mo = $today->clone;
        $next_mo->add(months => $adv_month);
        $page_url->query_param('DD', $next_mo->year);
        $page_url->query_param('M', $next_mo->month);

        my $content = get($page_url);
        my $tree = HTML::TreeBuilder->new_from_content($content);
        my @cells = $tree->look_down(_tag => 'td',
                                     class => 'mgCalendarCell');
        foreach my $cell (@cells) {
            my $link = $cell->look_down(_tag => 'a');
            next if !$link;
            my $link_url = URI->new_abs($link->attr('href'), $page_url);
            my $title_date  = $link->attr('title');
#            print STDERR "Title/Date: $title_date\n";
            my ($title, $day,$mon,$year,$hour,$min,$apm) = $title_date =~ m{^(.*),\s(\d{1,2})/(\d{1,2})/(\d{4})(?:\s(\d{1,2})\.(\d{0,2})\s([ap])\.m\.)?};
#            print STDERR "Title: $title\n";
            if($hour && $hour < 12 && $apm eq 'p') {
                $hour += 12;
            } elsif ($hour && $hour == 12 && $apm eq 'a') {
                $hour = 0;
            }
            $hour ||= 0;
            $min ||= 0;
            my $start_date = DateTime->new(year => $year,
                                           month => $mon,
                                           day => $day,
                                           hour => $hour,
                                           minute => $min,
                                           second => 0,
                                           time_zone => 'Europe/London');
            my $page_time = time();
            my $subpage = get($link_url);
            $page_time = time()-$page_time;
            my $subtree = HTML::TreeBuilder->new_from_content($subpage);
            my $venue_str = $subtree->look_down(class => 'mgLabel',
                                                text => qr/^Venue:/);

            my %event;
            $event{event_url} = $event{event_id} = $link_url;
            $event{event_name} = $title;
            $venue_str ||= 'Civic Offices';
            $event{venue} = __PACKAGE__->extract_venue($venue_str);
            $event{times} = [ {start => $start_date} ];

            push @events, \%event;
        }
    }

    return \@events;
}

1;
