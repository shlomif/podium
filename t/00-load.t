#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Podium' );
}

diag( "Testing App::Podium $App::Podium::VERSION, Perl $], $^X" );
