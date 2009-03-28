# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 02_crate.t'
#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use warnings;
use UNIVERSAL;
use Test::More tests => 13;

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
    Audio::ScratchLive::Constants::CRATE
);
ok( $ver, "Grab a constant" ) or BAIL_OUT( "Can't deal with constants: $!" );
#test -- new object/connection...
my $sl = Audio::ScratchLive->new(
    'filename' => File::Spec->catfile('t','Reggae.crate')
);
ok( $sl, "New Object Creation with crate test" ) or BAIL_OUT( "Couldn't create new object: $!" );
ok( $sl->parse(), "DB Parse Test" ) or BAIL_OUT( "Couldn't parse: $!" );
ok( ($sl->get_version() eq $ver), "Crate version test: $ver" ) or diag( "Didn't get assumed version: $!" );
ok( ($sl->get_type() eq 'crate'), "crate type test" ) or diag( "Didn't get assumed type: $!" );
ok( ($sl->get_num_tracks() == 946), "Crate Track count test: 946" ) or diag( "Expected to find 946 tracks: $!" );
my $tracks = $sl->get_tracks();
ok( UNIVERSAL::isa( $tracks, 'ARRAY' ), "Crate Track array ref" ) or diag( "Expected to get an array ref: $!" );
ok( (scalar(@{$tracks})==946), "Actual track count: 946" ) or diag( "Didn't get the expected 946 tracks: $!" );

