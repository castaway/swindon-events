use utf8;
package Mobilizon::Schema::Result::Todo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Todo

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

=head1 TABLE: C<todos>

=cut

__PACKAGE__->table("todos");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 status

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 due_date

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 creator_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 assigned_to_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 todo_list_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

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
  is_nullable: 1

=head2 published_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "status",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "due_date",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "creator_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "assigned_to_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "todo_list_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
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
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "published_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<todos_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("todos_url_index", ["url"]);

=head1 RELATIONS

=head2 assigned_to

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "assigned_to",
  "Mobilizon::Schema::Result::Actor",
  { id => "assigned_to_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 creator

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "creator",
  "Mobilizon::Schema::Result::Actor",
  { id => "creator_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 todo_list

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::TodoList>

=cut

__PACKAGE__->belongs_to(
  "todo_list",
  "Mobilizon::Schema::Result::TodoList",
  { id => "todo_list_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uVKUJr/C/SUaDCA94mATbg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
