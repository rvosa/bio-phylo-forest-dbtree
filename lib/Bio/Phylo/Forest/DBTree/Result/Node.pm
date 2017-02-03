package Bio::Phylo::Forest::DBTree::Result::Node;
use strict;
use warnings;
use Bio::Phylo::Forest::DBTree;
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

=head2 left

  data_type: 'int'
  is_nullable: 0

=head2 right

  data_type: 'int'
  is_nullable: 0

=head2 name

  data_type: 'string'
  is_nullable: 0

=head2 length

  data_type: 'float'
  is_nullable: 0

=head2 height

  data_type: 'float'
  is_nullable: 0


=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "int", is_nullable => 0 },
  "parent",
  { data_type => "int", is_nullable => 0 },
  "left",
  { data_type => "int", is_nullable => 1 },  
  "right",
  { data_type => "int", is_nullable => 1 },  
  "name",
  { data_type => "string", is_nullable => 0 },
  "length",
  { data_type => "float", is_nullable => 0 },
  "height",
  { data_type => "float", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

my $schema;
sub _schema {
	if ( not $schema ) {
		$schema = Bio::Phylo::Forest::DBTree->connect->resultset('Node');
	}
	return $schema;
}

sub get_parent {
	my $self = shift;
	return $self->_schema->find($self->parent);
}

sub get_children_rs {
	my $self = shift;
	my $id = $self->id;
	return $self->_schema->search({
		'-and' => [ 
			'parent' => { '==' => $id },
			'id'     => { '!=' => $id },
		]
	});
}

sub get_children { [ shift->get_children_rs->all ] }

sub get_descendants_rs {
	my $self = shift;
	return $self->_schema->search(
		{
			'-and' => [
				'left'  => { '>' => $self->left },
				'right' => { '<' => $self->right },
			]
		}
	)
}

sub get_descendants { [ shift->get_descendants_rs->all ] }

sub get_terminals_rs {
	my $self = shift;
	my $scalar = 'right';
	return $self->_schema->search(
		{
			'-and' => [
				'left'  => { '>' => $self->left },
				'right' => { '<' => $self->right },
				'left'  => { '==' => \$scalar },
			]
		}
	)	
}

sub get_terminals { [ shift->get_terminals_rs->all ] }

sub get_internals_rs {
	my $self = shift;
	my $scalar = 'right';
	return $self->_schema->search(
		{
			'-and' => [
				'left'  => { '>' => $self->left },
				'right' => { '<' => $self->right },
				'left'  => { '!=' => \$scalar },
			]
		}
	)
}

sub get_internals { [ shift->get_internals_rs->all ] }

sub get_ancestors_rs {
	my $self = shift;
	return $self->_schema->search(
		{
			'-and' => [
				'left'  => { '<' => $self->left },
				'right' => { '>' => $self->right },
			]
		}
	)
}

sub get_ancestors { [ shift->get_ancestors_rs->all ] }

sub get_mrca {
	my ( $self, $other ) = @_;
	my @lefts = sort { $a <=> $b } $self->left, $other->left;
	my @rights = sort { $a <=> $b } $self->right, $other->right;
	return $self->_schema->search(
		{ 
			'-and' => [ 
				'left'  => { '<' => $lefts[0] },
				'right' => { '>' => $rights[1] },
			]
		},
		{
			'order_by' => 'left',
			'rows'     => 1,
		}
	)->single;			
}

sub _index {
	my ( $self, $counter, $height ) = @_;
	$height += ( $self->get_branch_length || 0 );
	if ( ref($counter) eq 'SCALAR' ) {
		$$counter = $$counter + 1;
	}
	else {
		my $i = 1;
		$counter = \$i;
	}
	$self->update({ 'left' => $$counter, 'height' => $height });
	my @c = @{ $self->get_children };
	for my $child ( @c ) {
		$child->_index($counter, $height);
	}
	if ( @c ) {
		$$counter = $$counter + 1;
	}
	$self->update({ 'right' => $$counter });
}

sub get_id { shift->id }

sub get_name { shift->name }

sub get_branch_length { shift->length }

sub is_descendant_of {
	my ( $self, $other ) = @_;
	return ( $self->left > $other->left ) && ( $self->right < $other->right );
}

sub calc_patristic_distance {
	my ( $self, $other ) = @_;
	my $mrca = $self->get_mrca($other);
	my $mh = $mrca->height;
	return ( $self->height - $mh ) + ( $other->height - $mh );
}

1;