package Event::Scraper::Website::EventBrite;
BEGIN {
    $HTML::Tagset::HTML_VERSION='v5';
};

use strict;
use warnings;

use LWP::Simple; 'get';
use HTML::TreeBuilder;
use DateTime::Format::Strptime;
use Time::ParseDate;
## for venues:
use base 'Event::Scraper::Website::Swindon';
 
my $start_url = 'https://www.eventbrite.co.uk/d/united-kingdom--swindon/all-events/';

sub get_events {
    my ($self, $config, $keyconf) = @_;

    my $page = get($start_url);
    my $tree = HTML::TreeBuilder->new_from_content($page);

    # Sat, Sep 24, 11:00
    my $parser = DateTime::Format::Strptime->new(
        pattern => "%a, %b %d, %R", 
        on_error => 'croak', 
        time_zone => 'Europe/London');


    my @events;
    my @articles = $tree->look_down(_tag => 'article');
    foreach my $article (@articles) {
        my $event = {};

        my $link = $article->look_down(_tag => 'a')->attr('href');
        my $title = $article->look_down(_tag => 'h3')->as_text;
        my $date_str = $article->look_down(class => qr/eds-event-card-content__sub-title/)->as_text;
        # print STDERR "$date_str\n";
        my ($epoch, $err) = parsedate($date_str, FUZZY => 1, PREFER_FUTURE => 1);
        if (!$epoch) {
            warn "Can't parse event time: $date_str\n";
            next;
        }
        # print STDERR "$epoch, $err\n";
        my $start_time = DateTime->from_epoch(epoch => $epoch);
        # print "$start_time\n";
#        my $start_time = $parser->parse_datetime($date_str);
        my $venue_str = ($article->look_down('class' => qr/eds-event-card-content__sub-content/)->content_list)[0];
        my $img_link = $article->look_down(_tag => 'img')->attr('src');
        
        $event->{event_name} = $title;
        $event->{event_desc} = '';
        $event->{event_id} = $event->{event_url} = $link;
        $event->{start_time} = $start_time;

        my $venue = __PACKAGE__->extract_venue($venue_str);
        $event->{image_url} = $img_link;

        push @events, $event;
    }

    # print Data::Dumper::Dumper(\@events);
    return \@events;
}

1;

