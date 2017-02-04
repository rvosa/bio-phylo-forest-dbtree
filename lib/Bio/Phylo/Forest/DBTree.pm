package Bio::Phylo::Forest::DBTree;
use strict;
use warnings;
use DBI;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Exceptions 'throw';
use base 'DBIx::Class::Schema';
use base 'Bio::Phylo::Forest::Tree';

__PACKAGE__->load_namespaces;

my $SINGLETON;
my $DBH;
my $fac = Bio::Phylo::Factory->new;
our $VERSION = '0.1';

=head2 connect()

Connects to a SQLite database file, returns the connection as a 
C<Bio::Phylo::Forest::DBTree> object. Usage:

 use Bio::Phylo::Forest::DBTree;
 my $dbtree = Bio::Phylo::Forest::DBTree->connect($file);

The argument is a file name. If the file exists, a L<DBD::SQLite> database handle to that
file is returned. If the file does not exist, a new database is created in that location,
and subsequently the handle to that newly created database is returned. The creation of 
the database is handled by the C<create()> method (see below).

=cut

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

=head2 create()

Creates a SQLite database file in the provided location. Usage:

  use Bio::Phylo::Forest::DBTree;
  
  # second argument is optional
  Bio::Phylo::Forest::DBTree->create( $file, '/opt/local/bin/sqlite3' );

The first argument is the location where the database file is going to be created. The
second argument is optional, and provides the location of the C<sqlite3> executable that
is used to create the database. By default, the C<sqlite3> is simply found on the 
C<$PATH>, but if it is installed in a non-standard location that location can be provided
here. The database schema that is created corresponds to the following SQL statements:

 create table node(
 	id int not null,
 	parent int,
 	left int,
 	right int,
 	name varchar(20),
 	length float,
 	height float,
 	primary key(id)
 );
 create index parent_idx on node(parent);
 create index left_idx on node(left);
 create index right_idx on node(right);
 create index name_idx on node(name);

=cut

sub create {
	my $class = shift;
	my $file  = shift;
	my $sqlite3 = shift || 'sqlite3';
	my $command = do { local $/; <DATA> };
	system("echo '$command' | sqlite3 '$file'") == 0 or die 'Create failed!';
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
				undef,                     # not indexed yet
				undef,                     # not indexed yet
				$node->get_internal_name,  # node label or taxon name
				$node->get_branch_length,  # branch length
				undef                      # not computed yet
			);
		}
	);
	my $i = 0;
	$db->get_root->_index(\$i,0);
	return $db;
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


sub get_root { 
	shift->_rs->search(
		{ 'parent' => 1 },
		{
			'order_by' => 'id',
			'rows'     => 1,
		}
	)->single 
}

sub get_id { 0 }

sub get_by_name {
	my ( $self, $name ) = @_;
	return $self->_rs->search({ 'name' => $name })->single;
}

sub visit {
	my ( $self, $code ) = @_;
	my $rs = $self->_rs;
	while( my $node = $rs->next ) {
		$code->($node);
	}
	return $self;
}

sub dbh { $DBH }

sub _rs { shift->resultset('Node') }

1;

__DATA__
create table node(id int not null,parent int,left int,right int,name varchar(20),length float,height float,primary key(id));
create index parent_idx on node(parent);
create index left_idx on node(left);
create index right_idx on node(right);
create index name_idx on node(name);
