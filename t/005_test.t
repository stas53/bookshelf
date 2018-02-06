#!/usr/bin/perl
# 005_test.t
#
# /api test
#   PUT author: James Steinbeck France
#   GET authors
#   RETRIEVE ID of the last added author
#   PUT book of this author: The Grapefruits of Wrath
#   GET books
#   RETRIEVE ID of the last book added
#   GET this book (should contain 'Grapefruits')
#   PATCH Grapefruits -> Grapes
#   GET this book (should contain 'Grapes' and not contain 'Grapefruits')
#   GET author (should contain 'James' 'Steinbeck' 'France')
#   PATCH this author: John Steinbeck USA
#   GET author (should cotain 'John' 'Steinbeck' 'USA' and not contain 'James' 'France')
#   DELETE book
#   GET this book (should be empty)
#   DELETE author
#   GET all authors (should not contain 'Steinbeck')

use Plack::Test;
use Test::More;
use JSON::XS;
use HTTP::Request::Common qw/ GET POST DELETE PUT /;
use File::Spec;
use Data::Dumper;

                                                               # changes because test procedures
                                                               # read config differently than Dancer.
BEGIN {$ENV{DANCER_CONFDIR} = File::Spec->rel2abs('./');       # localization of config.yml
       $ENV{DANCER_VIEWS} = File::Spec->rel2abs('./views/');   # localization of templates
       push @INC, "./lib/";                                    # localization of modules
       }

use Booker qw/to_app/;


# --- Auxiliary functions

sub max_key_of_Json_coded_hash {
    my $hash_string = shift;
    my $hash = JSON::XS::decode_json($hash_string);
    return 0
        unless ( %$hash );
    return ( sort { $b <=> $a } keys %$hash )[0];
}

sub prepare_request {
    my $command = shift;
    my $url = shift;
    my $content = shift;
    my $req = POST $url,
       Content_Type => 'form-data',
       Content => $content;
    $req->{'_method'} = $command;
    return $req;
}

# --- main

$app = Booker->to_app;
test_psgi $app, sub {
    my $cb  = shift;
    my $res;

    $req = prepare_request('POST', '/api/authors', { forename => 'James',
                                                     surname => 'Steinbeck',
                                                     country => 'France' });
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/authors', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /$author_name/;
    my $last_author = max_key_of_Json_coded_hash($res->content);

    $req = prepare_request('POST', '/api/books', [ title => 'The Grapefruits of Wrath',
                                                   publ_date => '1935-03-01',
                                                   isbn => '76543-123-234-345',
                                                   author_id => $last_author ]);
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/books', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /$title1/;
    my $last_book = max_key_of_Json_coded_hash($res->content);
    
    $req = GET "/api/books/$last_book";
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /Grapefruits/;

    $req = prepare_request('PATCH', "/api/books/$last_book", [ title => 'The Grapes of Wrath' ]);
    $res = $cb->($req);
    is $res->code, 200;

    $req = GET "/api/books/$last_book";
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content !~ /Grapefruits/;
    ok $res->content =~ /Grapes/;

    $req = GET "/api/authors/$last_author";
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /James/;
    ok $res->content =~ /Steinbeck/;
    ok $res->content =~ /France/;

    $req = prepare_request('PATCH', "/api/authors/$last_author", [ forename => 'John',
                                                                   country => 'USA' ]);
    $res = $cb->($req);
    is $res->code, 200;

    $req = GET "/api/authors/$last_author";
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content !~ /James/;
    ok $res->content !~ /France/;
    ok $res->content =~ /John/;
    ok $res->content =~ /Steinbeck/;
    ok $res->content =~ /USA/;

    $req = DELETE "/api/books/$last_book";
    $res = $cb->($req);
    is $res->code, 200;

    $req = GET "/api/books/$last_book";
    $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "{}\n";
 
    $req = DELETE "/api/authors/$last_author";
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/authors', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content !~ /Steinbeck/;

};

done_testing();
