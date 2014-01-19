package Event::Scraper::Facebook;
use strictures 1;
use Facebook::Graph;
use DateTime;
use DateTime::Format::ISO8601;
use Data::Dump::Streamer 'Dump', 'Dumper';
$|=1;

my $fbg;

sub get_events {
  # user id may also be a page id.  We treat them just the same.
  my ($self, $source_info) = @_;

  my $user_id = $source_info->{page_id};

  if (!$fbg) {
    $fbg = Facebook::Graph->new(app_id => '570027493079452',
                                secret => '609e2628de0a41caf38285a985c6cfce',
                                postback => 'http://desert-island.me.uk/this-will-404/',
                               );

    # Right.  So if it seems to be unauthorized, that means that the
    # auth timed out, copy-and-paste the URL listed as "auth uri", and
    # then copy-and-paste the "code" parameter of the url you get
    # redirected to into the request_access_token line.

    # Then, copy-and-paste the access_token in.

    print "Auth uri: ", $fbg->authorize->uri_as_string, "\n";

#    $fbg->request_access_token('AQBie2XH5nlQ4vSnXdXrZNpb45M1ujG7dgEvaYzGSOjnIE0WCh8QQ-3h4BYFjmtZpOMfXkLxUPTO-OjfT2Y9KaaHOQWGe-0SbYS5s3d9L-VPYvlV2WWw-3r9c8LeQS374cosvexj0PodDD9fLALjB710YvKdFy7HLkut-zuJb1MBUnRvIVEp8joi7Cudjl7bHNt7Fe6hzdfYf5XL7jhjREmQbFYWpfncPUoOk8vwBXFvqLbtzw-KWE9cQ6Tu5my17RY_Nu6zAp_8-o1HxD7iZEtrJmUtCprhcx-4DtDB_Ayt7XyDjzxlEdgA6ltAbYz7XFo');

    $fbg->access_token('CAAIGb948uZAwBADA4LeAwOcAzWnNZAG9hxkNJKSp9StJzfVEkTJ1S02QqbJhKb1nZAcJPDIxgHTfjke47mGkk0U2F91ON7C8MJMPty23Sq1GTFpcNSZAPq5sKCTu3PCLjNR1zmBENZAaSisZAU4ErcxKUT2sIRuFfPg4jdFirIPcrEkuXTUWoO');

    #Dump $fbg;
  }

  my @ret;

  my $req = $fbg->query->find("$user_id/events")->limit_results(10);
  print $req->uri_as_string, "\n";
  my $events = $req->request->as_hashref;
  Dump $events;

  #my @event_ids = ($events->{data}[0]{id});

  push @ret, map {$self->expand_event($_->{id})} @{$events->{data}};

  my $next_url = $events->{paging}{next};

  while ($next_url) {
    my $events = $fbg->request($next_url)->as_hashref;
#    Dump $events;
    $next_url = $events->{paging}{next};
    push @ret, map {$self->expand_event($_->{id})} @{$events->{data}};
    last if @ret >= 25;
  }

  return \@ret;
}

sub expand_event {
  my ($self, $event_id) = @_;

  print "eid: $event_id\n";

  my $ret = {};
  my $fb_event = $fbg->query->find($event_id)->request->as_hashref;
#  print "From FB: ", Dumper($fb_event);

  $ret->{event_desc} = $fb_event->{description};
  $ret->{event_id} = "fb:" . $event_id;
  $ret->{event_url} = "https://www.facebook.com/" . $event_id;
  $ret->{venue_name} = $fb_event->{location};
  $ret->{event_name} = $fb_event->{name};
  $ret->{owner_id} = "fb:" . $fb_event->{owner}{id};
  $ret->{owner_name} = $fb_event->{owner}{name};
  my $st = $fb_event->{start_time};
  $st =~ s{\+\d{4}$}{};
  $ret->{start_time} = DateTime::Format::ISO8601->parse_datetime($st);
  $ret->{tz_hint} = $fb_event->{timezone};
  my $ut = $fb_event->{start_time};
  $ut =~ s{\+\d{4}$}{};
  $ret->{updated_time} = DateTime::Format::ISO8601->parse_datetime($ut);
  $ret->{venue_loc} = $fb_event->{venue};
  $ret->{venue_loc}{name} = $ret->{venue_name};

#  print "expanded: ", Dumper($ret);

  return $ret;
}

1;
