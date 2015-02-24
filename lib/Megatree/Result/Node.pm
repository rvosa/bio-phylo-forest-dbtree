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

sub get_descendants {
	my $self = shift;
	return [
		$self->_schema->search(
			{
				'-and' => [
					'left'  => { '>' => $self->left },
					'right' => { '<' => $self->right },
				]
			}
		)->all
	];
}

sub get_terminals {
	my $self = shift;
	my $scalar = 'right';
	return [
		$self->_schema->search(
			{
				'-and' => [
					'left'  => { '>' => $self->left },
					'right' => { '<' => $self->right },
					'left'  => { '==' => \$scalar },
				]
			}
		)->all
	];
}

sub get_internals {
	my $self = shift;
	my $scalar = 'right';
	return [
		$self->_schema->search(
			{
				'-and' => [
					'left'  => { '>' => $self->left },
					'right' => { '<' => $self->right },
					'left'  => { '!=' => \$scalar },
				]
			}
		)->all
	];
}

sub get_ancestors {
	my $self = shift;
	return [
		$self->_schema->search(
			{
				'-and' => [
					'left'  => { '<' => $self->left },
					'right' => { '>' => $self->right },
				]
			}
		)->all
	];
}

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
	$$counter = $$counter + 1;
	$self->update({ 'left' => $$counter, 'height' => $height });
	for my $child ( @{ $self->get_children } ) {
		$child->_index($counter, $height);
	}
	$self->update({ 'right' => $$counter });
}

sub get_id { shift->id }

sub get_name { shift->name }

sub get_branch_length { shift->length }

sub calc_patristic_distance {
	my ( $self, $other ) = @_;
	my $mrca = $self->get_mrca($other);
	my $mh = $mrca->height;
	return ( $self->height - $mh ) + ( $other->height - $mh );
}

1;