package App::Podium;

use warnings;
use strict;

=head1 NAME

App::Podium - Helper functions for the podium app.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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


1; # End of App::Podium
