package Event::Scraper::Website::SwindonFestLiterature;

# use strictures 2;
use strict;
use warnings;

use LWP::Simple 'get';
use LWP::UserAgent;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';
use lib '/usr/src/events/HTML-Tagset/lib';
use HTML::TreeBuilder;

use base 'Event::Scraper::Website::Swindon';

$|=1;

binmode(STDERR, ':utf8');
binmode(STDOUT, ':utf8');

    my %ths = (
        1 => 'st',
        2 => 'nd',
        3 => 'rd',
        21 => 'st',
        22 => 'nd',
        23 => 'rd',
        31 => 'st' );

sub get_events {
	my ($self, $source_info) = @_;

    $DB::single=1;
    ## From base class
	state $known_venues = __PACKAGE__->venues();

	## Just look at all of May until we find em:
	my $page_date = DateTime->now()->set(month => 5, day => 1);
#	my $url_part = sprintf("%02d-%s", $page_date->day, lc($page_date->day_abbr));

    # 2021 has to be different.. https://www.swindonfestivalofliterature.co.uk/monday-3rd-may-2021
    my $url_part = sprintf("%s-%d%s-%s-%s",
                           lc($page_date->day_name),
                           $page_date->day,
                           $ths{$page_date->day},
                           lc($page_date->month_name),
                           $page_date->year);
	my $page_url = "http://www.swindonfestivalofliterature.co.uk/${url_part}";

	my $end_date = DateTime->new(year => $page_date->year,
                                 month => 6,
                                 day => 1)->subtract(days => 1);
    my @events;
	while($page_date <= $end_date) {
        print "Fetching $page_url\n";
		my $html = get($page_url);

        if ($html) {
            my $tree = HTML::TreeBuilder->new_from_content($html);

            # New layout 2025 - wix fun
            for my $section ($tree->look_down(_tag => 'section')) {
                my @event_section = $section->look_down(_tag => 'div', 'data-testid' => 'richTextElement');
                my $e = {};
                foreach my $e_section (@event_section) {
                    my @paras = $e_section->look_down(_tag => 'p');
                    next if !@paras;
                    my $p_parent = $paras[0]->parent;
                    print "Found entry?\n";
                    # First Paragraph is the event name:
                    $e->{event_name} = $paras[0]->as_text;
                    # Last one is the main description
                    $e->{event_desc} = $paras[-1]->as_text;
                    # Somewhere in here is an address and a date..
                    # going to have to guess where!
                    foreach my $p (@paras[1..$#paras-1]) {
                        my $text = $p->as_text;
                        if($text =~ /\sSN\d/) {
                            # hopefully an address!
                            $e->{venue_loc} = $text;
                        }
                        if($text =~ /\sMay\s~/) {
                            # hopefully a date
                            my ($hour, $minute, $ampm) = $text =~ /(\d{1,2})\.?(\d{1,2})?(pm|am)/;
                            $minute //= 0;
                            if (lc $ampm eq 'pm' && $hour < 12) {
                                $hour += 12;
                            }
                            my $start_time = $page_date->clone;
                            $start_time->set_time_zone('Europe/London');
                            $start_time->set_hour($hour);
                            $start_time->set_minute($minute || 0);
                            $e->{start_time} = $start_time;
                        }
                    }

                    if($e->{event_name} && $e->{event_name} ne $e->{event_desc}
                       && $e->{venue_loc} && $e->{start_time}) {
                        # The next div is the ticket link:
                        my $link_div = $p_parent->right;
                        if($link_div) {
                            my $a = $link_div->look_down(_tag =>'a');
                            if($a) {
                            $e->{event_ticket_url} = $a->attr('href');
                            }
                        }
                        # Then an image:
                        if($link_div) {
                            my $image_div = $link_div->right;
                            if($image_div) {
                                my $img = $image_div->look_down(_tag => 'img');
                                if($img) {
                                    $e->{image_link} = $img->attr('srcset');
                                }
                            }
                        }
                    } else {
                        next;
                    }
                }
                # next if($coloured_span->parent->tag ne 'p');
                # print "Found entry?\n";
                # # $coloured_span->parent->dump;
                # # name = ALL CAPS, desc - rest
                # my $e = {};                
                # my ($e_name, $e_desc) = $coloured_span->parent->as_text =~ /([A-Z\s]+)\s+.\s+(.*)/;
                # next if !$e_name;
                # $e->{event_name} = $e_name;
                # $e->{event_desc} = $e_desc;
                # my $id = $e_name;
                # $id =~ s/\W//g;
                # $e->{event_id} = $page_url . '#' . $id;
                # # Actual urls later?
                # $e->{event_url} = $page_url;

                # my @paras = $coloured_span->parent->right;
                # foreach my $p (@paras) {
                #     $e->{event_desc} .= $p->as_text;
                #     next if $e->{start_time};
                #     # $p->dump;
                #     # print "P: ", $p->as_text, "\n";
                #     my $maybe_time_str = $p->as_text;
                #     $maybe_time_str =~ s/midday/pm/;
                #     my ($hour, $minute, $ampm) = 
                #         $maybe_time_str =~ m/(\d+)\s*\.?(\d+)?(am|pm|noon)  # start time
                #         /xi;
                #     # or warn "Can't parse time-of-day '$maybe_time_str'";
                #     if($hour) {
                #         $minute //= 0;
                #         if (lc $ampm eq 'pm' && $hour < 12) {
                #             $hour += 12;
                #         }
                #         my $start_time = $page_date->clone;
                #         $start_time->set_time_zone('Europe/London');
                #         $start_time->set_hour($hour);
                #         $start_time->set_minute($minute);
                #         $e->{start_time} = $start_time;
                #     }
                # }
                # $e->{venue}{name} = 'Online event';
                # Dump($e);
                push @events, $e;
            }


#             for my $h2 ($tree->look_down(_tag => 'h2', sub {$_[0]->look_up(class => 'event')})) {
# #                print "h2 dump\n";
# #                $h2->dump;

#                 my $info_para = $h2->right;

#                 my $e = {};
#                 $e->{event_name} = $h2->as_text;
#                 my $id = $h2->look_up(id => qr/./)->attr('id');
#                 $e->{event_url} = $page_url . '#' . $id;
#                 $e->{event_id} = $e->{event_url};
#                 use utf8;
#                 my $date_str = $info_para->address('.4');
# #                my ($time, $date, $price) = split / • /, $info_para->address('.4');

#                 # 10am – 4pm 11 May £5 adult • £4 child
#                 # 12 noon 12 May £5
#                 # date month now optional, as missing from some subparts!
#                 my ($hour, $minute, $ampm, $end_hour, $end_min, $end_ampm, $day, $month, $price) = 
#                     $date_str =~ m/(\d+)\s*\.?(\d+)?(am|pm|noon)  # start time
#                               (?:\D+?(\d+)\.?(\d+)?(am|pm))? # - optional end time
#                               \D+?(\d+)?\s([A-Z]+)?          # date month
#                               (.*)                           # prices
#                               /xi
#                     or die "Can't parse time-of-day '$date_str'";
# #                my ($hour, $minute, $ampm, $end_hour, $end_min, $end_ampm) = $time =~ m/(\d+)\.?(\d+)?(am|pm)(?:\D+(\d+)\.?(\d+)?(am|pm))?/i
# #                    or die "Can't parse time-of-day '$time'";
#                 $minute //= 0;
#                 $end_min //= 0;
#                 if (lc $ampm eq 'pm' && $hour < 12) {
#                     $hour += 12;
#                 }
#                 if ($end_ampm && lc $end_ampm eq 'pm' && $end_hour < 12) {
#                     $end_hour += 12;
#                 }
#                 # '5 May'
# #                my ($day, $month) = $date =~ m/(\d+) ([A-Z]+)/i or die "Can't parse date '$date'";
#                 $day ||= $page_date->day;
#                 $month = $page_date->month_name;
                    
#                 die "Huh date: $date_str" if $month ne 'May';
                                
#                 $e->{start_time} = DateTime->new(year => $page_date->year,
#                                                  month => $page_date->month,
#                                                  day => $day,
#                                                  hour => $hour,
#                                                  minute => $minute,
#                                                  second => 0,
#                                                  time_zone => 'Europe/London',
#                                                  locale => 'en_GB',
#                     );
#                 $e->{tz_hint} = 'Europe/London';
#                 if($end_hour) {
#                     $e->{end_time} = DateTime->new(year => $page_date->year,
#                                                    month => $page_date->month,
#                                                    day => $day,
#                                                    hour => $end_hour,
#                                                    minute => $end_min,
#                                                    second => 0,
#                                                    time_zone => 'Europe/London',
#                                                    locale => 'en_GB',
#                     );
#                 }                    
#                 my $venue = $info_para->address('.0');
                
#                 my ($venue_name) = split(/,/, $venue);

#                 if (!$known_venues->{$venue_name} && !__PACKAGE__->find_venue($venue_name)) {
#                     die "Don't know details for venue '$venue_name' (from '$venue')";
#                 }
#                 $e->{venue} = $known_venues->{$venue_name} || __PACKAGE__->find_venue($venue_name);

                
# #                Dump($e)->Freezer('DateTime', 'iso8601')->Out();

#                push @events, $e;
        }

		$page_date->add(days => 1);
        $url_part = sprintf("%s-%d%s-%s-%s",
                           lc($page_date->day_name),
                           $page_date->day,
                           $ths{$page_date->day} || 'th',
                           lc($page_date->month_name),
                           $page_date->year);
		$page_url = "http://www.swindonfestivalofliterature.co.uk/${url_part}";
    }

    return \@events;
}

# perl -Ilib -MEvent::Scraper::Website::SwindonFestLiterature -MData::Dumper -le'my $events = Event::Scraper::Website::SwindonFestLiterature->get_events; print Dumper($events)' | less
