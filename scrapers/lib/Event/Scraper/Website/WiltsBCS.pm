package Event::Scraper::Website::WiltsBCS;

use strict;
use warnings;

use LWP::Simple;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;

use base 'Event::Scraper::Website::Swindon';

my $top_uri = 'http://www.wiltshirebcs.org/EventsFuture.asp';
my $event_uri = 'http://www.wiltshirebcs.org/EventFutureDetails.asp'; # ?EID=F3A901807B334ED49950CBBB92EA859F
my $dt_parser = DateTime::Format::Strptime->new(pattern => '%d/%m/%Y %l:%M%p',
                                                on_error => 'croak', 
                                                time_zone => 'Europe/London');

sub get_events {
    my ($self, $config) = @_;

    my $tree = HTML::TreeBuilder->new_from_content(get($top_uri));
    ## Each TR we care about has a hidden <input with name="EID"

    my @inputs = $tree->look_down('_tag' => 'input',
                                  name => 'EID'
    );

    my @events;
    foreach my $input (@inputs) {
        my @tds = $input->parent->parent->look_down('_tag' => 'td');
        my $event;

        $event->{event_id} = $event->{event_url} = 
            $event_uri . '?EID=' . $input->attr('value');
        $event->{event_name} = $tds[2]->as_text;
        ## eg: Main Hall, St Joseph's Catholic College
        $event->{venue} = __PACKAGE__->extract_venue($tds[4]->as_text);

        ## Need event page for time details:
        my $e_page = HTML::TreeBuilder->new_from_content(get($event->{event_url}));
        my @rows = $e_page->look_down('_tag' => 'tr',
                                      class => 'Controls'
        );
        my $start_date = $rows[1]->look_down(colspan => '3')->as_text;
        $start_date =~ s{[^\d/]}{}g;
        my $start_time = $rows[4]->look_down(colspan => '3')->as_text;
        $start_time =~ s{[^\d:AMP]}{}g;
#        print "$start_date $start_time\n";
        my $start = $dt_parser->parse_datetime("$start_date $start_time");
        my $end_time = $rows[6]->look_down(colspan => '3')->as_text; 
        $end_time =~ s{[^\d:AMP]}{}g;
#        print "$start_date $end_time\n";
        my $end = $dt_parser->parse_datetime("$start_date $end_time");
        ## NB: Should probably check if enddate (#2) is different to startdate
        $event->{times} = [ { start => $start, end => $end } ];

#        print Dumper($event);
        push @events, $event;
    }

    return \@events;
}

1;
