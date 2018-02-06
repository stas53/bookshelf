# 003_test.t
#
# simple WWW operation checking
# a piece of a "smoke test"

use Plack::Test;
use Test::More;
use HTTP::Request::Common;
use File::Spec;

                                                               # changes because test procedures
                                                               # read config differently than Dancer.
BEGIN {$ENV{DANCER_CONFDIR} = File::Spec->rel2abs('./');       # localization of config.yml
       $ENV{DANCER_VIEWS} = File::Spec->rel2abs('./views/');   # localization of templates
       push @INC, "./lib/";                                    # localization of modules
       }
 
use Booker qw/to_app/;

$app = Booker->to_app;
test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->(GET "/index");
    ok $res->content =~ /Please, select a View/;
    is $res->code, 200;
    $res = $cb->(GET "/authors/1");
    ok $res->content =~ /A bookworm exploring Dancer/;
    is $res->code, 200;
    $res = $cb->(GET "/authors");
    ok $res->content =~ /Switch to Books/;
    is $res->code, 200;
};

done_testing();
