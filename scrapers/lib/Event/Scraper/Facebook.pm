package Event::Scraper::Facebook;
use strictures 1;
use Facebook::Graph;
use DateTime;
use DateTime::Format::ISO8601;
use feature 'state';
use Data::Dump::Streamer 'Dump', 'Dumper';
use base 'Event::Scraper::Website::Swindon';
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

# perl -Ilib -MEvent::Scraper::Facebook -MData::Dumper -le'my $events = Event::Scraper::Facebook->get_events; print Dumper($events)' | less

#    print "Auth uri: ", $fbg->authorize->uri_as_string, "\n";
# http://desert-island.me.uk/this-will-404/?code=AQBdFQHI10zquwfKzVRZhc41XuIhDbCcpedIGVM6U3q8Cn0cp-r4j6dhNJrMqQ73vZb4kaTrGgK6XowlLOcp3dMrQhDxEbTOT5UYPSRK-M1nfrJQDrySnV3YHUHRm1dQ6FY_XQe5O2RuyOJXuLcu7UpzwFK_t3F_PzXFdrnYLOJ_hNtD-QK8Erso1nFSUzPkk6u2WiEm17apIbHNimpjMmFhVFxmhNUv4LfUOO6GYLFmmBI0UQ3q7RuvS377C8YUmD19K_WZCpQumzvTdPMG0YDX3owb67HdzcB9LrP1uFcQEXlHJDT_zJGq8QS421OyarE#_=_
#    $fbg->request_access_token('AQCUdh1po37RhilQ69kXYlhPrCHT6ECOfK1VgxnIpn7q7Ii-pZIlmczjJHTho1HZG5OUcHZTX4lMKy-VainsUSdBvTksylvdhLx6AKIe8XaajEvlYZStkobwYk8wTX6kk-rd17rq7imDMN_BWrE_aWCnez84OQwk-dZ1aN7KMni2LDu1Llzkw6JrSj5RYAP9zSafVb4GVO0tq8kGuYfnO6J586FqEG9kyohwv1s1-ZKIFTJY7keYcPp9VP2wJxXr-3C6roV3pdagn8YkcpCqC0bRyt-oXxyk50hoMzCFPjdvC64KTjGBPeRI7sET1or1jPw');

    $fbg->access_token('CAAIGb948uZAwBAEqtBHm7iaPto5ebbHZBcdVEmVtZAFrVrLEYTZB7p9AqhrCa4eVFw0b1MiSxzxnUdkxlZAb4ZAAW3n9y1PBKNDPp3jbvVTUUoSRZC2ZCl1G6RaG7Qs0Jv4YK4tKFLHkIaVfwZBc7R4vBtq94y45KAd6AuIZAZA0bZAYKHOv2t5zIVcOQHxmtFBM56D5i6yhL2mZCJ5oRxoNzrFHJ');

#    Dump $fbg;
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

  state $today = DateTime->now();
  print "eid: $event_id\n";

  my $ret = {};
  my $fb_event = $fbg->query->find($event_id)->request->as_hashref;
#  print "From FB: ", Dumper($fb_event);

  my $st = $fb_event->{start_time};
  $st =~ s{\+\d{4}$}{};
  $ret->{start_time} = DateTime::Format::ISO8601->parse_datetime($st);
  if($ret->{start_time} < $today) {
      return ();
  }
  if(!$fb_event->{location} || $fb_event->{location} eq 'Swindon') {
      warn "Can't figure out location of event: $event_id";
      return ();
  }

  $ret->{event_desc} = $fb_event->{description};
  $ret->{event_id} = "fb:" . $event_id;
  $ret->{event_url} = "https://www.facebook.com/" . $event_id;
  $ret->{event_name} = $fb_event->{name};
  $ret->{owner_id} = "fb:" . $fb_event->{owner}{id};
  $ret->{owner_name} = $fb_event->{owner}{name};
  $ret->{tz_hint} = $fb_event->{timezone};
  my $ut = $fb_event->{start_time};
  $ut =~ s{\+\d{4}$}{};
  $ret->{updated_time} = DateTime::Format::ISO8601->parse_datetime($ut);

  ## Attempt to normalise venues:
  my $sw_venue = __PACKAGE__->find_venue($fb_event->{location});
  
  $ret->{venue} = $sw_venue || $fb_event->{venue};
  $ret->{venue}{name} ||= $fb_event->{location};

#  print "expanded: ", Dumper($ret);

  return $ret;
}

1;
