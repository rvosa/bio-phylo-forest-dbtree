package Megatree;
use strict;
use warnings;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Exceptions 'throw';
use base 'DBIx::Class::Schema';
use base 'Bio::Phylo::Forest::Tree';

__PACKAGE__->load_namespaces;

use DBI;
my $SINGLETON;
my $DBH;
my $fac = Bio::Phylo::Factory->new;
our $VERSION = '0.1';

sub connect {
	my $class = shift;
	my $file  = shift;
	if ( not $SINGLETON ) {
		
		# create if not exist
		if ( not -e $file ) {
			$class->create($file);
		}
	
		# fuck it, let's just hardcode it here - Yeehaw!
		my $dsn  = "dbi:SQLite:dbname=$file";
		$DBH = DBI->connect($dsn,'','');
		$DBH->{'RaiseError'} = 1;
		$SINGLETON = $class->SUPER::connect( sub { $DBH } );
	}
	return $SINGLETON;
}

sub make_mutable {
	my $self = shift;
	my $tree = $fac->create_tree;
	my $root = $self->get_root;
	_clone_mutable(
		$fac->create_node(
			'-name'          => $root->get_name,
			'-branch_length' => $root->get_branch_length,
		),
		$root,
		$tree
	);
	return $tree;
}

{
	no warnings 'recursion';
	sub _clone_mutable {
		my ( $parent, $template, $tree ) = @_;
		$tree->insert($parent);
		for my $child ( @{ $template->get_children } ) {
			_clone_mutable( 
				$fac->create_node(
					'-name'          => $child->get_name,
					'-branch_length' => $child->get_branch_length,
					'-parent'        => $parent,
				),
				$child,
				$tree
			);
		}
	}
}

sub persist {
	my ( $class, %args ) = @_;
	
	# need a file argument to write to
	if ( not $args{'-file'} ) {
		throw 'BadArgs' => "Need -file argument!";
	}
	
	# need a tree argument to persis
	if ( not $args{'-tree'} ) {
		throw 'BadArgs' => "Need -tree argument!";
	}
	
	# create a new database, prepare statement handler
	$class->create( $args{'-file'} );
	my $dsn = 'dbi:SQLite:dbname=' . $args{'-file'};
	my $dbh = DBI->connect($dsn,'','');
	$dbh->{'RaiseError'} = 1;
	my $db = $class->SUPER::connect( sub { $dbh } );		
	my $sth = $dbh->prepare("insert into node values(?,?,?,?)");
	
	# start traversing
	my $counter = 2;
	my %idmap;
	$args{'-tree'}->visit_depth_first(
		'-pre' => sub {
			my $node    = shift;
			my $id      = $node->get_id;
			$idmap{$id} = $counter++;
			
			# get the parent id, or "1" if root
			my $parent_id;
			if ( my $parent = $node->get_parent ) {
				my $pid = $parent->get_id;
				$parent_id = $idmap{$pid};
			}
			else {
				$parent_id = 1;
			}
			
			# do the insertion
			$sth->execute(
				$idmap{$id},               # primary key
				$parent_id,                # self-joining foreign key
				$node->get_internal_name,  # node label or taxon name
				$node->get_branch_length,  # branch length
			);
		}
	);
	return $db;
}

sub _rs { shift->resultset('Node') }

sub get_root { shift->_rs->find(2) }

sub dbh { $DBH }

sub create {
	my ($class,$file) = @_;
	my $command = <<'COMMAND';
create table node(id int not null,parent int,name varchar(20),length float,primary key(id));
create index parent_idx on node(parent);
create index name_idx on node(name);
COMMAND
	system("echo '$command' | sqlite3 $file") == 0 or die 'Create failed!';
}

sub get_id { 0 }

sub visit {
	my ( $self, $code ) = @_;
	my $rs = $self->_rs;
	while( my $node = $rs->next ) {
		$code->($node);
	}
	return $self;
}

1;
