# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 01_db.t'
#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use warnings;
use Test::More tests => 13;
use UNIVERSAL;
#test -- can we find the module?

BEGIN {
    use_ok( 'File::Spec' );
    use_ok( 'File::Slurp' );
    use_ok( 'Audio::ScratchLive' );
    use_ok( 'Audio::ScratchLive::Track' );
    use_ok( 'Audio::ScratchLive::Constants' );
};
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#test -- make sure we can know what type of object we're dealing with
my $ver = Audio::ScratchLive::Constants->version_default(
    Audio::ScratchLive::Constants::DB
);
ok( $ver, "Grab a constant" ) or BAIL_OUT( "Can't deal with constants: $!" );
#test -- new object/connection...
my $sl = Audio::ScratchLive->new(
    'filename' => File::Spec->catfile('t','DatabaseV2')
);
ok( $sl, "New Object Creation with DB test" ) or BAIL_OUT( "Couldn't create new object: $!" );
ok( $sl->parse(), "DB Parse Test" ) or BAIL_OUT( "Couldn't parse: $!" );
ok( ($sl->get_version() eq $ver), "DB version test: $ver" ) or diag( "Didn't get assumed version: $!" );
ok( ($sl->get_type() eq 'database'), "DB type test" ) or diag( "Didn't get assumed type: $!" );
ok( ($sl->get_num_tracks() == 12710), "DB Track count test: 12710" ) or diag( "Expected to find 12710 tracks: $!" );
my $tracks = $sl->get_tracks();
ok( UNIVERSAL::isa( $tracks, 'ARRAY' ), "DB Track array ref" ) or diag( "Expected to get an array ref: $!" );
ok( (scalar(@{$tracks})==12710), "Actual track count: 12710" ) or diag( "Didn't get the expected 12710 tracks: $!" );

