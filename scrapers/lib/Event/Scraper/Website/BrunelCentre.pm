package Event::Scraper::Website::BrunelCentre;

use strict;
use warnings;

use LWP::Simple 'get';
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use Time::HiRes;
use Try::Tiny;

use base 'Event::Scraper::Website::Swindon';

my $formatter = DateTime::Format::Strptime->new(
    pattern => '%a %d %b %Y %H:%M',
    on_error => 'croak', time_zone => 'Europe/London');

my $fmt_date = DateTime::Format::Strptime->new(
    pattern => '%a %d %b %Y',
    on_error => 'croak', time_zone => 'Europe/London');

sub get_events {
    my ($self, $source) = @_;


    warn "Brunel Centre parser broken, it went from .aspx to Angular!";
    return [];
    
    my $uri = $source->{uri};
    my $page = get($uri);
    warn $uri;
    my $tree = HTML::TreeBuilder->new_from_content($page);
    my @html_events = $tree->look_down(id => 'circle-list-container')->look_down('_tag' => 'a');

    my @events;
    # Brunel events show absolute start date/time and end date/time
    # these generally mean "every Monday between start time/end time, from first date until last date"
    foreach my $event_link (@html_events) {
        my $page_uri = URI->new_abs($event_link->attr('href'), $uri);
        my $content = get($page_uri);
        my $s_time = time();
        my $page_tree = HTML::TreeBuilder->new_from_content($content);
        $s_time = time() - $s_time;

        my $main_cont = $page_tree->look_down('class' => 'clear whitebox');
        my $title = $main_cont->look_down('_tag' => 'h1');
#        print STDERR "Title: ", $title->as_text, "\n";
        $title->dump;
        my @dates = $title->right->look_down('_tag' => 'li');
#        print STDERR "Times ", join (", ", map { 
#            $_->look_down('_tag'=>'span')->right
#                                     } @dates), "\n";
        my @times = map {
            my $date_str = $_->look_down('_tag'=>'span')->right;
            print STDERR "date_str: '$date_str'\n";
            $date_str =~ s/\s/ /g;
            my $dt;
            my @errors;
            try {
                $dt = $formatter->parse_datetime($date_str);
            } catch {
                $errors[0] = $_;
                try {
                    $dt = $fmt_date->parse_datetime($date_str);
                } catch {
                    $errors[1] = $_;
                }
            };
            if (!$dt) {
                die "Can't parse date_str '$date_str': ".join("\n"), @errors;
            }
            print STDERR "parsed date: $dt\n";
            $dt;
        } @dates;
        my $image = $page_tree->look_down('class' => 'eventMainImage')->look_down('_tag' => 'img')->attr('src');
        

        my %event;
        $event{event_id} = $page_uri;
        $event{event_url} = $page_uri;
        $event{event_name} = $title->as_text;
        $event{image_url} = URI->new_abs($image, $event_link->attr('href'));
        $event{venue} = {
            name => 'Brunel Centre',
            street => '29a The Plaza',
            city => 'Swindon',
            zip => 'SN1 1LF',
            country => 'United Kingdom',
            other_names => [],
        };

        my $desc = '';
        for my $child ($main_cont->content_list) {
            if (ref $child and (
                    $child->tag eq 'h1' or                                                    # title
                    ($child->tag eq 'ul' and $child->attr('class') =~ /storeProfileTable/) or # times
                    ($child->tag eq 'a' and $child->attr('class') =~ m/backToList/)           # "back to list" link
                )) {
                next;
            }
            if (ref $child) {
                $desc .= $child->as_HTML;
            } else {
                $desc .= $child;
            }
        }
        $event{event_desc} = $desc;

        # my $desc = '';
        # my $p = $title->right->right;
        # while (ref $p && $p->tag eq 'p') {
        #     ## <p><u>Tuesday 25th August</u></p>
        #     if($p->look_down('_tag' => 'u') && $p->as_text =~ /\w+\s\d{1,2}\w{2}\s\w+/) {
        #         my $date_str = $p->as_text;
        #         $date_str =~ s/\s/ /g;
        #         $date_str =~ s/(\d{1,2})(th|nd|rd|st)/$1/;
        #         $date_str .= " " . $times[0]->year;
        #         print STDERR "Internal date: $date_str\n";
        #         my $date = $fmt_date->parse_datetime($date_str);
        #         $date->set_hour($times[0]->hour);
        #         $date->set_minute($times[0]->minute);
        #         $date->set_second(0);
        #         my $end = $date->clone;
        #         $end->set_hour($times[1]->hour);
        #         $end->set_minute($times[1]->minute);
        #         $end->set_second(0);
        #         push @{ $event{times} }, {
        #             start => $date,
        #             end => $end,
        #         };

        #         ## Skipping the description of day event..
        #         $p = $p->right->right;
        #         next;
        #     }

        #     $desc .= $p->as_text . ' ';
        #     $p = $p->right;
        # }
        # $event{event_desc} = $desc;

        if(!$event{times}) {
            my $start_time = $times[0]->clone;
            while($start_time <= $times[1]) {
                my $end_time = $start_time->clone;
                $end_time->set_hour($times[1]->hour);
                $end_time->set_minute($times[1]->minute);
                $end_time->set_second(0);
                push @{$event{times}}, {
                    start => $start_time,
                    end => $end_time,
                };
                $start_time = $start_time->clone->add(days => 1);
            }
        }

        push @events, \%event;
        sleep $s_time;
    }

#    print STDERR Data::Dumper::Dumper(\@events);

    return \@events;
}

1;
