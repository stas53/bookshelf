#!/usr/bin/perl
# Booker.pm
# part of "bookshelf"
#
# Simple Dancer application
# Books and Authors
#
# Constructed after git://github.com/PerlDancer/dancer-tutorial.git
# Thanks, bigpresh !

package Booker;

use Dancer;
use DBI;
use File::Spec;
use File::Slurp;
use Template;
BEGIN { push @INC, "./lib/", '/views/', './lib/Bookshell/Schema/Result'; }
use Bookshell::Schema;
use DBIx::Class::Row qw/get_columns/;
use Data::Dumper;

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'username'     => 'admin';
set 'password'     => 'password';
set 'layout'       => 'main';
 
my $flash;
 
sub set_flash {
       my $message = shift;
 
       $flash = $message;
}
 
sub get_flash {
 
       my $msg = $flash;
       $flash = "";
 
       return $msg;
}

sub hash_ids_sorted_by_field {
    my $hash = shift;
    my $field = shift;
    my @keys = keys %$hash;
    my @sorted_keys = sort { $hash->{$a}->{$field} cmp $hash->{$b}->{$field} } @keys;
    return \@sorted_keys;
}

sub error_in_params {
    my $message = shift;
    return { status => 'err', result => { message => $message } };
}

sub db_schema {
    my $dbconf = config->{'plugins'}->{'Database'}->{'bookshelf'};
    return Bookshell::Schema->connect('dbi:' . $dbconf->{'driver'} . ':dbname=' . $dbconf->{'database'},
                                      $dbconf->{'username'},
                                      $dbconf->{'password'} );
}

sub collect_params {
    return { map { param($_) ? ( $_ => param($_) ) : ()
                 } @_
           };
}

sub books_extended {
    my $is_for_display = shift;
    my $book_id = shift;
    my $schema = db_schema();
    my $book_rs = $schema->resultset('Book');
    $book_rs = $book_rs->search({ book_id => $book_id },)
        if $book_id;
    my $book_ext_rs = $schema->resultset('BookAuthor')
                             ->search_related('author');
    my $bd = { map { $_->book_id => { $_->get_columns,
                                      author => [ map { { $_->get_columns
                                                        } } $book_ext_rs->search({book_id => $_->book_id})->all ]
                                    }
                   } $book_rs->all };
    if ( $is_for_display ) {
        foreach my $bbo ( values %$bd ) {
            $bbo->{'author'} = join('; ', map{ $_->{'forename'} . ' ' . $_->{'surname'}
                                             } @{$bbo->{'author'}})
        }
    }
    return $bd;
}


sub authors_extended {
    my $is_for_display = shift;
    my $author_id = shift;
    my $schema = db_schema();
    my $author_rs = $schema->resultset('Author');
    $author_rs = $author_rs->search({ author_id => $author_id },)
        if $author_id;
    my $book_ext_rs = $schema->resultset('BookAuthor')
                             ->search_related('book');
    my $bd = { map { $_->author_id => { $_->get_columns,
                                        book => [ map { { $_->get_columns
                                                      } } $book_ext_rs->search({author_id => $_->author_id})->all ],
                                      }
                   } $author_rs->all };
    if ( $is_for_display ) {
        foreach my $bbo ( values %$bd ) {
            $bbo->{'book'} = join('; ', map{ $_->{'title'}
                                             } @{$bbo->{'book'}})
        }
    }
    return $bd;
}


hook before_template => sub {
        my $tokens = shift;
        # TODO in future ...
        # $tokens->{'css_url'} = request->base . 'css/style.css';
        # $tokens->{'login_url'} = uri_for('/login');
        # $tokens->{'logout_url'} = uri_for('/logout');
};
 
any ['get', 'post'] => '/index' => sub {
 
    template 'index.tt', {
               'msg' => get_flash(),
               'add_entry_url' => uri_for('/add'),
               'begin_url' => uri_for('/'),
               'authors_url' => uri_for('/authors'),
               'books_url' => uri_for('/books'),
    };
};

any ['get', 'post'] => '/' => sub {
       redirect '/index';
};

any ['get', 'post'] => '/authors' => sub {
    my $for_display = 1;
    my $bd = authors_extended($for_display);
    my $ids_in_order = hash_ids_sorted_by_field($bd, 'surname');
    template 'browse_authors.tt', {
               'msg' => get_flash(),
               'detail_author_prefix_url' => uri_for('/authors/'),
               'begin_url' => uri_for('/'),
               'authors_url' => uri_for('/authors'),
               'books_url' => uri_for('/books'),
               'entries' => $bd,
               ids_in_order => $ids_in_order
    };
};

