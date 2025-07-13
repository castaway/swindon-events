use utf8;
package Mobilizon::Schema::Result::ReportNote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::ReportNote

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

=head1 TABLE: C<report_notes>

=cut

__PACKAGE__->table("report_notes");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'report_notes_id_seq'

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 moderator_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 report_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 inserted_at

  data_type: 'timestamp'
  is_nullable: 0
  set_on_create: 1
  size: 0

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 0
  set_on_create: 1
  set_on_update: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "report_notes_id_seq",
  },
  "content",
  { data_type => "text", is_nullable => 0 },
  "moderator_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "report_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "inserted_at",
  { data_type => "timestamp", is_nullable => 0, set_on_create => 1, size => 0 },
  "updated_at",
  {
    data_type => "timestamp",
    is_nullable => 0,
    set_on_create => 1,
    set_on_update => 1,
    size => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 moderator

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "moderator",
  "Mobilizon::Schema::Result::Actor",
  { id => "moderator_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:of9Gtkg+VTsxWzG4UA3Ngw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
