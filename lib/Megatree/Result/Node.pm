package Megatree::Result::Node;
use strict;
use warnings;
use Megatree;
use Bio::Phylo::Forest::Node;
use base 'DBIx::Class::Core';
use base 'Bio::Phylo::Forest::Node';
__PACKAGE__->table("node");

=head1 ACCESSORS

=head2 id

  data_type: 'int'
  is_nullable: 0

=head2 parent

  data_type: 'int'
  is_nullable: 0

=head2 name

  data_type: 'string'
  is_nullable: 0

=head2 length

  data_type: 'float'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "int", is_nullable => 0 },
  "parent",
  { data_type => "int", is_nullable => 0 },
  "name",
  { data_type => "string", is_nullable => 0 },
  "length",
  { data_type => "float", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

my $schema;
sub _schema {
	if ( not $schema ) {
		$schema = Megatree->connect->resultset('Node');
	}
	return $schema;
}

sub get_parent {
	my $self = shift;
	return $self->_schema->find($self->parent);
}

sub get_children {
	my $self = shift;
	return [ $self->_schema->search({ 'parent' => $self->id })->all ];
}

sub get_id { shift->id }

sub get_name { shift->name }

sub get_branch_length { shift->length }

1;