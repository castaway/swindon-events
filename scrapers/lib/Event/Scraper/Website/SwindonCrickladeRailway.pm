package Event::Scraper::Website::SwindonCrickladeRailway;

use strict;
use warnings;

use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use Time::ParseDate 'parsedate';
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';


sub get_events {
    my ($self, $source) = @_;

    my $content = get($source->{uri});
    my $tree = HTML::TreeBuilder->new_from_content($content);

    $tree->dump;
    
    my %events;

    my @event_list = $tree->look_down(_tag => 'li',
                                      class => qr/ecs-event /,
                                      #sub { $_[0]->attr('class') =~ /ecs-event / }
        );
    
    # my $current = $tree->look_down(_tag => 'ul',
    #                                class => 'ecs-event-list'
    #                                # sub { $_[0]->as_text =~ /^\d{4} Special Events$/ }
        
    #     );

    my ($month, $year) ;
    foreach my $event_li (@event_list) {
        my %event;
        my $link = $event_li->look_down(_tag => 'a');
        $event{event_name} = $link->as_text;
        $event{event_url} = $link->attr('href');
        my $e_time = $event_li->look_down(_tag => 'span',
                                          class => 'duration time')->as_text;
        # 24 July @ 11:00 am - 3:04 pm
        my ($date, $start,$end) = $e_time =~ /(\d+\s+\w+(?:\s+\d{4})?)\s+\@\s+(\d+:\d+\s*[ap]m)\s*-\s*(\d+:\d+\s*[ap]m)/;
#        my ($date, $start, $startap, $end, $endap) = $e_time =~ /(\d\s+\w+)\s+\@\s+(\d+:\d+)\s*([ap])m\s*-\s*(\d+:\d+)\s*([ap])m/;
        # if($endap eq 'p' && $end <= 12) {
        #     $end += 12;
        # }
        my ($starttime, $endtime);
        if($date) {
            print STDERR "Parsed: $date $start $end from $e_time\n";
            $starttime = parsedate("$date $start", PREFER_FUTURE => 1);
            $endtime = parsedate("$date $end", PREFER_FUTURE => 1);
        } else {
            # 27 July - 28 July
            my ($date_start, $date_end) = $e_time =~ /(\d+\s+\w+)\s*-\s*(\d+\s+\w+)/;
            if(!$date_start) {
                warn "Can't parse dates from $e_time\n";
            } else {
                print STDERR "Parsed: $date_start $date_end from $e_time\n";
                $starttime = parsedate("$date_start", PREFER_FUTURE => 1);
                $endtime = parsedate("$date_end", PREFER_FUTURE => 1);
            }
        }
        
        $event{times} = [ {
            start => DateTime->from_epoch(epoch => $starttime, time_zone => 'Europe/London'),
            end => DateTime->from_epoch(epoch => $endtime, time_zone => 'Europe/London'),
        }];
        my $id = $event{event_url};
        $id =~ s{https://swindon-cricklade-railway.org/event/}{};
        $id =~ s{\s}{}g;
        $id = "schr://$id";
        if($events{ $event{event_url} }) {
            push @{ $events{ $event{event_url} }{times} }, {
                start => $event{times}[0]{start},
                end => $event{times}[0]{end},
            };
        } else {
            $events{ $event{event_url} } = {
                event_id => $id,
                venue => __PACKAGE__->find_venue('Swindon and Cricklade Heritage Railway'),
                %event,
            };
        }
    }

    #print STDERR Data::Dumper::Dumper(values %events);

    #return [];
    return [ values %events ];
}

1;
