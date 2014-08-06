#!/usr/bin/env perl
package Events::Web;

use local::lib '/usr/src/perl/libs/events/perl5';
use Plack::Request;
use Plack::Middleware::Session;
use JSON;
use Template;
use Path::Class;
use Config::General;
use Web::Simple;
use LWP::UserAgent ();
use Data::Dumper;
use DateTime;
use Data::ICal;
use Data::ICal::Entry::Event;
use Date::ICal;

use lib '/mnt/shared/projects/events/scrapers/lib';
use lib '/usr/src/perl/pubboards/lib';
use PubBoards::Schema;

has 'app_cwd' => ( is => 'ro', default => sub {'/mnt/shared/projects/events/app/'});
#has 'static_url' => ( is => 'ro', default => sub {'http://192.168.42.2:7778'});
has 'host' => (is  => 'ro', default => sub {'http://desert-island.me.uk' });
has 'base_uri' => (is  => 'ro', default => sub {'/events'});
has 'static_url' => ( is => 'ro', default => sub {'http://desert-island.me.uk/events/static'});
has 'oneall_domain' => ( is => 'ro', default => sub {'theswindonian.api.oneall.com'});
has 'oneall_publickey' => ( is => 'ro', default => sub {'7bfc3bbf-b462-4c7c-93aa-a0e2f5b25e5a'});
has 'oneall_privatekey' => ( is => 'ro', default => sub {'a1a8aa6f-7dcf-44c8-b0ec-83534533af48'});
has 'tt' => (is => 'ro', lazy => 1, builder => '_build_tt');
has 'config' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     +{Config::General->new($self->app_cwd."/../scrapers/events.conf")->getall};
                 });
has 'schema' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     my $dbi = $self->config->{Setup}{dbi};
                     my $dbfile = $self->config->{Setup}{dbfile};

                     my $dsn = "dbi:$dbi:$dbfile";

                     print "Trying to connect to dsn $dsn\n";

                     PubBoards::Schema->connect($dsn);
                 });

sub _build_tt {
    my ($self) = @_;

    return Template->new({ 
        INCLUDE_PATH => dir($self->app_cwd)->subdir('templates')->stringify,
                         });
}

