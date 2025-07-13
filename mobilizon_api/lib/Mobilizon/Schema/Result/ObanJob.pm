use utf8;
package Mobilizon::Schema::Result::ObanJob;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::ObanJob - 12

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

=head1 TABLE: C<oban_jobs>

=cut

__PACKAGE__->table("oban_jobs");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'oban_jobs_id_seq'

=head2 state

  data_type: 'enum'
  default_value: 'available'
  extra: {custom_type_name => "oban_job_state",list => ["available","scheduled","executing","retryable","completed","discarded","cancelled"]}
  is_nullable: 0

=head2 queue

  data_type: 'text'
  default_value: 'default'
  is_nullable: 0

=head2 worker

  data_type: 'text'
  is_nullable: 0

=head2 args

  data_type: 'jsonb'
  default_value: '{}'
  is_nullable: 0

=head2 errors

  data_type: 'jsonb[]'
  default_value: ARRAY[]::jsonb[]
  is_nullable: 0

=head2 attempt

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 max_attempts

  data_type: 'integer'
  default_value: 20
  is_nullable: 0

=head2 inserted_at

  data_type: 'timestamp'
  default_value: timezone('UTC'::text, now())
  is_nullable: 0
  set_on_create: 1

=head2 scheduled_at

  data_type: 'timestamp'
  default_value: timezone('UTC'::text, now())
  is_nullable: 0

=head2 attempted_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 completed_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 attempted_by

  data_type: 'text[]'
  is_nullable: 1

=head2 discarded_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 tags

  data_type: 'character varying[]'
  default_value: ARRAY[]::character varying[]
  is_nullable: 1
  size: 255

=head2 meta

  data_type: 'jsonb'
  default_value: '{}'
  is_nullable: 1

=head2 cancelled_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "oban_jobs_id_seq",
  },
  "state",
  {
    data_type => "enum",
    default_value => "available",
    extra => {
      custom_type_name => "oban_job_state",
      list => [
        "available",
        "scheduled",
        "executing",
        "retryable",
        "completed",
        "discarded",
        "cancelled",
      ],
    },
    is_nullable => 0,
  },
  "queue",
  { data_type => "text", default_value => "default", is_nullable => 0 },
  "worker",
  { data_type => "text", is_nullable => 0 },
  "args",
  { data_type => "jsonb", default_value => "{}", is_nullable => 0 },
  "errors",
  {
    data_type     => "jsonb[]",
    default_value => \"ARRAY[]::jsonb[]",
    is_nullable   => 0,
  },
  "attempt",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "max_attempts",
  { data_type => "integer", default_value => 20, is_nullable => 0 },
  "inserted_at",
  {
    data_type     => "timestamp",
    default_value => \"timezone('UTC'::text, now())",
    is_nullable   => 0,
    set_on_create => 1,
  },
  "scheduled_at",
  {
    data_type     => "timestamp",
    default_value => \"timezone('UTC'::text, now())",
    is_nullable   => 0,
  },
  "attempted_at",
  { data_type => "timestamp", is_nullable => 1 },
  "completed_at",
  { data_type => "timestamp", is_nullable => 1 },
  "attempted_by",
  { data_type => "text[]", is_nullable => 1 },
  "discarded_at",
  { data_type => "timestamp", is_nullable => 1 },
  "priority",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "tags",
  {
    data_type => "character varying[]",
    default_value => \"ARRAY[]::character varying[]",
    is_nullable => 1,
    size => 255,
  },
  "meta",
  { data_type => "jsonb", default_value => "{}", is_nullable => 1 },
  "cancelled_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XjQDLMPSbA3yNC8PIZdPNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
