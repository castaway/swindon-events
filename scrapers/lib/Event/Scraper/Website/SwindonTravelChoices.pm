package Event::Scraper::Website::SwindonTravelChoices;
BEGIN {
    $HTML::Tagset::HTML_VERSION='v5';
};

use strict;
use warnings;

# use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use Data::Dumper;
use DateTime::Format::Strptime;
use DateTime;
# use LWP::ConsoleLogger::Easy;

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $config) = @_;

    my $ua = LWP::UserAgent->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.114 Safari/537.36');
    my $page_uri = $config->{uri};
    my $page_num = 1;
    my @events;
    while (1) {        
        my $resp = $ua->get($page_uri);
        if (!$resp->is_success) {
            # Default simple 'get' agent rejected..
            print STDERR "Fail: ", $resp->status_line;
            print STDERR $resp->content;
            return [];
        }
        #    my $page = get($config->{uri});
        my $page = $resp->decoded_content;
        my $tree = HTML::TreeBuilder->new_from_content($page);
        my @entries = $tree->look_down('_tag' => 'section');
        last if !@entries;
        
        # Tue 30th Nov 2021
        # 10.30am - 12.00pm
        my $dtptime = DateTime::Format::Strptime->new(pattern => '%a %d %b %Y %H:%M%p',
                                                      time_zone => 'Europe/London');
        my $dtpday = DateTime::Format::Strptime->new(pattern => '%a %d %b %Y',
                                                     time_zone => 'Europe/London');

        foreach my $entry (@entries) {
            my $date = $entry->look_down('class' => 'event-card-date')->as_text;
            $date =~ s/\s+/ /g;
            $date =~ s/\s/_/g;
            # print STDERR "Date: $date\n";
            my $title = $entry->look_down('_tag' => 'h3')->as_text;
            my $desc = $entry->look_down('class' => 'event-card-summary')->as_text;
            my $url = $entry->look_down('_tag' => 'a')->attr('href');
            my $id = $url . $date;

            my $event_page = $ua->get($url)->decoded_content();
            my $event_tree = HTML::TreeBuilder->new_from_content($event_page);
            my @date_time_str = $event_tree->look_down('class' => 'event-meta')->look_down('_tag' => 'li');
            my $date_str = $date_time_str[0]->look_down('_tag' => 'p')->as_text;
            my $time_str = $date_time_str[1]->look_down('_tag' => 'p')->as_text;
            # 10.00am - 11.00am
            # 9am - 12pm
            # 12.30pm
            # 10.00 - 16.00
            # 9:00am - 12:00pm
            my @times = $time_str =~ /^(\d+)(?:[\.:](\d+))?([apm]+)?(?:\s+-\s+(\d+)(?:[\.:](\d+))?([apm]+)?)?$/;
            $date_str =~ s/(th|st|nd|rd)//g;
            # print STDERR $time_str, "\n";
            $times[1] ||= 0;
            $times[2] ||= '';
            $times[4] ||= 0;
            $times[5] ||= '';
            # print STDERR Data::Dumper::Dumper(\@times);
            my $dtstart = "$date_str $times[0]:$times[1]$times[2]";
            my $dtend   = $times[3] ? "$date_str $times[3]:$times[4]$times[5]" : '';
            # print STDERR "Start/end, $dtstart, $dtend\n";
            my %event;
            $event{event_id} = $id;
            $event{event_url} = $url;
            $event{event_name} = $title;
            $event{event_desc} = $desc;
            # $event{venue}{zip} = $loc && $loc->[0]->value;
            my ($start,$end) = map { $dtptime->parse_datetime($_) } ($dtstart,$dtend);
            my $all_day = 0;
            if(!$start && !$end) {
                # maybe no times?
                ($start,$end) = map { $dtpday->parse_datetime($_) } ($dtstart,$dtend);
                if($start == $end) {
                    $end = undef;
                    $all_day = 1;
                }
            }
            $event{times}[0] = {
                start => $start,
                end => $end || undef,
                all_day => $all_day,
            };
            
            push @events, \%event;
            sleep 1;
        }
        $page_num++;
        $page_uri = $config->{uri} . "/page/$page_num";
    }
#    print STDERR Data::Dumper::Dumper(\@events);
#    return [];
    return \@events;
}

1;