sub dispatch_request {
    my ($self) = @_;

    my $user;

    my $events_rs = $self->get_events_rs();

    $self->check_authenticated($user),
    sub (GET + /) {
#        print STDERR "Index page\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_homepage($user, $events_rs) ] ];
    },
    sub (GET + /calendar/*/*) {
        my ($self, $year, $month) = @_;
#        print STDERR "Calendar: $year, $month\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_monthpage($user, $events_rs, $year, $month) ] ];
    },
    sub (GET + /all.ical) {
#        print STDERR "ICAL of events\n";
        return [ 200, [ 'Content-type', 'text/calendar' ], [ $self->get_ical($user, $events_rs) ] ];
    },
    sub (GET + /venue/*) {
        my ($self, $url_part) = @_;

        my $venue = $self->get_venue($url_part);
        if($venue) {
            return  [ 200, [ 'Content-type', 'text/html' ], [ $self->get_venuepage($user, $venue) ] ];
        } else {
            return  [ 404, [ 'Content-type', 'text/plain' ], [ 'No such venue' ] ];
        }
    },
    sub (GET + /images) {
        my $images = $self->get_unprocessed_images();
        if(@$images) {
            return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_boardpage($user, $images) ] ];
        } else {
            return  [ 200, [ 'Content-type', 'text/plain' ], [ 'No images to process' ] ];
        }
    },
    sub (POST + /oneall_login_callback + %connection_token=) {
        my ($self, $conn_token) = @_;

        if($conn_token) {
            my $user_token_uri = 'https://' . $self->oneall_publickey . ':' 
                . $self->oneall_privatekey . '@'
                . $self->oneall_domain . "/connections/${conn_token}.json" ;
            my $ua = LWP::UserAgent->new();
#            $ua->credentials($self->oneall_domain . ':80', '', $self->oneall_publickey, $self->oneall_privatekey );
            my $resp = $ua->get($user_token_uri);
            if(!$resp->is_success) {
                return [ 200, [ 'Content-type', 'text/plain' ], [ $resp->status_line ] ];
            }
            my $ut_json = $resp->decoded_content;
#            my $ut_json = LWP::Simple::get($user_token_uri);

            if($ut_json) {
                my $ut_result = JSON::decode_json($ut_json);
                ## should be "social_login" as its the result of a login call? always?
#                my $trans_type = $ut_result->{response}{result}{data}{plugin}{key};
                my $ext_user = $ut_result->{response}{result}{data}{user};
                my $user_token = $ext_user->{user_token};
                my $identity_token = $ext_user->{identity}{identity_token};
                my $user_name = $ext_user->{identity}{preferredUsername};
                my $provider = $ext_user->{identity}{provider};
                my $image_url = $ext_user->{identity}{pictureUrl};
                my $profile_url = $ext_user->{identity}{profileUrl};

                my $new_user = $self->make_or_update_user({
                    user_name => $user_name,
                    user_token => $user_token,
                    identity_token => $identity_token,
                    provider => $provider,
                    image_url => $image_url,
                    profile_url => $profile_url,
                                           });
                if(!$user) {
                    return ($self->set_authenticated($new_user),
                            [ 303, [ 'Content-type', 'text/html', 
                                     'Location', $self->host . $self->base_uri .  '/' ], 
                      [ 'Login succeeded, back to <a href="' . $self->host . $self->base_uri . '/' . '"></a>' ]]);
                }

                return [ 200, [ 'Content-type', 'text/plain' ], [ Dumper($ut_result) ] ];
            } else {
                return [ 200, [ 'Content-type', 'text/plain' ], ["No json returned from $user_token_uri"] ];
            }
        }
        $conn_token ||= '<No token>';
        return [ 200, [ 'Content-type', 'text/plain' ], [ 'Got token' . $conn_token ] ];
    },
    sub (GET + /logout) {
        my ($self) = @_;

        if($user) {
            $user = undef;
        }

        return ($self->logout,
                [ 303, [ 'Content-type', 'text/html', 
                         'Location', $self->host . $self->base_uri . '/' ], 
                      [ 'Logout succeeded, back to <a href="' . $self->host . $self->base_uri . '/' . '"></a>' ]]);
    },

}

sub get_venue {
    my ($self, $url_part) = @_;

    print STDERR "Part: $url_part\n";
    return $self->schema->resultset('Venue')->find({url_name => $url_part}, { key => 'url_name'});
}

sub get_events_rs {
    my ($self) = @_;

    my $events_rs = $self->schema->resultset('Event')->search(
        { 'times.start_time' => { "!=" => undef }}, 
        { prefetch => ['venue', 'times'] }
        );
}

sub get_ical {
    my ($self, $user, $events_rs) = @_;

    my $ical = Data::ICal->new();

    while (my $event = $events_rs->next) {
#        print STDERR "E\n";
        my $times_rs = $event->times_rs;
        while (my $time = $times_rs->next) {
#            print STDERR "T\n";
            my $ical_event = Data::ICal::Entry::Event->new();
            $ical_event->add_properties(
                summary => $event->name,
                description => $event->description,
                dtstart => Date::ICal->new( epoch => $time->start_time->epoch)->ical,
                );

            $ical_event->add_properties(location => join(' ', $event->venue->name//'(no name)', $event->venue->address//'(no address)'))
                if $event->venue;

            ## geo data is bork! it backslashes the semi-colon
            $ical_event->add_properties(geo => join(";", ($event->venue->latitude, $event->venue->longitude)))
                if 0 and $event->venue && $event->venue->latitude;

            $ical_event->add_properties(url => $event->url)
                if ($event->url);
            
            $ical_event->add_properties(dtend => Date::ICal->new( epoch => $time->end_time->epoch)->ical)
                if $time->get_column('end_time');
            
            $ical->add_entry($ical_event);
        }
    }
    return $ical->as_string;
}

sub get_homepage {
    my ($self, $user, $events_rs) = @_;

    my $now = DateTime->now();
    return $self->get_monthpage($user, $events_rs, $now->year, $now->month);
}

sub get_monthpage {
    my ($self, $user, $events_rs, $year, $month) = @_;
    my $output = '';

    my $schema = $self->schema;
    my $dtf = $schema->storage->datetime_parser;

    my $in_month = DateTime->now;
    $in_month->set( month => $month ) if($month && $month !~ /\D/);
    $in_month->set( year => $year ) if($year && $year !~ /\D/);
    
    my $start_date = DateTime->new(year => $in_month->year,
                                   month => $in_month->month,
                                   day => 1,
        );
    my $end_date = $start_date->clone->add(months => 1);
    
    my $start = $dtf->format_datetime($start_date);
    my $end = $dtf->format_datetime($end_date);

    $events_rs = $events_rs->search({
        'times.start_time' => {-between => [$start, $end]},
                                    },
                                    {
                                        prefetch => ['venue', { event_acts => 'act' }],
                                    });
    
#                                           order_by => [{ '-asc' => 'start_time' }],
#    my $json = to_json(\%events) or die "Couldn't to_json?";

    my $next_month = $end_date->clone->add(days => 1);
    my $prev_month = $start_date->clone->subtract(days => 1);

    return $self->tt_process('monthpage.tt',
                             user   => $user,
                             events => $events_rs->by_day,
                             start_date => $start_date,
                             prev_month => $prev_month,
                             next_month => $next_month,
        );
}

sub get_venuepage {
    my ($self, $user, $venue) = @_;

    print STDERR "Venue: ", $venue->name, "\n";

    return $self->tt_process('venuepage.tt', 
        venue      => $venue,
        );
}

sub get_unprocessed_images {
    my ($self) = @_;

    my $images_rs = $self->schema->resultset('Image')->search({
        processed_on => undef,
    },
    {
        order_by => { '-desc' => 'original_date' },
    });

    return [ $images_rs->all ];
}

sub get_boardpage {
    my ($self, $user, $images) = @_;

    $self->tt_process('boardpage.tt',
                      images => $images,
        );
}

sub make_or_update_user {
    my ($self, $user_stuff) = @_;

    ## Check if we already know this IT:
    my $social_rs = $self->schema->resultset('UserSocial');
    my $user_s = $social_rs->find({
        identity_token => $user_stuff->{identity_token},
                                  });
    ## Check if we know this user_token but by a different IT:
    my $main_user = $self->schema->resultset('User')->find({
        user_token => $user_stuff->{user_token},
                                                           });
    $main_user ||= {
                user_name => $user_stuff->{user_name},
                user_token => $user_stuff->{user_token},
                display_name => $user_stuff->{display_token} || '',
    };

    ## If unknown, create and link to user or create new user if also unknown:
    if(!$user_s) {
        $user_s = $social_rs->create({
            user_name => $user_stuff->{user_name},
            identity_token => $user_stuff->{identity_token},
            display_name => $user_stuff->{display_token},
            provider => $user_stuff->{provider},
            image_url => $user_stuff->{image_url},
            profile_url => $user_stuff->{profile_url},
            user => $main_user,
                           });
    }

    return $user_s->user;
    
}

sub nav_links {
    my ($self) = @_;
    return {
        'This month' => $self->base_uri . '/',
        'Latest Boards/Posters' => $self->base_uri . '/images',
#        'Venues' => '/venues',
    };
}

## Auth from http://sherlock.scsys.co.uk/~matthewt/auth-sketch2.txt
sub set_authenticated {
  my ($self, $user) = @_;
  my $uc = $user->ident_condition;
  return (
    $self->ensure_session,
    sub () { $_[PSGI_ENV]->{'psgix.session'}{'user_info'} = $uc; }
  );
}

sub logout { 
    my ($self) = @_;
    return (
        $self->ensure_session, 
        sub () { 
            print STDERR ref($_[PSGI_ENV]->{'psgix.session'});
            delete $_[PSGI_ENV]->{'psgix.session'}{user_info};
        }
    ); 
}

sub check_authenticated {
  my ($self) = @_;
  my $user_ref = \$_[1];
  return (
    $self->ensure_session,
    sub () {
      if (my $uc = $_[PSGI_ENV]->{'psgix.session'}{'user_info'}) {
        ${$user_ref} = $self->schema->resultset('User')->find($uc);
      }
      return;
    }
  );
}

sub ensure_session {
  my ($self) = @_;
  sub () {
    return if $_[PSGI_ENV]->{'psgix.session'};
    Plack::Middleware::Session->new(store => 'File');
  }
}


sub tt_process {
    my ($self, $page, %vars) = @_;

    my $output;
    $self->tt->process($page, {
        static_uri => $self->static_url,
        host       => $self->host,
        base_uri   => $self->base_uri,
        nav_menu   => $self->nav_links,
        oneall_domain => $self->oneall_domain,
        %vars,
                       }, \$output) || die $self->tt->error;

#    print STDERR "Homepage: $output\n";
    return $output;

}

Events::Web->run_if_script();
