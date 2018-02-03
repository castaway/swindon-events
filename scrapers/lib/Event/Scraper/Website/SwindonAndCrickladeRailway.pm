package Event::Scraper::Website::SwindonAndCrickladeRailway;
use strictures 1;
use HTML::TreeBuilder;
use LWP::Simple 'get';
use DateTime;

sub get_events {
  my ($self, $source_info) = @_;
  my $url = 'http://www.swindon-cricklade-railway.org/events.php';
  my $html = get($url) or die;
  my $tree = HTML::TreeBuilder->new_from_content($html);

  my $start = $tree->look_down(_tag => 'tr', sub {$_[0]->as_text =~ m/^\d+ Special Events/});

  my @events;

  my $context;
  my $tr = $start;
  while (1) {
    $tr = $tr->right;
    last if !$tr;

    my $event;

    my $count = $tr->content_list;
    if ($count == 0) {
      # Nothing Happens.
    } elsif ($count == 1) {
      # Month header row.
      $context = $tr->as_text;
    } elsif ($count == 3) {
      my $dow = $tr->address('.0')->as_text;
      my $dom = $tr->address('.1')->as_text;
      my $desc = $tr->address('.2');
      $event->{date_parseme} = "$dow $dom $context";
      if (ref $desc) {
        if ($desc->look_down(_tag => 'a')) {
          $event->{event_url} = URI->new_abs( $desc->look_down(_tag => 'a')->attr('href'),
                                              $url );
        }
        $event->{event_name} = $desc->address('.0');
        if (ref $event->{event_name}) {
          $event->{event_name} = $event->{event_name}->as_text;
        }
      } else {
        $event->{event_name} = $desc;
      }

      push @events, $event;
    } else {
      die "Don't know what to do with strange count=$count";
    }

  }

  return \@events;
}

'Is the pope catholic?';
