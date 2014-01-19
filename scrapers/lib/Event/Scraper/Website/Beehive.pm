package Event::Scraper::Website::Beehive;
$|=1;
use strictures 1;
use HTML::TreeBuilder;
use LWP::Simple 'get';
use DateTime;
#use DateTime::Event::Recurrence;
use Data::Dump::Streamer 'Dump', 'Dumper';
use Time::ParseDate;

sub get_events {
  my ($self, $source_info) = @_;

  my $url = $source_info->{page};

  my $html = get($url) or die "Couldn't get $url";
  my $root = HTML::TreeBuilder->new_from_content($html);
  
  my @ret;

  for my $table_tag ($root->look_down(_tag => 'table', 'width' => '85%')) {
    print "\n\n\n";

    my $event = {};

    $table_tag->dump;
    
    my $right_tag = $table_tag->look_down(bgcolor => '#CDEEFE');

    my $context = '?';
    for my $child ($right_tag->content_list) {
      my $t = ref $child ? $child->as_text : $child;

      print "c: $context, t: '$t'\n";

      if ($t =~ m/^\s*$/) {
        # noop
      } elsif ($t eq 'Band:') {
        $context = 'band_name';
      } elsif ($context eq 'band_name') {
        $event->{event_name} = $t;
        $context = '?';
      } elsif ($t eq 'Playing on:') {
        $context = 'date';
      } elsif ($context eq 'date') {
        if ($t =~ m/Last Sunday of every month 8pm/) {
          # We should probably just ignore this event.
          $event->{ignore_me}++;
        } else {
          
          # There is no use providing a month name (Jan) without providing a year. at lib/Event/Scraper/Website.pm line 58.
          () = <<'END';
          my $format = DateTime::Format::Strptime->new(
                                                       locale => 'en_GB',
                                                       time_zone => 'Europe/London',
                                                       # Friday Jan 10th 8.30pm
                                                       pattern => '%A %B %dth %l.%M%p',
                                                       on_error => 'croak',
                                                      );

          $format->parse_datetime($t);
END


          $t =~ s/(Saturday|Monday|Tuesday|Wednesday|Thursday|Friday|Sunday)//;
          $t =~ s/^\s+//;
          $t =~ s/(\d+)\.(\d\d)/$1:$2/;

          my ($epoch, $err) = parsedate($t, UK=>1, WHOLE=>0, VALIDATE=>1);
          if ($err) {
            die "could not parsedate $t: $err";
          }
          $event->{start_time} = DateTime->from_epoch(epoch => $epoch);
          $event->{start_time}->set_time_zone('Europe/London');
        }
        $context = 'desc';
      } elsif ($context eq 'desc') {
        $event->{event_desc} .= ref $child ? $child->as_HTML : $t;
      } else {
        die "Don't know what to do at context = '$context', t = '$t'";
      }
    }
    
    print Dumper($event);

    push @ret, $event;
  }

  return \@ret;
}

1;
