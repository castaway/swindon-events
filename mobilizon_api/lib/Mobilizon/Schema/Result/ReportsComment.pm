use utf8;
package Mobilizon::Schema::Result::ReportsComment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::ReportsComment

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

=head1 TABLE: C<reports_comments>

=cut

__PACKAGE__->table("reports_comments");

=head1 ACCESSORS

=head2 report_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 comment_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "report_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "comment_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

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

=head2 report

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Report>

=cut

__PACKAGE__->belongs_to(
  "report",
  "Mobilizon::Schema::Result::Report",
  { id => "report_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vMGw8a+HJiDneSBfB+7rgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
