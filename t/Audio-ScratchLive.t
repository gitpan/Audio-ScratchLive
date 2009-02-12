# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Audio-ScratchLive.t'
#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use warnings;
use Test::More tests => 13;

#test -- can we find the module?

BEGIN {
    use_ok( 'File::Spec' );
    use_ok( 'Audio::ScratchLive' );
    use_ok( 'Audio::ScratchLive::Constants' );
};
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#test -- new object/connection...
my $sl = Audio::ScratchLive->new(
    'filename' => File::Spec->catfile('t','Database V2')
);
ok( $sl, "New Object Creation with DB test" ) or BAIL_OUT( $! );

#test -- parse
{
    my $res = $sl->parse();
    ok( $res, "DB Parse Test" ) or diag( $! );
}

#test -- grab version
{
    my $res = $sl->get_version();
    my $ver = Audio::ScratchLive::Constants->version_default(
        Audio::ScratchLive::Constants::DB
    );
    ok( ($res eq $ver), "DB version test: $ver" ) or diag( $! );
}

#test -- grab type
{
    my $res = $sl->get_type();
    ok( ($res eq 'database'), "DB type test" ) or diag( $! );
}

#test -- number of tracks
{
    my $res = $sl->get_num_tracks();
    ok( ($res == 12710), "DB Track count test: 12710" ) or diag( $! );
}

undef($sl);
$sl = Audio::ScratchLive->new(
    'filename' => File::Spec->catfile('t','Reggae.crate')
);
ok( $sl, "New Object Creation with crate test" ) or BAIL_OUT( $! );

#test -- parse
{
    my $res = $sl->parse();
    ok( $res, "crate Parse Test" ) or diag( $! );
}

#test -- grab version
{
    my $res = $sl->get_version();
    my $ver = Audio::ScratchLive::Constants->version_default(
        Audio::ScratchLive::Constants::CRATE
    );
    ok( ($res eq $ver), "crate version test: $ver" ) or diag( $! );
}

#test -- grab type
{
    my $res = $sl->get_type();
    ok( ($res eq 'crate'), "crate type test" ) or diag( $! );
}

#test -- number of tracks
{
    my $res = $sl->get_num_tracks();
    ok( ($res==946), "crate Track count test: 946" ) or diag( $! );
}
