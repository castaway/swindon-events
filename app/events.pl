#!/usr/bin/env perl
package Events::Web;

use local::lib '/usr/src/perl/libs/events/perl5';
use Plack::Request;
use Plack::Middleware::Session;
use Plack::Session::State::Cookie;
use JSON;
use Template;
use Path::Class;
use Config::General;
use Web::Simple;
use LWP::UserAgent ();
use LWP::MediaTypes 'guess_media_type';
use Data::Dumper;
use DateTime;
use Time::ParseDate;
use Data::ICal;
use Data::ICal::Entry::Event;
#use Date::ICal;
use Data::ICal::DateTime;
use Geo::Distance;

use Encode;

use lib '/mnt/shared/projects/events/scrapers/lib', '/usr/src/events/scrapers/lib';
# Schema:
use lib '/mnt/shared/projects/events/lib', '/usr/src/events/lib';;
#use lib '/usr/src/perl/pubboards/lib'; 
use PubBoards::Schema;

has 'app_cwd' => ( is => 'ro', default => sub { ($ENV{EVENTS_HOME} || '/mnt/shared/projects/events') . '/app/'});
has 'scrapers' => ( is => 'ro', default => sub { ($ENV{EVENTS_HOME} || '/mnt/shared/projects/events') . '/scrapers/events.conf'});
#has 'static_url' => ( is => 'ro', default => sub {'http://192.168.42.2:7778'});
has 'host' => (is  => 'ro', default => sub {'https://swindonguide.org.uk' });
has 'base_uri' => (is  => 'ro', default => sub {''});
# has 'static_url' => ( is => 'ro', default => sub {'http://desert-island.me.uk/events/static'});
has 'static_url' => ( is => 'ro', default => sub {'https://swindonguide.org.uk/static'});
has 'oneall_domain' => ( is => 'ro', default => sub {'theswindonian.api.oneall.com'});
has 'oneall_publickey' => ( is => 'ro', default => sub {'7bfc3bbf-b462-4c7c-93aa-a0e2f5b25e5a'});
has 'oneall_privatekey' => ( is => 'ro', default => sub {'a1a8aa6f-7dcf-44c8-b0ec-83534533af48'});
has 'tt' => (is => 'ro', lazy => 1, builder => '_build_tt');

# location of train station according to Openstreetmap!
has 'centre' => ( is => 'ro',
                  lazy => 1,
                  default => sub {
                      my ($self) = @_;
                      return [
                          $self->config->{Setup}{centre}{lat},
                          $self->config->{Setup}{centre}{lng},
                          ];
                  } );
