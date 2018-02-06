use utf8;
package Bookshell::Schema::Result::Book;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bookshell::Schema::Result::Book

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<books>

=cut

__PACKAGE__->table("books");

=head1 ACCESSORS

=head2 book_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 publ_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=cut

__PACKAGE__->add_columns(
  "book_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "publ_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 25 },
);

=head1 PRIMARY KEY

=over 4

=item * L</book_id>

=back

=cut

__PACKAGE__->set_primary_key("book_id");

=head1 RELATIONS

=head2 book_authors

Type: has_many

Related object: L<Bookshell::Schema::Result::BookAuthor>

=cut

__PACKAGE__->has_many(
  "book_authors",
  "Bookshell::Schema::Result::BookAuthor",
  { "foreign.book_id" => "self.book_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-30 06:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AucG9JNl3D8GaNEHDp+1Bg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
