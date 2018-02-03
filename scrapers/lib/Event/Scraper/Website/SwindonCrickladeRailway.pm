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

    my $current = $tree->look_down(_tag => 'tr',
                               sub { $_[0]->as_text =~ /^\d{4} Special Events$/ }
        );

    my ($month, $year) ;
    while($current = $current->right) {
        last if !$current;
        my $td = ($current->content_list)[0];
        if($td->attr('colspan') && $td->attr('colspan') == 3) {
            # Its probably a month/year string:
            if($current->as_text =~ /(\w+) (\d{4})/) {
                $month = $1;
                $year = $2;
            }
            next;
        }
        ## Else its 3 cols, day, date, link:
        my @cols = $current->look_down(_tag => 'td');
        my $day = $cols[0]->as_text;
        my $date = $cols[1]->as_text;
        my $name = ($cols[2]->content_list)[0];
        $name = ref $name ? $name->as_text : $name;
        my $link = $cols[2]->look_down(_tag => 'a');
        $link ||= $cols[2];

        # basic opening times are 11am-4pm (see basic info page)
        my $date_str = "$month $date, $year";
        my $date_epoch = parsedate($date_str);
        my $start_time = DateTime->from_epoch(epoch => $date_epoch, time_zone => 'Europe/London');
        $start_time->set_hour(11);
        $start_time->set_minute(0);
        $start_time->set_second(0);
        my $end_time = DateTime->from_epoch(epoch => $date_epoch);
        $end_time->set_hour(16);
        $end_time->set_minute(0);
        $end_time->set_second(0);

        if($cols[2]->as_text =~ /(\d{1,2}):(\d{1,2})([ap]m)(?:\s-\s(\d{1,2}):(\d{1,2})([ap]m))?/) {
            # Either a start time or a start/end
            my $hour = $3 eq 'pm' && $1 < 12 ? $1 + 12 : $1;
            $start_time->set_hour($hour);
            $start_time->set_minute($2);
            if($4) {
                my $hour = $6 eq 'pm' && $1 < 12 ? $4 + 12 : $4;
                $end_time->set_hour($hour);
                $end_time->set_minute($5);
            }

            ## Fix default times issue (5pm < 8pm!)
            if($end_time < $start_time) {
                $end_time = $start_time->clone->add(hours => 1);
            }
        }

        my $id = $name;
        $id =~ s{\s}{}g;
        $id = "schr://$id";
        if($events{$name}) {
            push @{ $events{$name}{times} }, {
                start => $start_time,
                end => $end_time,
            };
        } else {
            $events{$name} = {
                event_id => $id,
                event_name => $name,
                event_url => $source->{uri},
                venue => __PACKAGE__->find_venue('Swindon and Cricklade Heritage Railway'),
                times => [ {
                    start => $start_time,
                    end => $end_time,
                }],
            };
        }
    }

#    print STDERR Data::Dumper::Dumper(values %events);
    
    return [ values %events ];
}

1;
