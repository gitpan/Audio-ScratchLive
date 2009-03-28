use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Audio::ScratchLive',
    VERSION_FROM => 'lib/Audio/ScratchLive.pm', # finds $VERSION
    PREREQ_PM => {
        'Carp' => 1.08,
        'File::Spec' => 3.2501,
        'File::Slurp' => 9999.13,
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM => 'lib/Audio/ScratchLive.pm',
    AUTHOR => 'Chase Whitener <cwhitener@gmail.com>',
    LICENSE => 'perl',
);
