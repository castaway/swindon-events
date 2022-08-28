package Event::Scraper::Website::SmallChange;

use strictures 1;

use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dumper;

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

    ## From base class
	state $known_venues = __PACKAGE__->venues();

    my $uri = $source_info->{uri};
    my $html = get($uri);
    my $tree = HTML::TreeBuilder->new_from_content($html);
    # 'start_time' => '28 Sep 2022 7:30 PM - 8:30 PM',
    my $dt_parser = DateTime::Format::Strptime->new(
        pattern => '%d %b %Y %I:%M %p',
        time_zone => 'Europe/London',
        on_error  => 'croak',
    );

    my @events;
    my @e_divs = $tree->look_down('class' => qr/talks/, '_tag' => 'div');
	foreach my $e_div (@e_divs) {
        my $date_div = $e_div->look_down(class => 'vsel-start-icon');
        my $time_div = $e_div->look_down(class => 'vsel-meta-time')->look_down('_tag' => 'span');
        my $loc_div = $e_div->look_down(class => 'vsel-meta-location');
        my $title_div = $e_div->look_down(class => 'vsel-meta-title');
        my $desc_div = $e_div->look_down(class => 'vsel-info');
        my $date_time_str = join(" ", map { $_->as_text() } ($date_div->content_list)) . " " . $time_div->as_text();
        $date_time_str =~ s/\s-\s(\d+):(\d+) ([AP]M)//;
        my ($end_hour, $end_min, $apm) = ($1, $2, $3);
        my $venue = $loc_div ? $loc_div->as_text() : '';
        $venue =~ s/^Location: //;
        print STDERR $venue, "\n";
        $venue = $venue ? $self->extract_venue($venue) : '';
        

        my %event = ();
        $event{event_name} = $title_div->as_text();
        $event{event_name} =~ s/^TALK \x{2013} //;
        $event{event_id} = $uri . $date_div->as_text() . $time_div->as_text();
        $event{times} = [ {
            start => $dt_parser->parse_datetime($date_time_str) }];
        $event{times}[0]{end} = $event{times}[0]{start}->clone;
        if ($apm =~ /pm/i) {
            $end_hour += 12;
        }
        $event{times}[0]{end}->set_hour($end_hour);
        $event{times}[0]{end}->set_minute($end_min);
        $event{event_desc} = $desc_div->as_text();
        $event{venue} = $venue;
        $event{event_url} = $uri;
        
        # print Dumper(\%event);
        push @events, \%event;
	}

    return \@events;
}

# perl -Ilib -MEvent::Scraper::Website::SwindonFestLiterature -MData::Dumper -le'my $events = Event::Scraper::Website::SwindonFestLiterature->get_events; print Dumper($events)' | less
