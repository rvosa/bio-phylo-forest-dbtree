package Megatree;
use strict;
use warnings;
use Bio::Phylo::Forest::Tree;
use base 'DBIx::Class::Schema';
use base 'Bio::Phylo::Forest::Tree';

__PACKAGE__->load_namespaces;

use DBI;
my $SINGLETON;
my $DBH;
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