has 'geo_dist' => ( is => 'ro', default => sub { my $gd = Geo::Distance->new(); $gd->formula('mt'); $gd; } );

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
                     my $dbname = $self->config->{Setup}{dbname};
                     my $dbuser = $self->config->{Setup}{dbuser};
                     my $dbpass = $self->config->{Setup}{dbpass};

                     my $dsn = "dbi:$dbi:$dbname";

                     print "Trying to connect to dsn $dsn\n";

                     PubBoards::Schema->connect($dsn, $dbuser, $dbpass);
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
    sub (GET +/about) {
        my $sources = $self->config->{Source};

        return [ 200, [ 'Content-type', 'text/html' ], [
                     $self->tt_process('aboutpage.tt', 
                                       user => $user,
                                       sources => $sources) ] ];
    },
    sub (GET + /calendar/*/*) {
        my ($self, $year, $month) = @_;
        # print STDERR "Calendar: $year, $month\n";
        my $page = $self->get_monthpage($user, $events_rs, $year, $month);
        if($page) {
            return [ 200, [ 'Content-type', 'text/html' ], [ $page ] ];
        } else {
            return [ 404, [ 'Content-type', 'text/plain' ], [ 'No data for this month' ] ];
        }
    },
    sub (GET + /bootcal/*/*) {
        my ($self, $year, $month) = @_;
#        print STDERR "Calendar: $year, $month\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_bootmonthpage($user, $events_rs, $year, $month) ] ];
    },
    sub (GET + /all.ical) {
#        print STDERR "ICAL of events\n";
        return [ 200, [ 'Content-type', 'text/calendar' ], [ $self->get_ical($events_rs) ] ];
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
    sub (GET + /newposter) {
        return [200, ['Content-type', 'text/html' ], [ $self->get_newposterpage ] ];
    },
    sub (POST + /newposter + %:poster_url=&:owner~&:description~&:title~&:orig_date~&:tags~) {
        my ($self, $params) = @_;
        my %args = $self->check_args('newposter', %$params);

        if($args{url_image}) {
            $args{id} ||= $args{url_image};
            $args{source} = 'Submitted';
            $self->schema->resultset('Image')->create(\%args);
            return [ 302, [ 'Content-type', 'text/plain',
                            'Location', $self->host . $self->base_uri .  '/images' ] ];
        } else {
            return [ 200, [ 'Content-type', 'text/html' ],
                     [ $self->get_newposterpage((%$params, message => $args{message})  ) ] ];
        }
    },
    sub (GET + /images) {
        my $images = $self->schema->resultset('Image')->get_unprocessed_images();
        my @venues = $self->schema->resultset('Venue')->search({}, { order_by => {'-asc' => 'name'}})->all;
        if(@$images) {
            return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_boardpage($user, $images, \@venues) ] ];
        } else {
            return  [ 200, [ 'Content-type', 'text/plain' ], [ 'No images to process' ] ];
        }
    },
    sub (POST + /transcribe_image + %id=&venue~&event_name=&event_date=&start_time~&end_time~&processing_done~&event_weekly~) {
        my ($self, $image_id, $venue_name, $event_name, $event_date, $start_time, $end_time, $processing_done, $event_weekly) = @_;
        ## NB: $venue is the name, not an id.. these should be unique anywhey.. right??
        print STDERR "transcribe image: ", join("\n", $image_id, $venue_name, $event_name, $event_date, $start_time, $end_time), "\n";
        my $image = $self->schema->resultset('Image')->find({ id => $image_id });
        if(!$image || !$event_name || !$event_date) {
            return [ 404, [ 'Content-type', 'text/plain' ], [ 'No such image found' ] ];
        }

        my $start;
        if($start_time) {
            $start = $event_date . ' ' . $start_time;
            my $epoch = parsedate($start);
            $start = DateTime->from_epoch(epoch => $epoch, time_zone => 'Europe/London');
        }
        my $end_date;
        if($end_time) {
            $end_date = $event_date . ' ' . $end_time;
            my $epoch = parsedate($end_date);
            $end_date = DateTime->from_epoch(epoch => $epoch, time_zone => 'Europe/London');
        }
        my $venue;
        $self->schema->storage->txn_do( sub {
            if($venue_name) {
                $venue = $self->schema->resultset('Venue')->find_or_new({
                    name => $venue_name,
                });
                if(!$venue->in_storage) {
                    print STDERR "New venue: $venue_name\n";
                    $venue->id($self->schema->resultset('Venue')->next_id);
                    $venue->url_name($self->schema->resultset('Venue')->venue_url($venue));
                    $venue->insert();
                }
                $image->update({ venue => $venue });
            } else {
                $venue = $image->venue;
            }
            if($processing_done) {
                $image->update({ processed_on => DateTime->now });
            }

            $venue->create_related('events',{
                id => "image_transcription://$event_date",
                name => $event_name,
                times => [
                    { 
                        start_time => $start,
                        ( $end_date ? (end_time => $end_date) : () ),
                        time_key => "image_transcription://$event_date" . $start_time,
                    }
                ]
            });
        });

        return [ 302, [ 'Content-type', 'text/plain',
                        'Location', $self->host . $self->base_uri .  '/images' ] ];
    },
    sub (POST + /star_event + %event_id=) {
        ## Current logged-in user stars or unstars an event
        ## If not logged in then.. save in cookie/session anyway?
        my ($self, $event_id) = @_;

        print STDERR "Starring event: $event_id\n";
        my $result = {};
        if($user) {
            if($user->favourited($event_id)) {
                $user->favourites_rs->find({ event_id => $event_id})->delete;
                print STDERR "Deleted $event_id\n";
                $result->{star} = '&#9734;';
            } else {
                $user->favourites_rs->create({ event_id => $event_id });
                print STDERR "Added $event_id\n";
                $result->{star} = '&#9733;';
            }
        }
        
        return [ 200, [ 'Content-type', 'application/json' ], [ JSON::encode_json($result) ] ];
    },
    sub (POST + /hide_category + %month=&year=&@hide_category=) {
        my ($self, $month, $year, @categories) = @_;

        if($user) {
            
        }
    },
    sub (GET + /favourites) {
        my ($self) = @_;
        return [ 302, [ 'Content-type', 'text/plain',
                        'Location', $self->host . $self->base_uri .  '/' ], 
                 [ 'Login to see favourites' ] ] if !$user;

        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_favpage($user) ] ];
    },
    sub (GET + /favourites/ical + ?token=) {
        my ($self, $token) = @_;
        ## No check if logged in, returns calendar for user with token!
        ## otherwise hard to use for outside tools, eg google-calendar
        my $cal_user = $self->schema->resultset('User')->find({ user_token => $token } , { key => 'token' });
        print STDERR "Looking up $token\n";
        return [ 404, [ 'Content-type', 'text/plain' ],
                 [ 'No user found for that token' ] ] if !$cal_user;

        return [ 200, [ 'Content-type', 'text/calendar' ], [ $self->get_ical($events_rs, $cal_user) ] ];

    },
    sub (POST + /oneall_login_callback + %connection_token=) {
        my ($self, $conn_token) = @_;
        print STDERR "Conn token: $conn_token\n";

        if($conn_token) {
            my $user_token_uri = 'https://' . $self->oneall_publickey . ':' 
                . $self->oneall_privatekey . '@'
                . $self->oneall_domain . "/connections/${conn_token}.json" ;
            my $ua = LWP::UserAgent->new();
#            $ua->credentials($self->oneall_domain . ':80', '', $self->oneall_publickey, $self->oneall_privatekey );
            my $resp = $ua->get($user_token_uri);
            print STDERR "Token fetched: ", $resp->content, "\n";
            if(!$resp->is_success) {
                return [ 200, [ 'Content-type', 'text/plain' ], [ $resp->status_line ] ];
            }
            my $ut_json = $resp->decoded_content;
#            my $ut_json = LWP::Simple::get($user_token_uri);

            if($ut_json) {
                my $ut_result = JSON::decode_json($ut_json);
                if($ut_result->{response}{result}{status}{flag} eq 'error') {
                    return [ 303, [ 'Content-type', 'text/html', 
                                    'Location', $self->host . $self->base_uri .  '/' ],
                             [ 'Login failed' ] ];
                }
                ## should be "social_login" as its the result of a login call? always?
#                my $trans_type = $ut_result->{response}{result}{data}{plugin}{key};
                my $ext_user = $ut_result->{response}{result}{data}{user};
                my $user_token = $ext_user->{user_token};
                my $identity_token = $ext_user->{identity}{identity_token};
                my $user_name = $ext_user->{identity}{preferredUsername} || $ext_user->{identity}{id};
                my $provider = $ext_user->{identity}{provider};
                my $image_url = $ext_user->{identity}{pictureUrl};
                my $profile_url = $ext_user->{identity}{profileUrl};

                print STDERR Dumper($ut_result);
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

=head2 get_ical

Return calendar content representing the events resultset passed
in. If a user object is passed, only return events that user has
favourited.

=cut

sub get_ical {
    my ($self, $events_rs, $user) = @_;

    my $ical = Data::ICal->new();

    if($user) {
        $events_rs = $events_rs->search(
            {
                'starred_events.user_id' => $user->id,
            },
            {
                join => { 'times' => 'starred_events' },
            }
            );
    }

    while (my $event = $events_rs->next) {
        my $times_rs = $event->times_rs;
        while (my $time = $times_rs->next) {
            my $ical_event = Data::ICal::Entry::Event->new();
            $ical_event->add_properties(
                summary => $event->name,
                description => $event->description,
                dtstart => $time->start_time,
#                dtstart => Date::ICal->new( epoch => $time->start_time->epoch)->ical,
                );

            $ical_event->add_properties(location => join(' ', $event->venue->name//'(no name)', $event->venue->address//'(no address)'))
                if $event->venue;

            ## geo data is bork! it(the module?) backslashes the semi-colon
            $ical_event->add_properties(geo => join(";", ($event->venue->latitude, $event->venue->longitude)))
                if 0 and $event->venue && $event->venue->latitude;

            $ical_event->add_properties(url => $event->url)
                if ($event->url);
            
            $ical_event->add_properties(dtend => $time->end_time)
#            $ical_event->add_properties(dtend => Date::ICal->new( epoch => $time->end_time->epoch)->ical)
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

    print STDERR "get_monthpage: year=$year, month=$month";
    
    my $in_month = DateTime->now();
    if($month and $year and $month =~ /^\d{1,2}$/ and $month > 0 and $month <= 12
       and $year =~ /^\d{4}$/) {
        $in_month = DateTime->new(
            year => $year,
            month => $month,
            day => 1
            );
    }
    
    my $start_date = DateTime->new(year => $in_month->year,
                                   month => $in_month->month,
                                   day => 1,
        );
    my $end_date = $start_date->clone->add(months => 1);
    
    my $start = $dtf->format_datetime($start_date);
    my $end = $dtf->format_datetime($end_date);

    my $hide_cats = $user 
        ? $user->preferences()->{'hide_categories'} || [] 
        : [];

    my $times_rs = $schema->resultset('Time')->search(
        {
            'start_time' => {-between => [$start, $end]},
            ( @$hide_cats 
              ? ('event_categories.name' => { 'not-in' => $hide_cats })
              : ()
            ),
        },
        {
            prefetch => {'event' => ['venue', 'event_categories']},
            # order_by => [ {'-asc' => 'start_time'}],
        }
    );

    if(!$times_rs->count) {
        warn "No events for $year/$month";
        return;
    }
    my $next_month = $end_date->clone->add(days => 1);
    my $prev_month = $start_date->clone->subtract(days => 1);

    ## Check if we have events for previous/following months:
    my $next_mo_times = $schema->resultset('Time')->search(
        {
            'start_time' => {'-between' => [$end,
                                            $dtf->format_datetime($next_month)]},
        },
        {
            rows => 1,
        }
    )->count;
    my $prev_mo_times = $schema->resultset('Time')->search(
        {
            'start_time' => {'-between' => [$dtf->format_datetime($prev_month),
                                            $start] },
        },
        {
            rows => 1,
        }
    )->count;
    
    
    if($user) {$user = $self->schema->resultset('User')->find({id => $user->id}, { prefetch=> { favourites => 'event_time'} } ) };
    
    my $extra_nav = {
        ( $prev_mo_times ? ("< " . $prev_month->month_name => $self->base_uri 
            . '/calendar/' 
            . sprintf("%04d/%02d", 
                      $prev_month->year,
                      $prev_month->month),) : () ),
        ( $next_mo_times ? ( $next_month->month_name . ' >' => $self->base_uri 
            . '/calendar/' 
            . sprintf("%04d/%02d", 
                      $next_month->year,
                      $next_month->month), ):() ),
    };

    my $all_cats = $self->schema->resultset('EventCategories')->all_categories;
    
    return $self->tt_process('monthpage.tt',
                             user   => $user,
                             events => $times_rs->by_day,
                             start_date => $start_date,
                             extra_nav => $extra_nav,
                             categories => $all_cats,
        );
}

sub get_bootmonthpage {
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

    # $events_rs = $events_rs->search({
    #     'times.start_time' => {-between => [$start, $end]},
    #                                 },
    #                                 {
    #                                     prefetch => ['venue', { event_acts => 'act' }],
    #                                     join => 'times',
    #                                 });
    
#    my $json = to_json(\%events) or die "Couldn't to_json?";

    my $times_rs = $schema->resultset('Time')->search({
        'start_time' => {-between => [$start, $end]},
                                                      },
                                                      {
                                                          prefetch => {'event' => 'venue' },
#                                                          order_by => [ {'-asc' => 'start_time'}],
                                                      }
        );

    my $next_month = $end_date->clone->add(days => 1);
    my $prev_month = $start_date->clone->subtract(days => 1);

    if($user) {$user = $self->schema->resultset('User')->find({id => $user->id}, { prefetch=> { favourites => 'event_time'} } ) };

    my $extra_nav = {
        "< " . $prev_month->month_name => $self->base_uri 
            . '/bootcal/' 
            . sprintf("%04d/%02d", 
                      $prev_month->year,
                      $prev_month->month),
        $next_month->month_name . ' >' => $self->base_uri 
            . '/bootcal/' 
            . sprintf("%04d/%02d", 
                      $next_month->year,
                      $next_month->month),
    };
    
    return $self->tt_process('bootmonthpage.tt',
                             user   => $user,
                             events => $times_rs->by_day,
                             start_date => $start_date,
                             extra_nav => $extra_nav,
#                             prev_month => $prev_month,
#                             next_month => $next_month,
        );
}

sub get_venuepage {
    my ($self, $user, $venue, $page, $rows) = @_;
    $page ||= 1;
    $rows ||= 25;
    print STDERR "Venue: ", $venue->name, "\n";

    ## Restrict events shown, else we get them ALLL
    ## Paging?

    my $events = $venue->events_rs->search(
        {},
        { 
            page => $page, 
            rows => $rows,
        });
    
    return $self->tt_process('venuepage.tt', 
                             venue      => $venue,
                             events     => $events,
        );
}

sub get_favpage {
    my ($self, $user) = @_;

    return $self->tt_process(
        'favpage.tt',
        favs_by_day => $user->favourites_rs->related_resultset('event_time')->by_day,
        user => $user,
        );
}

sub get_boardpage {
    my ($self, $user, $images, $venues) = @_;

    $self->tt_process('boardpage.tt',
                      images => $images,
                      venues => $venues,
        );
}

sub get_newposterpage {
    my ($self, $poster_url, $owner, $desc, $title, $orig_date, $tags) = @_;

    $self->tt_process('newposterpage.tt',
                       (
                        poster_url => $poster_url,
                        owner => $owner,
                        description => $desc,
                        title => $title,
                        original_date => $orig_date,
                        tags => $tags,
                       )
        );
}

sub check_args {
    my ($self, $page, %args) = @_;

    if($page eq 'newposter') {
        my $type = guess_media_type($args{poster_url});
        if($type =~ /^image/) {
            return (
                url_image => $args{poster_url},
                owner => $args{owner} || 'Unknown',
                description => $args{desc} || '',
                title => $args{title} || undef,
                original_date => $args{orig_date} || DateTime->now,
                url_linkback => '',
                tags => $args{tags} || '',
                );                
        }
        return ( message => 'Please ensure the URL is to an image' );
    }
    return ();
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
    my ($self, $user, $extra) = @_;
    $extra ||= {};
    my $start_date = DateTime->now();

    my $wcal_host = $self->host;
    $wcal_host =~ s/^http/webcal/;

    return {
        'Jump to Today' => $self->host . $self->base_uri . '/calendar/' 
            . sprintf("%d/%02d#%s",
                      $start_date->year, $start_date->month,
                      $start_date->ymd),
#        'Latest Boards/Posters' => $self->host . $self->base_uri . '/images',
        ( $user ? ('Your Favourites' => $self->host . $self->base_uri . '/favourites' ) : () ),
        ( $user ? ('Your Calendar' => $wcal_host . $self->base_uri . '/favourites/ical?token=' . $user->user_token ) : () ),
        'About' => $self->base_uri . '/about',
        %$extra,
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
        ${$user_ref} = $self->schema->resultset('User')->find($uc, {prefetch => 'favourites'});
      }
      return;
    }
  );
}

sub ensure_session {
  my ($self) = @_;
  sub () {
    return if $_[PSGI_ENV]->{'psgix.session'};
    Plack::Middleware::Session->new(
        store => 'File',
        state => Plack::Session::State::Cookie->new(expires => 60*60*24*99),
        );
  }
}

## TT methods

sub calc_dist {
    my ($self, $lat, $lng) = @_;

    return 0 if !$lat || !$lng;
    return sprintf("%.1f", $self->geo_dist()->distance('mile', @{ $self->centre }, $lat, $lng));
}

sub tt_process {
    my ($self, $page, %vars) = @_;

    my $output;
    $self->tt->process($page, {
        static_uri => $self->static_url,
        host       => $self->host,
        base_uri   => $self->base_uri,
        nav_menu   => $self->nav_links($vars{user}, $vars{extra_nav} || {}),
        oneall_domain => $self->oneall_domain,
        calc_dist  => sub { $self->calc_dist(@_) },
        %vars,
                       }, \$output) || die $self->tt->error;

    $output = encode_utf8($output);
#    print STDERR "Homepage: $output\n";
    return $output;

}

Events::Web->run_if_script();
