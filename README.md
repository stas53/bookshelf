README.txt
==========

    "bookshelf" Project

## Purpose

Training of a few Perl packeges
         - Dancer
         - Dancer::Plugin::DBIC
         - MySQL connection
         - Plack::Test

## The Task

To construct a database and write a Dancer application with REST interface
       serving as a simple collection of books.

## Data base

Stores two main types of data

    - Books
      + title
      + author
      + publication date
      + ISBN

    - Authors
      + forename
      + surname
      + country

## REST interface

Enables the following routes and HTTP methods

     + /api/books/       - GET, POST
     + /api/books/:id    - GET, PUT PATCH, DELETE
     + /api/authors/     - GET, POST
     + /api/authors/:id  - GET, PUT PATCH, DELETE

    Data exchange processes use JSON format.

## WWW application

Is a simple interface for the end user.

The following pages are designed

    + /index.html  -- a static page with links to /books/ and /authors/
    + /books/      -- list of all books, sorted by title. Every entry has a link to a page with details of this book
    + /books/:id   -- a page with details of the selected book
    + /authors/    -- list of all authors, sorted alphabetically by surname. Every entry has a link to a page with details of this author
    + /authors/:id -- a page with details of the pointed author. Contains his/her personal data and a list of books

The WWW application is constructed as a part of the same Dancer application as the RRST interface is.

Additional requirements specify the packages to be used

    + MySQL database
    + Dancer::Plugin::DBIC
    + Plack::Test

A few tests are prepared, just as an example.




## IMPLEMENTATION

Environment

    * Windows 7  or  Ubuntu 16
    * MySQL 5.5 or 5.7
    * Dancer 1.3


Sources

    * bookshell.sql - a dump of the example data base
    * config.yml - DB connection info is put here.

## Installation on local server

    git clone https://github.com/stas53/bookshelf.git
    cd bookshelf
    vim config.yml
      ...  replace username and password of 'bookshell' database
    mysql -p
      ...  give password
      \. bookshell.sql
    \q


## Running

    Server
        perl bin/app.pl

    Web browser
        localhost:3000/index

## Additional Tests

        perl t\003_test.t
        perl t\004_test.t
        perl t\005_test.t
