#!/usr/bin/perl
use warnings;
use strict;
use local::lib '~/perl5';
use Daemon::Control;
my $path = "/usr/src/events/app";

exit Daemon::Control->new(
    name        => "SwindonGuideServer",
    lsb_start   => '$syslog $remote_fs',
    lsb_stop    => '$syslog',
    lsb_sdesc   => 'SwindonGuide Server',
    lsb_desc    => 'SwindonGuide Daemon controls the SwindonGuide Server.',
    path        => "$path/events_app_daemon.pl",
    directory   => "$path",
#    init_config => "$path etc/environment",
    user        => 'jess',
    group       => 'src',
    program     => "eval \$(perl -Mlocal::lib=/usr/src/perl/libs/events/perl5/) ; export EVENTS_HOME=/usr/src/events;  starman -l :7778 /usr/src/events/app/events.pl",
#    program_args => [ '-r', '-p 2366', "$path/messenger.pl" ],
    
    pid_file    => "$path/swindonguide_app.pid",
    stderr_file => '/tmp/swindonguide_server_err.out',
    stdout_file => '/tmp/swindonguide_server.out',
 
    fork        => 2,
 
    )->run;