any ['get', 'post'] => '/authors/' => sub {
       return redirect '/authors';
};

any ['get', 'post'] => '/authors/:author_id' => sub {
    my $author_id = param 'author_id';
    return error_in_params("Bad author ID given in /authors/$author_id")
        unless ( $author_id =~ /^\d+$/ )  and  $author_id > 0;
    my $for_display = 1;
    my $entry = authors_extended($for_display, $author_id)->{$author_id};
    $entry->{'author_id'} = $author_id;
    template 'edit_author.tt', {
               'msg' => get_flash(),
               'detail_author_prefix_url' => uri_for('/author/'),
               'begin_url' => uri_for('/'),
               'authors_url' => uri_for('/authors'),
               'authors_url' => uri_for('/authors'),
               'entry' => $entry,
    };
};

any ['get', 'post'] => '/books' => sub {
    my $for_display = 1;
    my $bd = books_extended($for_display);
    my $ids_in_order = hash_ids_sorted_by_field($bd, 'title');
    template 'browse_books.tt', {
               'msg' => get_flash(),
               'detail_book_prefix_url' => uri_for('/books/'),
               'begin_url' => uri_for('/'),
               'authors_url' => uri_for('/authors'),
               'books_url' => uri_for('/books'),
               'entries' => $bd,
               ids_in_order => $ids_in_order
    };
};
 
any ['get', 'post'] => '/books/' => sub {
       return redirect '/books';
};

any ['get', 'post'] => '/books/:book_id' => sub {
    my $book_id = param 'book_id';
    return error_in_params("Bad book ID given in /books/$book_id")
        unless ( $book_id =~ /^\d+$/ )  and  $book_id > 0;
    my $for_display = 1;
    my $entry = books_extended($for_display, $book_id)->{$book_id};
    $entry->{'book_id'} = $book_id;
    template 'edit_book.tt', {
               'msg' => get_flash(),
               'detail_book_prefix_url' => uri_for('/book/'),
               'begin_url' => uri_for('/'),
               'authors_url' => uri_for('/authors'),
               'books_url' => uri_for('/books'),
               'entry' => $entry,
    };
};

get '/api/authors' => sub {
    my $for_display = 0;
    return authors_extended($for_display);
};

post '/api/authors' => sub {
    my $new_author_data = collect_params('forename', 'surname', 'country');
    my $schema = db_schema();
    my $author_rs = $schema->resultset('Author');
    eval {
        my $new_author = $author_rs->create($new_author_data);
    }; if ($@) {
        return error_in_params("Error encountered while PUT with /api/authors " . $@)
    };
};

get '/api/authors/:author_id' => sub {
    my $author_id = param 'author_id';
    return error_in_params("Bad author ID given in /authors/$author_id")
        unless ( $author_id =~ /^\d+$/ )  and  $author_id > 0;
    my $for_display = 0;
    return authors_extended($for_display, $author_id);
};

patch '/api/authors/:author_id' => sub {
    my $author_id = param 'author_id';
    return error_in_params("Bad author ID given in /api/authors/$author_id")
        unless ( $author_id =~ /^\d+$/ )  and  $author_id > 0;

    my $new_author_data = collect_params('forename', 'surname', 'country');
    return error_in_params("No data given for PATCH /api/authors/$author_id")
        unless %$new_author_data;

    my $schema = db_schema();
    my $author = $schema->resultset('Author')
                        ->search({'me.author_id' => $author_id })
                        ->first;
    return error_in_params("Author ID in PATCH with /api/authors/$author_id not found")
        unless $author;

    eval {
        my $new_author = $author->update($new_author_data);
    }; if ($@) {
        return error_in_params("Error encountered while PATCH with /api/authors/$author_id " . $@)
    };
};

put '/api/authors/:author_id' => sub {
    my $author_id = param 'author_id';
    return error_in_params("Bad author ID given in /api/authors/$author_id")
        unless ( $author_id =~ /^\d+$/ )  and  $author_id > 0;

    my $new_author_data = collect_params('forename', 'surname', 'country');
    return error_in_params("No data given for PUT /api/authors/$author_id")
        unless %$new_author_data;

    my $schema = db_schema();
    my $author = $schema->resultset('Author')
                        ->search({'me.author_id' => $author_id })
                        ->first;
    forward "/api/authors/$author_id", { }, { method => 'PATCH' }
        if $author;

    forward "/api/authors", { }, { method => 'POST' }
};


