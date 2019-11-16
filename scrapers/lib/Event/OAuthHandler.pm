package Event::OAuthHandler;

use Moo::Role;
use LWP::Authen::OAuth2;
use LWP::UserAgent;
use JSON qw/encode_json decode_json/;
use Future::Utils qw/repeat/;
use Try::Tiny;
#use Future::AsyncAwait;
use Data::Dumper;

# keyconf
sub authenticate {
    my ($self, $conf) = @_;
    
    # Create email/service combo on the oauth service (get back an id)
    my $ua = LWP::UserAgent->new();
    my $res = $ua->post('http://desert-island.me.uk/oauth/new',
                        Content => encode_json({ email => 'castaway@desert-island.me.uk', service => $self->service }) );

    if(!$res->is_success) {
        die $res->status_line;
    }

    my $new_id = $res->decoded_content();
    if(!$new_id || $new_id =~ /\D/) {
        die "Didn't get a new id from oauth/new!";
    }

    my $oauth2 = LWP::Authen::OAuth2->new(
        client_id => $conf->{client_id},
        client_secret => $conf->{client_secret},
        authorization_endpoint => $conf->{authorization_endpoint},
        token_endpoint => $conf->{token_endpoint},
        redirect_uri => "http://desert-island.me.uk/oauth/callback/$new_id",
        request_required_params => [qw/grant_type client_id client_secret code redirect_uri/],
        #scope => 'basic+ageless',
        );

    my $url = $oauth2->authorization_url();

    print "Auth: ", $self->service, " $url\n";

    # Lurk until user has visited url and dart has stored the code:
    my $now = time();
    my $code;
    my $f = repeat {
        sleep 1;
        my $f = Future->new();
        try {
            my $res = $ua->get("http://desert-island.me.uk/oauth/get/$new_id");
            #print $res->status_line, "\n";
            #print $res->content, "\n";

            if($res->code !~ /^[23]/) {
                #print "Fail ", $res->code, " ", $res->status_line, "\n";
                $f->fail('Error fetching user');
            } else {
                my $result = decode_json($res->decoded_content());
                $code = $result->{code};
                $f->done();
            }
        } catch {
            warn "UA error: $_";
        };
        return $f;
    } until => sub { $code || time()-$now > 60*10 };

    $f->get();

#print "Code:\n";
#my $code = <STDIN>;
#chomp $code;
    $oauth2->request_tokens(
        code => $code,
        redirect_uri => "http://desert-island.me.uk/oauth/callback/$new_id"
        );
    #print  $oauth2->token_string;
    return decode_json($oauth2->token_string)->{access_token};
}

1;


    

    
