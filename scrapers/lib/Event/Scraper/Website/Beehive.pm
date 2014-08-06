# -*- perl; tab-width: 2 -*-
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

  Dump($source_info);
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
          my $now = DateTime->now();
          my $dt = DateTime->last_day_of_month(year => $now->year,
                                               month => $now->month);
          while($dt->day_name !~ /Sunday/) {
            $dt = $dt->subtract(days => 1);
          }
          $event->{times}[0]{start} = $dt;
        } else {

          my $t_start = $t;
          my $t_end;
          if($t =~ /-/) {
            ($t_start, $t_end) = split(/-/, $t);
          }

          my $start_dt = DateTime->from_epoch(epoch => get_datetime($t_start));
          push @{$event->{times}}, { start => $start_dt };
          $event->{times}[-1]{start}->set_time_zone('Europe/London');
          if($t_end) {
            my $end_dt = DateTime->from_epoch(epoch => get_datetime($t_end));
            while($start_dt <= $end_dt) {
              $start_dt = $start_dt->clone->add(days => 1);
              push @{$event->{times}}, { start => $start_dt };
              $event->{times}[-1]{start}->set_time_zone('Europe/London');
            }
          }
          $event->{start_time} = $event->{times}[0]{start};
        }
        $context = 'desc';
      } elsif ($context eq 'desc') {
        $event->{event_desc} .= ref $child ? $child->as_HTML : $t;
      } else {
        die "Don't know what to do at context = '$context', t = '$t'";
      }
    }
    
    $event->{url} = $url;
    print Dumper($event);

    push @ret, $event;
  }

  return \@ret;
}

sub get_datetime {
    my ($string) = @_;

    $string =~ s/(Saturday|Monday|Tuesday|Wednesday|Thursday|Friday|Sunday)//;
    $string =~ s/^\s+//;
    $string =~ s/(\d+)\.(\d\d)/$1:$2/;
    
    my ($epoch, $err) = parsedate($string, UK=>1, WHOLE=>0, VALIDATE=>1);
    if ($err) {
        die "could not parsedate $string: $err";
    }

    return $epoch;
}

1;
