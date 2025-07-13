package Mobilizon::WebAPI::HAL;

use strict;
use warnings;
use v5.30;
use REST::Client;
use JSON;
use URI;
use Data::Dumper;
use MIME::Base64;

use Moo;

has user => (is => 'rw');
has pass => (is => 'rw');
has host => (is => 'rw');
has rc_client => (is => 'lazy',
                  default => sub {
                      my ($self) = @_;
                       my $client = REST::Client->new(
                           host => $self->host . 'webapi-dbic',
                           );

                      $client->addHeader('Content-Type', 'application/json'); # ActiveModel
                      # $rc_client->addHeader('Content-Type', 'application/hal+json'); # ActiveModel
                      # $rc_client->addHeader('Content-Type', 'application/vnd.api+json'); #JSON-API
                      # $rc_client->addHeader('Accept', 'application/vnd.api+json'); #JSON-API
                      $client->addHeader('Accept', 'application/hal+json'); #HAL+JSON
                      # print join('', split("\n", encode_base64("$webapi_user->{user}:$webapi_user->{pass}")));
                      $client->addHeader('Authorization', 'Basic ' . join('', split("\n", encode_base64(join(':', $self->user, $self->pass)))));
                      $client->setFollow(1);
                      push @{$client->getUseragent->requests_redirectable}, 'POST';
                       return $client;
                       
                  });
has actors => (is => 'rw', default => sub { []; });

sub get {
    my ($self, $path, %args) = @_;

    my @result = ();
    my $uri = URI->new($path);
    $uri->query_form_hash(\%args);
    
    my $res = decode_json($self->rc_client->GET($uri->as_string)->responseContent());
    push @result, @{$res->{_embedded}{$path}};
    while(scalar @result != $res->{_meta}{count}) {
        my $next_link = $res->{_links}{next}{href};
        $next_link =~ s{/webapi-dbic/}{};
        $res = decode_json($self->rc_client->GET($next_link)->responseContent());
        push @result, @{$res->{_embedded}{$path}};
    }
    return \@result;
}

sub post {
    my ($self, $path, $content) = @_;

    $self->rc_client->POST($path, encode_json($content));

    if($self->rc_client->responseCode() !~ /^20\d$/) {
        say "rc_client $path creation POST:";
        say $self->rc_client->responseCode();
        #        say Dumper($self->rc_headers);
        say $self->rc_client->responseContent();
        exit;
    } else {
        my $output = decode_json($self->rc_client->responseContent());
        say "New $path created", Data::Dumper::Dumper($output);
        return $output;
    }

    return;
}

sub find_actor {
    my ($self, $name) = @_;

    if(!@{$self->actors}) {
        my $actors = $self->get('actor', with => 'count');
        $self->actors($actors);
    }

    my ($actor) = grep { $_->{type} eq 'Person' && $_->{name} =~ /$name/ } @{$self->actors};

    return $actor;
}

sub find_group {
    my ($self, $name) = @_;

    if(!@{$self->actors}) {
        my $actors = $self->get('actor', with => 'count');
        $self->actors($actors);
    }

    my ($group) = grep { $_->{type} eq 'Group' && $_->{name} =~ /$name/ } @{$self->actors};

    return $group;
}

1;
