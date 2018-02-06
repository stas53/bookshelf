# 004_test.t
#
# /api test
#   ADD author
#   RETRIEVE ID of the last added author
#   ADD book of this author
#   RETRIEVE ID of the last book added
#   ADD another book of this author
#   RETRIEVE ID of the last book added
#   GET author (should contain both books)
#   DELETE first book
#   GET first book (should return empty structure)
#   GET all books (should contain the title of the second book but not of the first one)
#   DELETE second book
#   GET all books (should contain no second book title)
#   DELETE author

use Plack::Test;
use Test::More;
use JSON::XS;
use HTTP::Request::Common qw/ GET POST DELETE PUT /;
use File::Spec;

                                                               # changes because test procedures
                                                               # read config differently than Dancer.
BEGIN {$ENV{DANCER_CONFDIR} = File::Spec->rel2abs('./');       # localization of config.yml
       $ENV{DANCER_VIEWS} = File::Spec->rel2abs('./views/');   # localization of templates
       push @INC, "./lib/";                                    # localization of modules
       }

use Booker qw/to_app/;

# --- Test data

my $author_name = 'Winston C';
my $title1 = 'First C Book';
my $title2 = 'Second C Book';

my $author_data = [ forename => $author_name,
                    surname => 'Smith',
                    country => 'USA',
                  ];

my $first_book_data = [ title => $title1,
                        publ_date => '2001-03-01',
                        isbn => '123-234-345'
                      ];

my $second_book_data = [ title => $title2,
                         publ_date => '2001-03-02',
                         isbn => '22-23-234-345'
                       ];

                       
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

    $req = prepare_request('POST', '/api/authors', $author_data);
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/authors', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /$author_name/;
    my $last_author = max_key_of_Json_coded_hash($res->content);

    $req = prepare_request('POST', '/api/books', [ @$first_book_data, author_id => $last_author ]);
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/books', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /$title1/;
    my $last_book1 = max_key_of_Json_coded_hash($res->content);
    
    $req = prepare_request('POST', '/api/books', [ @$second_book_data, author_id => $last_author ]);
    $res = $cb->($req);
    is $res->code, 200;

    $req = prepare_request('GET', '/api/books', []);
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content =~ /$title1/;
    ok $res->content =~ /$title2/;
    my $last_book2 = max_key_of_Json_coded_hash($res->content);
    $req = DELETE "/api/books/$last_book1";
    $res = $cb->($req);
    is $res->code, 200;

    $req = GET "/api/books/$last_book1";
    $res = $cb->($req);
    is $res->code, 200;
    is $res->content, "{}\n";
 
    $req = GET '/api/books';
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content !~ /$title1/;
    ok $res->content =~ /$title2/;
       
    $req = DELETE "/api/books/$last_book2";
    $res = $cb->($req);
    is $res->code, 200;

    $req = GET '/api/books';
    $res = $cb->($req);
    is $res->code, 200;
    ok $res->content !~ /$title2/;
 
    $req = DELETE "/api/authors/$last_author";
    $res = $cb->($req);
    is $res->code, 200;

};

done_testing();
