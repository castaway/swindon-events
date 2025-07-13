use utf8;
package Mobilizon::Schema::Result::CommentsTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::CommentsTag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::UUIDColumns>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "UUIDColumns");

=head1 TABLE: C<comments_tags>

=cut

__PACKAGE__->table("comments_tags");

=head1 ACCESSORS

=head2 comment_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "tag_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</comment_id>

=item * L</tag_id>

=back

=cut

__PACKAGE__->set_primary_key("comment_id", "tag_id");

=head1 RELATIONS

=head2 comment

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "comment",
  "Mobilizon::Schema::Result::Comment",
  { id => "comment_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 tag

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "Mobilizon::Schema::Result::Tag",
  { id => "tag_id" },
  { is_deferrable => 0, on_delete => "SET NULL", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/hLNVmmk6e1tOXpnupB6pg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
