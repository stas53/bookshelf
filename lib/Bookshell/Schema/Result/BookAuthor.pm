use utf8;
package Bookshell::Schema::Result::BookAuthor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bookshell::Schema::Result::BookAuthor

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<book_author>

=cut

__PACKAGE__->table("book_author");

=head1 ACCESSORS

=head2 book_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 author_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "book_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "author_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<book_id>

=over 4

=item * L</book_id>

=item * L</author_id>

=back

=cut

__PACKAGE__->add_unique_constraint("book_id", ["book_id", "author_id"]);

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Bookshell::Schema::Result::Author>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Bookshell::Schema::Result::Author",
  { author_id => "author_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 book

Type: belongs_to

Related object: L<Bookshell::Schema::Result::Book>

=cut

__PACKAGE__->belongs_to(
  "book",
  "Bookshell::Schema::Result::Book",
  { book_id => "book_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-30 06:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mp7vDC5Xb3bCP2Liie1+Ww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
