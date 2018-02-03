package Event::Scraper::Website::SwindonDoesArts;
#use strictures 1;
use strict;
use warnings;
use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::Microdata;
use DateTime;
use Time::ParseDate;
#use DateTime::Format::Strptime;
#use feature 'state';
use Data::Printer;

use Event::Scraper::Website::SchemaOrg;

use base 'Event::Scraper::Website::Swindon';

$|=1;

#my $top_uri = 'http://www.swindondoesarts.co.uk/listings/events/?network[0]=6';

# Start 

sub get_events {
    my ($self, $source_info) = @_;

    my @ret;

    my $page = get($source_info->{uri});

    # ?network[0]=6&month=3&day=22&page=X
    # default is "upcoming" (eg March-May)

    $HTML::Tagset::isHeadOrBodyElement{meta} = 1;
    $HTML::Tagset::isHeadElement{meta} = undef;

    my $page_num = 0;
    while ($page && $page_num < 10) {
#        print $page;
        next if !$page;
        my $tree = HTML::TreeBuilder->new_from_content($page);
#        $tree->dump;
        my @events = Event::Scraper::Website::SchemaOrg::parse_schema
            ($tree,
             event_name => { _tag => 'h3'},
             event_desc => { _tag => 'p'},
            );

#         my @event_rows = $tree
#             ->look_down('_tag' => 'table',
#                         class => 'directoryList')
#             ->look_down('_tag' => 'tbody')
#             ->look_down('_tag' => 'tr');

#         foreach my $e_row (@event_rows) {
#             my $event = {};
#             my $link = $e_row->look_down('_tag' => 'a');
#             my $desc = $e_row->look_down('class' => 'events')->look_down('_tag' => 'p');
#             my $image_uri = $e_row->look_down('class' => 'events')->look_down('_tag' => 'img')->attr('src');
#             my $e_dates = $e_row->look_down('class' => 'centre'); # ->look_down('_tag', 'span');
#             my $uri = $link->attr('href');
#             $uri = URI->new_abs($uri, $source_info->{uri});
#             $image_uri = URI->new_abs($image_uri, $source_info->{uri});
#             $event->{event_id} = "$uri";
#             $event->{event_url} = "$uri";
#             $event->{event_name} = $link->as_text;
#             $event->{event_desc} = $desc->as_text;
#             $event->{image_url} = "$image_uri";

#             print "Date: >", $_->as_text, "<\n" for $e_dates;
#             my $dates = get_dates($e_dates->as_text);
#             $event->{times}[0] = $dates;

#             print "Event: $event->{event_name}\n";
#             $event = { %$event, get_eventpage_data($uri) };
# #            $event->{venue} = get_venue($uri);
#             $event->{venue} ||= __PACKAGE__->extract_venue($event->{event_desc});
#             if(!$event->{venue}) {
#                 warn "Still no venue in $event->{event_desc}\n";
#             }

            push @ret, @events;

            sleep 1;
        #}

        $page_num++;
        $page = get("$source_info->{uri}&page=$page_num");
    }

    # Temp testing gubbins
    p @ret;

#    return [];
    
    return \@ret;
}

sub get_dates {
    my ($string) = @_;

    ## Sat 28th Mar 2015
    ## Wed 1st to Fri 3rd Apr 2015 (3 days)
    ## Wed 4th Mar to Thu 7th May 2015 (2 months)
    ## Fri 26th Jun 2015 to Sun 26th Jun 2016 (1 year)

    my ($start_str, $end_str, $duration, $dur_type) = $string
        ##    Wed 1st               Mar             to    Fri  3rd                Apr   2015   (    3     days )
        =~ /^(\w+ \d+(?:th|nd|st|rd)(?:\s\w+)?(?:\s\d{4})?)?(?: to )?(\w+ \d+(?:th|nd|st|rd) \w{3} \d{4})\s*(?:\((-?\d+) (days?|weeks?|months?|years?)\))?$/;

    print STDERR "Parsed: $string, Got: $start_str, $end_str, $duration, $dur_type\n";

    if(!$end_str) {
        my $start_date = DateTime->from_epoch(epoch => get_datetime($start_str), time_zone => 'Europe/London');
        return { start => $start_date };
    }
    my $end_date = DateTime->from_epoch(epoch => get_datetime($end_str), time_zone => 'Europe/London');
    my $start_date = $end_date;
    if($duration) {
        $dur_type =~ s/s?$/s/;
        $start_date = $end_date->clone->subtract($dur_type => $duration);
    }
    if($start_date > $end_date) {
        ($start_date, $end_date) = ($end_date, $start_date);
    }

    return { start => $start_date, end => $end_date };
}

sub get_datetime {
    my ($string) = @_;

    $string =~ s/(Saturday|Monday|Tuesday|Wednesday|Thursday|Friday|Sunday|Sat |Mon |Tue |Wed |Thu |Fri |Sun )//;
    $string =~ s/^\s+//;
    my ($day, $mon, $year) = $string =~ /^(\d+)(?:th|nd|st|rd) (\w+) (\d+)$/;
#    $string =~ s/(\d+)\.(\d\d)/$1:$2/;
    
    my ($epoch, $err) = parsedate("$day $mon $year", UK=>1, WHOLE=>0, VALIDATE=>1, PREFER_FUTURE=>1);
    if ($err) {
        die "could not parsedate $string: $err";
    }

    return $epoch;
}

## Sadly the venues are only on the actual event page:
sub get_eventpage_data {
    my ($event_uri) = @_;

    my $event_cont = get($event_uri);
    my $tree = HTML::TreeBuilder->new_from_content($event_cont);

#    $tree->dump;
    my $loc_h2 = $tree->look_down(id => 'location');
    my $venue = undef;
    if(!$loc_h2) {
        warn "No location id!\n";
    } else {
        my $loc_name = $loc_h2->right->look_down('_tag', 'h3');
        if($loc_name) {
            $loc_name = $loc_name->as_text;
            $venue = __PACKAGE__->find_venue($loc_name);
            
            if(!$venue) {
                warn "Can't find venue for $loc_name\n";
            }
        } else {
            warn "No h3 for event\n";
            $loc_h2->dump;
        }
    }

    ## get full desc:
    my $profiles = $tree->look_down('id' => 'profile');
    my @full_desc = $profiles->look_down('_tag' => 'p', class => undef);
    
    
    
    return ( venue => $venue, (@full_desc ? (event_desc => join('', map { $_->as_text } @full_desc )) : () ) );
#    return $venue;
}

1;
