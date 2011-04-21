# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Energy::UserAdmin' ); }

my $object = Energy::UserAdmin->new ();
isa_ok ($object, 'Energy::UserAdmin');


