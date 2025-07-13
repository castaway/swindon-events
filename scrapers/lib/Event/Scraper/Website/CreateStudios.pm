package Event::Scraper::Website::CreateStudios;

use strictures 1;
use LWP::Simple 'get';
use LWP::UserAgent;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';
use lib '/usr/src/events/HTML-Tagset/lib';
use HTML::TreeBuilder;

use base 'Event::Scraper::Website::Swindon';

my $ua = LWP::UserAgent->new();

sub get_events {
    my ($self, $source_info) = @_;

    my $events = [];
    
	state $known_venues = __PACKAGE__->venues();
    my $cs_venue = __PACKAGE__->find_venue('Create Studios');

    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 SwindonGuide');
    my $resp = $ua->get($source_info->{url});
    my $html;
    if($resp->is_success) {
        #my $html = get($source_info->{url});
        $html = $resp->decoded_content;
    } else {
        print $resp->status_line;
        return [];
    }
    my $tree = HTML::TreeBuilder->new_from_content($html);

    my @event_elements = $tree->look_down(_tag => 'article', class => qr/event-type-screening/);
    my $dt_formatter = DateTime::Format::Strptime->new(
        pattern => '%Y%n%B%n%d%n%l:%M%n%p',
        #           2025     May     24     7:00   pm
        #           %Y  %n   %B %n   %d %n  %l:%M  %n %p
        on_error => 'undef',
        time_zone => 'Europe/London'
    );
    my $now = DateTime->now();
    foreach my $ele (@event_elements) {
        my %event = ();
        my $title_ref = $ele->look_down(_tag => 'h3', class => qr/post-title/);
        $event{event_name} = $title_ref->as_text();
        my $url_ref = $ele->look_down(_tag => 'a', class => qr/permalink/);
        $event{event_url} = $url_ref->attr('href');
        $event{event_id} = $url_ref->attr('href');
        my @month_refs = map { $_->as_text } $ele->look_down(_tag => 'span', class => qr/event-month/);
        my @time_refs = map { $_->as_text  } $ele->look_down(_tag => 'span', class => qr/event-time/);

        my @times;
        for(my $ind = 0; $ind < scalar @month_refs; $ind++) {
            my $time_str = $now->year . " $month_refs[$ind] $time_refs[$ind]";
            my $start_time = $dt_formatter->parse_datetime($time_str);
            if(!$start_time) {
                warn $dt_formatter->errmsg;
            } else {
                push @times, { start => $start_time };
            }
        }
        $event{times} = \@times;
        $resp = $ua->get($event{event_url});
        my $page_html;
        if($resp->is_success) {
            $page_html = $resp->decoded_content();
        } else {
            warn $resp->status_line;
            next;
        }

        my $page_tree = HTML::TreeBuilder->new_from_content($page_html);
        my @page_art_ref = $page_tree->look_down(_tag => 'article');
        my @desc;
        foreach my $a_ele (@page_art_ref) {
            push @desc, $_->as_text for $a_ele->look_down(_tag => 'p'); 
        }

        my $image_w_ref = $page_tree->look_down(_tag => 'div', class => qr/image-wrapper/);
        my $image_ref = $image_w_ref->look_down(_tag => 'img');
        $resp = $ua->get($image_ref->attr('data-src'));

        # store the actual data !
        # extract file ending / convert from type somehow?
        $event{event_image} = {
            url => $image_ref->attr('data-src'),
            width => $image_ref->attr('width')+0,
            height => $image_ref->attr('height')+0,
            type => $resp->header('Content-Type'),
            size  => $resp->header('Content-Length'),
        };

        $event{event_desc} = join("\n\n", @desc);
        $event{venue} = $cs_venue;
        sleep 1;

        push @$events, \%event;
    }

    return $events;
}
1;
