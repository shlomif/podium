package App::Podium;

use 5.10.0;
use warnings;
use strict;

=head1 NAME

App::Podium - Helper functions for podium

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use App::Podium::PSH;
use File::Slurp;
use Getopt::Long;
use YAML qw( LoadFile );
use Template ();
use Template::Constants qw( :debug :chomp );

use ExtUtils::Command qw( rm_rf );

=head1 SYNOPSIS

Helper functions for podium.  No user-serviceable parts inside.

=head1 FUNCTIONS

=head2 pod2html

=cut

sub pod2html {
    my $podfile = shift;

    my $html;

    my $parser = App::Podium::PSH->new;
    $parser->html_header_before_title( '' );
    $parser->html_header_after_title( '' );
    $parser->html_footer( '' );

    # Manually adjust the stuff we passed thru earlier
    my $podtext = read_file( $podfile );

    $podtext =~ s{P<(.+?)>}{L<$1|http://perldoc.perl.org/$1.html>}g;
    $podtext =~ s{M<(.+?)>}{L<$1|http://search.cpan.org/perldoc?$1>}g;

    $parser->complain_stderr( 1 );
    $parser->output_string( \$html );
    $parser->parse_string_document( $podtext );


    return $html;
}

sub get_pages {
    my $sourcedir = shift;
    my $pages     = shift;

    opendir my $dh, $sourcedir or die "Can't open $sourcedir";
    my %pod = map { ($_,1) } grep { /\.pod$/ && -f "$sourcedir/$_" } readdir $dh;

    my @ordered_pages;
    for my $section ( @{$pages} ) {
        my $filename = make_filename( $section );
        delete $pod{"$filename.pod"} or die "$filename is in the section list but not in the source";
        push( @ordered_pages, [ $filename, $section ] );
    }
    if ( keys %pod ) {
        die "The following pod files still exist: ", join( ', ', sort keys %pod );
    }

    return @ordered_pages;
}

sub make_filename {
    my $name = lc shift;

    $name =~ s/[^-a-z]+/-/g;
    $name =~ s/^-//;
    $name =~ s/-$//;

    return $name;
}

sub get_config {
    my $configfile;

    GetOptions( 'configfile:s' => \$configfile ) or exit;

    if ( !$configfile ) {
        $configfile = 'config.yaml';
        say "Using $configfile";
    }

    my $config = LoadFile( $configfile );
}


sub build_tt_object {
    my $config = shift;

    my %defaults = (
        INCLUDE_PATH => [ $config->{templatepath} ],
        OUTPUT_PATH  => $config->{buildpath},
        DEBUG        => DEBUG_UNDEF,
        TRIM         => CHOMP_ALL,
        PRE_CHOMP    => 1,
        POST_CHOMP   => 1,
    );

    my $tt = Template->new( \%defaults );

    return $tt;
}

sub command_test {
    my $config = shift;

    say 'TODO: Make this do something';

    return;
}

sub command_clean {
    my $config = shift;

    local @ARGV = $config->{buildpath};
    rm_rf;

    return;
}

sub _mkpath {
    local @ARGV = @_;
}

sub command_build {
    my $config = shift;

    _mkpath( $config->{buildpath} );

    my $tt = App::Podium::build_tt_object( $config );

    my $vars = {};

    my @podfiles;
    my @sidelinks;

    my $podpath = $config->{podpath};
    for ( App::Podium::get_pages( $podpath, $config->{pages} ) ) {
        my ($sectionfile, $sectiontext) = @{$_};

        my $podfile  = "$podpath/$sectionfile.pod";
        my $htmlfile = "$sectionfile.html";
        push( @sidelinks, {
                filename => $htmlfile,
                text     => $sectiontext,
            } );
        push( @podfiles, {
                section  => $sectiontext,
                podfile  => $podfile,
                htmlfile => $htmlfile,
            } );
    }

    for my $vars ( @podfiles ) {
        $vars->{content} = App::Podium::pod2html( $vars->{podfile} );
        $vars->{sidelinks} = \@sidelinks;
        $tt->process( 'page.ttml', $vars, $vars->{htmlfile} ) || die $tt->error;
    }

    return;
}

1; # End of App::Podium