del '/api/authors/:author_id' => sub {    # 'del' keyword stands for REST DELETE method
    my $author_id = param 'author_id';
    return error_in_params("Bad author ID given in /authors/$author_id")
        unless ( $author_id =~ /^\d+$/ )  and  $author_id > 0;

    my $author = db_schema()->resultset('Author')
                            ->search({'me.author_id' => $author_id })
                            ->first;
    return error_in_params("Author ID in DELETE with /api/authors/$author_id not found")
        unless $author;

    eval {
        my $purged_author_ex = $author->delete_related('book_authors');
        my $purged_author = $author->delete();
    }; if ($@) {
        return error_in_params("Error encountered while DELETE with /api/authors/$author_id " . $@)
    };
};


get '/api/books' => sub {
    my $for_display = 0;
    return books_extended($for_display);
};

post '/api/books' => sub {

    my $new_book_data = { author_id => param('author_id'),
                               book => { title     => param('title'),
                                         publ_date => param('publ_date'),
                                         isbn      => param('isbn'),
                                       }
                        };
    my $schema = db_schema();
    my $book_ext = $schema->resultset('Author')
                          ->search({'me.author_id' => $new_book_data->{'author_id'}})
                          ->first;
    eval {
        my $new_book_rel = $book_ext->create_related('book_authors',  $new_book_data );
    }; if ($@) {
        return error_in_params("Error encountered while PUT with /api/books " . $@)
    };
};


get '/api/books/:book_id' => sub {
    my $book_id = param 'book_id';
    return error_in_params("Bad book ID given in /books/$book_id")
        unless ( $book_id =~ /^\d+$/ )  and  $book_id > 0;
    my $for_display = 0;
    return books_extended($for_display, $book_id);
};

patch '/api/books/:book_id' => sub {
    my $book_id = param 'book_id';
    return error_in_params("Bad book ID given in /books/$book_id")
        unless ( $book_id =~ /^\d+$/ )  and  $book_id > 0;

    my $new_book_data = collect_params('title', 'publ_date', 'isbn');
    return error_in_params("No data given for PATCH /books/$book_id")
        unless %$new_book_data;

    my $book = db_schema()->resultset('Book')
                          ->search({'book_id' => $book_id })
                          ->first;
    return error_in_params("Book ID in PATCH with /api/books/$book_id not found")
        unless $book;

    eval {
        my $new_book = $book->update($new_book_data);
    }; if ($@) {
        return error_in_params("Error encountered while PATCH with /api/books/$book_id " . $@)
    };
};

put '/api/books/:book_id' => sub {
    my $book_id = param 'book_id';
    return error_in_params("Bad book ID given in /books/$book_id")
        unless ( $book_id =~ /^\d+$/ )  and  $book_id > 0;

    my $new_book_data = collect_params('title', 'publ_date', 'isbn');
    return error_in_params("No data given for PUT /books/$book_id")
        unless %$new_book_data;

    my $book = db_schema()->resultset('Book')
                          ->search({'book_id' => $book_id })
                          ->first;
    return error_in_params("Book ID in PATCH with /api/books/$book_id not found")
        unless $book;
    forward "/api/books/$book_id", { }, { method => 'PATCH' }
        if $book;

    forward "/api/books", { }, { method => 'POST' }
};


del '/api/books/:book_id' => sub {    # 'del' keyword stands for REST DELETE method
    my $book_id = param 'book_id';
    return error_in_params("Bad book ID given in /books/$book_id")
        unless ( $book_id =~ /^\d+$/ )  and  $book_id > 0;

    my $book = db_schema()->resultset('Book')
                            ->search({'me.book_id' => $book_id })
                            ->first;
    return error_in_params("Book ID in DELETE with /api/books/$book_id not found")
        unless $book;

    eval {
        my $purged_book_ex = $book->delete_related('book_authors');
        my $purged_book = $book->delete();
    }; if ($@) {
        return error_in_params("Error encountered while DELETE with /api/books/$book_id " . $@)
    };
};


# subroutine used to run Plack::Test test_psgi tests
sub  to_app{ return sub { my $env = shift;
    my $req = Dancer::Request->new(env => $env);
    Dancer->dance($req);
    my $res = Dancer::SharedData->response;
    return [ $res->status, $res->headers_to_array, [ $res->content ] ];
}};

1;
