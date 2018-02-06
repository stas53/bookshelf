use utf8;
package Bookshell::Schema::Result::Author;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bookshell::Schema::Result::Author

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<authors>

=cut

__PACKAGE__->table("authors");

=head1 ACCESSORS

=head2 author_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 forename

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 surname

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "author_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "forename",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "surname",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</author_id>

=back

=cut

__PACKAGE__->set_primary_key("author_id");

=head1 RELATIONS

=head2 book_authors

Type: has_many

Related object: L<Bookshell::Schema::Result::BookAuthor>

=cut

__PACKAGE__->has_many(
  "book_authors",
  "Bookshell::Schema::Result::BookAuthor",
  { "foreign.author_id" => "self.author_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-30 06:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nUsEjTXf6MGUVM/CVxeegA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
