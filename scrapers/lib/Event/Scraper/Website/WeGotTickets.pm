package Event::Scraper::Website::WeGotTickets;
use strictures 1;
use LWP::Simple 'get';
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DateTime::Format::Strptime;
use feature 'state';
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';

sub get_events {
    my ($self, $source_info) = @_;

    my $html = get($source_info->{uri});
    my $tree = HTML::TreeBuilder->new_from_content($html);
#    $tree->objectify_text;
    $tree->dump;

    my $events;
    state $formatter = DateTime::Format::Strptime->new(pattern => "%A %d %B, %Y", on_error => 'croak', time_zone => 'Europe/London');
    for my $listing ($tree->look_down(class => qr/ListingFullWidth/)) {
        print STDERR $listing->as_HTML;
        my $l_date = $listing->look_down(class => qr/ListingDate/);
#        next if(!$l_date);
        my $group = $listing->look_down(class => qr/listingInfoGroup/);
        print STDERR "Grp:"; $group->dump;
        my @bits = $group->content_list;
        # for (@bits) {
        #     print "BIT: ";
        #     ref $_ ? $_->dump : print $_;
        # }
        my $a;
        until (ref $a && $a->attr('href')) { $a = shift @bits};
        $a = $a->look_down(_tag => 'a');
        my $l_url = $a->attr('href');
        my $l_name = $a->as_text;
        my $l_price = shift @bits;
        my $desc = '';
        for( @bits ) {
            $desc .= ref $_ ? $_->as_text : $_;
        }

        $l_date = $l_date->as_text;
        $l_date =~ s/(\d)(?:th|st|rd|nd)/$1/;
        print STDERR "Date: ", $l_date, "\n";
        my $e_date = $formatter->parse_datetime($l_date);
        print STDERR "Date: ", $e_date->ymd;
        my $event = {
            venue => __PACKAGE__->venues->{'Town Gardens'},
            event_name => $l_name,
            event_desc => $desc,
            event_id => $l_url,
            event_url => $l_url,
            start_time => $formatter->parse_datetime($l_date),
        };
        Dump($event);
        push @$events, $event;
    }

    return $events;
}

1;
