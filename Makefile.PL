use 5.008001;
use ExtUtils::MakeMaker;

print <<END;
Several tests need to be run in order to test the Scratchlive Perl module.

END


WriteMakefile(
    NAME              => 'Audio::ScratchLive',
    VERSION_FROM      => 'lib/Audio/ScratchLive.pm', # finds $VERSION
    PREREQ_PM         => {
        'Carp' => 1.08,
        'File::Spec'    => 3.2501,
        'Fcntl' => 1.06,
    }, # e.g., Module::Name => 1.1
);
