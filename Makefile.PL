use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Podium',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'lib/App/Podium.pm',
    ABSTRACT_FROM       => 'lib/App/Podium.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'podium-*' },
);
