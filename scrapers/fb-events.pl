#!/usr/bin/perl
use strictures 1;
use Facebook::Graph;
use URI;
use URI::QueryParam;
use Data::Dump::Streamer;

my $fbg = Facebook::Graph->new;

$fbg->access_token('CAACEdEose0cBAJLgq6J5reC3B3FttXcbDAfv2jZCBcS9xLqHvZALawyvgVUoRZA3FugkPMZBzgLYmfBVjZBJBtSyAb0i17KyM4DvSoF1ewNDVRbI963uGp72987ihu9i1pz5ZBfJEqYtiJPAXLKP4lC5IpJkZCBNsWZAOqW9CMYfdiQlnZCmVOv2z9uBhrxlv7NU6jXXwWjZA9JwZDZD');
#$fbg->access_token('CAACEdEose0cBAOvgPLbItcFhAvYDmorAuBd3UZCqKSa8Svxp5QFJ6R8YfKuVwdnlY4R21LIuPlAbABNQZBFUndJtzr744RMaJXlw74I7pdYB1lpbRGUnisg6omUnXk6fFHU5W4s9em4PoWaNdF4nwFZCaNsRRYqSDlBeIZBvdzAQ9TlkwEBDELNcMpbqpmUZD');

# status promotions
my $user = '397590460346226';
# status promotions at the rolly.
#my $user = '357999137646307';

# user id, status promotions
#my $events = $fbg->query->request("https://graph.facebook.com/$user/events")->as_hashref;
my $req = $fbg->query->find("$user/events")->limit_results(10);
print $req->uri_as_string, "\n";
my $events = $req->request->as_hashref;
Dump $events;

my @event_ids = ($events->{data}[0]{id});
my $next_url = $events->{paging}{next};

while ($next_url) {
#  my $q = $fbg->query;
#  $q->uri($next_url);
  my $events = $fbg->request($next_url)->as_hashref;
  Dump $events;
  $next_url = $events->{paging}{next};
  push @event_ids, map {$_->{id}} @{$events->{data}};
  last if @event_ids >= 25;
}

for my $event_id (@event_ids) {
  print "eid: $event_id\n";

  my $ret = {};

  my $fb_event = $fbg->query->find($event_id)->request->as_hashref;

  Dump $fb_event;

  exit;
}
