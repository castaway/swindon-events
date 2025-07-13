use utf8;
package Mobilizon::Schema::Result::Report;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Report

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

=head1 TABLE: C<reports>

=cut

__PACKAGE__->table("reports");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'reports_id_seq'

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'enum'
  default_value: 'open'
  extra: {custom_type_name => "report_status",list => ["open","closed","resolved"]}
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 reported_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 reporter_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 manager_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

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

=head2 local

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "reports_id_seq",
  },
  "content",
  { data_type => "text", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "open",
    extra => {
      custom_type_name => "report_status",
      list => ["open", "closed", "resolved"],
    },
    is_nullable => 0,
  },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "reported_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "reporter_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "manager_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
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
  "local",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 manager

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "manager",
  "Mobilizon::Schema::Result::Actor",
  { id => "manager_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 report_notes

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportNote>

=cut

__PACKAGE__->has_many(
  "report_notes",
  "Mobilizon::Schema::Result::ReportNote",
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reported

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "reported",
  "Mobilizon::Schema::Result::Actor",
  { id => "reported_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 reporter

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "reporter",
  "Mobilizon::Schema::Result::Actor",
  { id => "reporter_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 reports_comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportsComment>

=cut

__PACKAGE__->has_many(
  "reports_comments",
  "Mobilizon::Schema::Result::ReportsComment",
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reports_events

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportsEvent>

=cut

__PACKAGE__->has_many(
  "reports_events",
  "Mobilizon::Schema::Result::ReportsEvent",
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8UrlIy55Z4l1ztGdZLO2Bg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
