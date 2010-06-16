use 5.10.0;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'podium',
    ABSTRACT            => 'POD-based presentation and website builder',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'Podium.pm',
    LICENSE             => 'artistic2',
    PL_FILES            => {},
    PM                  => {
        'Podium.pm' => '$(INST_LIBDIR)/Podium.pm',
        'PSH.pm'    => '$(INST_LIBDIR)/Podium/PSH.pm',
    },
    EXE_FILES           => [ 'podium' ],
    PREREQ_PM => {
        'Carp::Always'      => 0,
        'File::Slurp'       => 0,
        'Getopt::Long'      => 0,
        'Pod::Simple'       => 3.13,
        'Pod::Simple::HTML' => 0,
        'Template'          => 0,
        'Test::More'        => 0,
        'YAML'              => 0,
    },
    META_MERGE => {
        resources => {
            homepage    => 'http://betterthangrep.com/',
            bugtracker  => 'http://github.com/petdance/ack',
            license     => 'http://dev.perl.org/licenses/',
            repository  => 'git://github.com/petdance/ack.git',
            MailingList => 'http://groups.google.com/group/ack-users',
        },
    },
    MAN3PODS            => {}, # no need for man pages for any of the .pm files
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'podium-1* nytprof*' },

);


sub MY::postamble {
    my $file_next_filename = qx(perldoc -l File::Next);
    my $postamble = <<'MAKE_FRAG';
.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib \
		--exclude=.git \
		--exclude='*~' \
		--exclude=podium \
		--languages=Perl --langmap=Perl:+.t \

critic:
	perlcritic -1 -q -profile perlcriticrc $(BASE) $(ALL_PM) t/*.t

tidy:
	perltidy -b -pro=perltidyrc $(BASE) $(ALL_PM)

PROF_ARGS = -Mblib ./$(ACK) --noenv --color --group -w foo ~/parrot

timed: all
	$(PERL) $(PROF_ARGS) >> /dev/null 2>&1

dprof: all
	$(PERL) -d:DProf $(PROF_ARGS) >> /dev/null 2>&1
	dprofpp -R

dproflb: all
	$(PERL) -d:DProfLB $(PROF_ARGS) >> /dev/null 2>&1
	dprofpp -R

fastprof: all
	$(PERL) -d:FastProf $(PROF_ARGS) >> /dev/null 2>&1
	fprofpp

profile: all
	$(PERL) -d:Profile $(PROF_ARGS) >> /dev/null 2>&1
	less prof.out

profiler: all
	$(PERL) -MDevel::Profiler $(PROF_ARGS) >> /dev/null 2>&1
	dprofpp -R

smallprof: all
	$(PERL) -d:SmallProf $(PROF_ARGS) >> /dev/null 2>&1
	sort -k 2nr,2 smallprof.out | less

nytprof: all
	$(PERL) -d:NYTProf $(PROF_ARGS) >> /dev/null 2>&1
	nytprofhtml

$(ACK) : $(BASE) $(ALL_PM) squash Makefile
	$(PERL) squash ack-base File::Next $(ALL_PM) > $(ACK)
	$(CHMOD) 0755 $(ACK)
	$(PERL_T) -c $(ACK)

$(ACK_HELP) : $(ACK)
	$(PERL_T) $(ACK) --noenv --help > $(ACK_HELP) || perl -e0

$(ACK_HELP_TYPES) : $(ACK)
	$(PERL_T) $(ACK) --noenv --help=types > $(ACK_HELP_TYPES) || perl -e0

MAKE_FRAG

    return $postamble;
}
