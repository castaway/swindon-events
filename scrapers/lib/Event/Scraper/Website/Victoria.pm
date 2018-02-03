# -*- perl; tab-width: 2 -*-
package Event::Scraper::Website::Victoria;
$|=1;
use strictures 1;
use HTML::TreeBuilder;
use LWP::Simple 'get';
use DateTime;
#use DateTime::Event::Recurrence;
use Data::Dump::Streamer 'Dump', 'Dumper';
use DateTime::Format::Strptime;

use feature 'state';


sub get_events {
  my ($self, $source_info) = @_;

  my $url = $source_info->{uri};

  my $html = get($url) or die "Couldn't get $url";
  my $root = HTML::TreeBuilder->new_from_content($html);
  
  my @ret;
  #$root->dump;
  
  my $top_tag = $root->look_down(_tag => 'div', 'id' => 'giggity');
  for my $child ($top_tag->content_list) {
      next if $child->attr('_tag') eq 'p';
#      $child->dump;

      # @0.1.0.5.0.1.0 : top_tag
      # @0.1.0.5.0.1.0.0.0.0 : image x
      # @0.1.0.5.0.1.0.0.1.0.0 : date
      # @0.1.0.5.0.1.0.0.1.1.0 : name x
      # @0.1.0.5.0.1.0.1.0 : desc x
      # @0.1.0.5.0.1.0.2.1.0 : band website? <-
      # @0.1.0.5.0.1.0.3.1.0 : start (doors open) time
      # @0.1.0.5.0.1.0.4.1.0 : price (needs second-level parsing) <-
      # FIXME: Some have a tickets link.
      
      my $event;
      $event->{image} = $child->address('.0.0.0')->attr('src');
      $event->{image} = URI->new_abs($event->{image}, $url);
      $event->{event_name} = $child->address('.0.1.1.0')->as_text;
      $event->{event_desc} = join ('', map {ref $_ ? $_->as_HTML : $_}
				   $child->address('.1.0')->content_list);
      if ($child->address('.0.2.1.0')) {
          my @websites = $child->address('.0.2.1.0')->look_down(_tag => 'a');
          
          $event->{event_url} =  @websites ? $websites[0]->attr('href') : $url;
      }
      $event->{event_url} ||= $url;
      $event->{event_url} = URI->new_abs($event->{event_url}, $url);

      ## This is currently required for the auto-eventid assignment... boo!
      $event->{start_time} = $self->get_times($child->address('.0.1.0.0')->as_text,
                                              $child->address('.3.1.0'  )->as_text)->[0]{start};
#      $event->{times} = $self->get_times($child->address('.0.1.0.0')->as_text,
#                                         $child->address('.3.1.0'  )->as_text);
      $event->{venue} = { 
          name => 'The Victoria',
          street => '88 Victoria Road',
          zip => 'SN1 3BD',
          country => 'United Kingdom',
      };
      push @ret, $event;
  }
  return \@ret;
}

sub get_times {
    my ($self, $date_str, $time_str) = @_;


    my $input = "${date_str} ${time_str}";
    $input =~ s/(\d+)(th|nd|rd|st)/$1/;
    $input =~ s/\s+/ /g;
    
    my $dt_parser;
    $dt_parser ||= DateTime::Format::Strptime->new(pattern => "%A %e %B %Y %H:%M",
						   on_error => sub {
						       my ($self, $errmsg) = @_;
						       die "Can't parse $input: $errmsg";
						   },
	);

    my $dt = $dt_parser->parse_datetime($input);
    
    ## We assume things end at closing time..
    return [{ start => $dt, end => $dt->clone->set_hour(23)}];
}

__END__
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
