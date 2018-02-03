package Event::Scraper::Facebook;
use strictures 1;
use Facebook::Graph;
use DateTime;
use DateTime::Format::HTTP;
use feature 'state';
use Data::Dump::Streamer 'Dump', 'Dumper';
use base 'Event::Scraper::Website::Swindon';
$|=1;

my $fbg;

sub get_events {
  # user id may also be a page id.  We treat them just the same.
  my ($self, $source_info, $keyconf) = @_;
  my %keys = $keyconf->getall();
  my $user_id = $source_info->{page_id};

  if (!$fbg) {
      $fbg = Facebook::Graph->new(app_id => '1414208068886457',
                                secret => 'a333d8306f17d56d9b584feef414e141',
                                postback => 'http://desert-island.me.uk/events/fb/this-will-404/',
                               );
#    $fbg = Facebook::Graph->new(app_id => '570027493079452',
#                                secret => '609e2628de0a41caf38285a985c6cfce',
#                                postback => 'http://desert-island.me.uk/this-will-404/',
#                               );

    # Right.  So if it seems to be unauthorized, that means that the
    # auth timed out, copy-and-paste the URL listed as "auth uri", and
    # then copy-and-paste the "code" parameter of the url you get
    # redirected to into the request_access_token line.

    # Then, copy-and-paste the access_token in.

# perl -Ilib -MEvent::Scraper::Facebook -MData::Dumper -le'my $events = Event::Scraper::Facebook->get_events; print Dumper($events)' | less

    print "Auth uri: ", $fbg->authorize->uri_as_string, "&response_type=token\n";
# http://desert-island.me.uk/this-will-404/?code=AQAwnczGywRH7oEc0u_FxijlJC39VgFtef5jhhq7wAVFXARtaE6BtfboAVBo0TDYCMaVqMQhqhXDP9_KtWhzls7RR9I6TIBYrOS_nsafGQyshYnqYyIiA21smJRcF8vd7lDiS2X2gVszs6tRrhk8nYmXlhxQ6Yy38L

#      $fbg->access_token('EAAUGNvmVn7kBANeoMS5Kvj5ECVZA0HhIKwSqZBc4pG3KT3lYSWbiGfa3kEnNj4Ln9odGL90ZA88n0BhXlpq6H9pll47zfe3ZAZCZCm67JWTITqCxSml9ZABKC2pZBLv2Nv0U8xBhzZBmnsjULRYu4JIHM');
      # GET graph.facebook.com/debug_token?input_token={token-to-inspect}&access_token={app-token-or-admin-token}
#      print STDERR "Token: ", Data::Dumper::Dumper(\%keys);
      $fbg->access_token($keys{'Keys'}{'Facebook'}{'access_token'});
      $fbg->request_extended_access_token();
      $keys{'Keys'}{'Facebook'}{'access_token'} = $fbg->access_token();
      $keyconf->save_file(($keyconf->files())[0], \%keys);
    Dump $fbg;
  }

  my @ret;

  my $last6mo = DateTime->now()->subtract(months => 2);
  my $req = $fbg->query->find("$user_id/events")->where_since($last6mo->ymd);
# limit_results(10);
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
  my $fb_event = $fbg->query->find($event_id)->
      select_fields(qw/id name description place owner start_time end_time ticket_uri timezone updated_time/)->request->as_hashref;
  print "From FB: ", Dumper($fb_event);

  my $st = $fb_event->{start_time};
  $st =~ s{\+\d{4}$}{};
  $ret->{start_time} = DateTime::Format::HTTP->parse_datetime($st, $fb_event->{timezone});
  $ret->{start_time}->set_time_zone($fb_event->{timezone}) if $fb_event->{timezone};
  if($ret->{start_time} < $today) {
      return ();
  }
  if($fb_event->{end_time}) { 
      my $et = $fb_event->{end_time};
      $et =~ s{\+\d{4}$}{};
      $ret->{end_time} = DateTime::Format::HTTP->parse_datetime($et, $fb_event->{timezone});
      $ret->{end_time}->set_time_zone($fb_event->{timezone}) if $fb_event->{timezone};      
  }
  if(!$fb_event->{place}{name} || $fb_event->{place}{name} eq 'Swindon') {
      warn "Can't figure out location of event: $event_id";
      return ();
  }

  $ret->{event_desc} = $fb_event->{description};
  $ret->{event_id} = "fb:" . $event_id;
  $ret->{event_url} = "https://www.facebook.com/" . $event_id;
  $ret->{event_name} = $fb_event->{name};
  $ret->{owner_id} = "fb:" . $fb_event->{owner}{id};
  $ret->{owner_name} = $fb_event->{owner}{name};
#  $ret->{tz_hint} = $fb_event->{timezone};
  my $ut = $fb_event->{updated_time};
  $ut =~ s{\+\d{4}$}{};
  $ret->{updated_time} = DateTime::Format::HTTP->parse_datetime($ut);

  ## Attempt to normalise venues:
  my $sw_venue = __PACKAGE__->find_venue($fb_event->{place}{name});
  $sw_venue ||= __PACKAGE__->find_venue($fb_event->{owner}{name});
  
  $ret->{venue} = $sw_venue || $fb_event->{place}{location};
  $ret->{venue}{name} ||= $fb_event->{place}{name};
  $ret->{venue}{url} ||= '';

#  print "expanded: ", Dumper($ret);

  return $ret;
}

1;
