package App::Podium::PSH;

# Subclassing Pod::Simple::HTML:
# http://search.cpan.org/~arandal/Pod-Simple-3.05/lib/Pod/Simple/Subclassing.pod

use base 'Pod::Simple::HTML';

our $VERSION = '0.01';

sub new {
    my $self = shift->SUPER::new(@_);

    my @passthru = qw( P M ); # P = Perldoc, M = Module
    $self->accept_codes( @passthru );

    my $tagmap = $self->{Tagmap};

    for my $code ( @passthru ) {
        $tagmap->{$code} = "$code<";
        $tagmap->{"/$code"} = ">";
    }

    $tagmap->{'VerbatimFormatted'} =
        qq{\n<pre class="prettyprint lang-perl">\n};

    return $self;
}

1;
