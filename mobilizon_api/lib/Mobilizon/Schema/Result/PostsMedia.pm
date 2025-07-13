use utf8;
package Mobilizon::Schema::Result::PostsMedia;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::PostsMedia

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

=head1 TABLE: C<posts_medias>

=cut

__PACKAGE__->table("posts_medias");

=head1 ACCESSORS

=head2 post_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 media_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "post_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "media_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</post_id>

=item * L</media_id>

=back

=cut

__PACKAGE__->set_primary_key("post_id", "media_id");

=head1 RELATIONS

=head2 media

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Media>

=cut

__PACKAGE__->belongs_to(
  "media",
  "Mobilizon::Schema::Result::Media",
  { id => "media_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 post

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Mobilizon::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f341pdPoaHPwMi84dyeMHA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
