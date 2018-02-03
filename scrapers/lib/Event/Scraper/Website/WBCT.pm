package Event::Scraper::Website::WBCT;
# Wilts&Berks Canal Trust - Dragonfly trips etc

use strict;
use warnings;

use URI;
use LWP::Simple;
use HTML::TreeBuilder;
use DateTime;
use Time::ParseDate;
use Data::Dumper;

use base 'Event::Scraper::Website::Swindon';
# http://www.wbct.org.uk/home/full-calendar/month.calendar/2015/06/27/182%7C181%7C180%7C178%7C179
# 181 = boat trips
# 180 = events
# Joomla - too crazy??
# http://www.wbct.org.uk/boat-trips/schedule
my $top_uri = 'http://www.wbct.org.uk/boat-trips/schedule';

sub get_events {
    my ($self, $config) = @_;

    my $tree = HTML::TreeBuilder->new_from_content(get($top_uri));
    my $events_div = $tree->look_down('class' => 'jeventslatest jev_gray');

    my @event_links = $events_div->look_down('_tag' => 'a',
                                             class => 'jevdateiconmod'
    );

    my @events;
    foreach my $jevent (@event_links) {
        my ($year) = $jevent->attr('title') =~ /^(\d{4})/;
        $year ||= '';
        my $uri = $jevent->attr('href');
        $uri = URI->new_abs($uri, $top_uri);

        my $datetime = join('', map { $_->as_text } $jevent->right->look_down(class => 'mod_events_latest_date'));
        #    Saturday, 27th June, 10:30am3:00pm
        #    Sunday, 28th June, 10:30am3:00pm
        # Sunday, 26th June, 10:30am
        my ($date_str, $start_time, $last_time) = $datetime =~ 
            /[A-Z][a-z]+,\s(\d{1,2}(?:th|nd|rd|st)\s[A-Z][a-z]+),\s*(\d{1,2}:\d{2}am)(?:\s*(\d{1,2}:\d{2}pm))?/;
        ## Time::ParseDate wants Dow, DD Mon Year / or DD Month Year (!)
        $date_str =~ s/(\d)(?:th|nd|rd|st)/$1/;
        my $start_date = "${date_str} ${year} $start_time";
        my $epoch_start = parsedate($start_date);
        my $start = DateTime->from_epoch(epoch => $epoch_start);
        $start->set_time_zone('Europe/London');

        my $desc = $jevent->right->look_down(class => 'mod_events_latest_content')->look_down('_tag' => 'a')->as_text;

        my $event;
        $event->{event_id} = $uri;
        $event->{event_url} = $uri;
        $event->{event_name} = $desc;
        $event->{times}[0] = { start => $start };
        $event->{venue} = __PACKAGE__->find_venue($desc);

        push @events, $event;
    }

    return \@events;
}

1;
