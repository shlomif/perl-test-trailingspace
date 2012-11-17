use strict;
use warnings;
package Test::TrailingSpace;

use autodie;

use Test::More;

use File::Find::Object::Rule 0.0301;

our $VERSION = '0.0103';

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

sub _filename_regex
{
    my $self = shift;

    if (@_)
    {
        $self->{_filename_regex} = shift;
    }

    return $self->{_filename_regex};
}

sub _root_path
{
    my $self = shift;

    if (@_)
    {
        $self->{_root_path} = shift;
    }

    return $self->{_root_path};
}
sub _init
{
    my ($self, $args) = @_;

    $self->_root_path(exists($args->{root}) ? $args->{root} : '.');
    $self->_filename_regex($args->{filename_regex});

    return;
}

sub no_trailing_space
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($self, $blurb) = @_;

    my $num_found = 0;

    my $subrule = File::Find::Object::Rule->new;

    my $rule = $subrule->or(
        $subrule->new->directory->name(qr/(?:\A|\/)(?:blib|_build|CVS|\.svn|\.bzr\.hg|\.git)\z/)->prune->discard,
        $subrule->new->file()->name($self->_filename_regex())
    )->start( $self->_root_path() );

    while ( my $path = $rule->match() )
    {
        open my $fh, '<', $path;
        LINES:
        while (my $line = <$fh>)
        {
            chomp($line);
            if ($line =~ /[ \t]+\r?\z/)
            {
                $num_found++;
                diag ("Found trailing space in file '$path'");
                last LINES;
            }
        }
        close ($fh);
    }

    return is ($num_found, 0, $blurb);
}

1;

__END__

=encoding utf-8

=head1 NAME

Test::TrailingSpace - test for trailing space in source files.

=head1 SYNOPSIS

    use Test::TrailingSpace;

    my $finder = Test::TrailingSpace->new(
        {
            root => '.',
            filename_regex => qr/\.(?:t|pm|pl)\z/,
        },
    );

    # TEST
    $finder->no_trailing_space(
        "No trailing space was found."
    );

Or, if you want the test to be optional:

    use Test::More;

    eval "use Test::TrailingSpace";
    if ($@)
    {
        plan skip_all => "Test::TrailingSpace required for trailing space test.";
    }
    else
    {
        plan tests => 1;
    }

    my $finder = Test::TrailingSpace->new(
        {
            root => '.',
            filename_regex => qr/\.(?:t|pm|pl)\z/,
        },
    );

    # TEST
    $finder->no_trailing_space(
        "No trailing space was found."
    );




=head1 DESCRIPTION

This module is used to test for lack of trailing space. See the synopsis
for more details.

B<NOTE:> there is an older CPAN distribution titled L<Test::EOL> that also
supports testing for trailing space / trailing whitespace, although it
has some limitations that L<Test::TrailingSpace> does not have, and also
only calls it "trailing whitespace", rather than "trailing space".
Whenever possible, one should prefer to use it, instead of this module.

=head1 METHODS

=head2 new({ root => ".", filename_regex => qr/\. ... \z/,})

Constructs a new object with the root (that defaults to "." and
the filename matching regular expression. All the files under root
matching the pattern will be searched (excpet for those under version
control directories, "blib", "_build", etc.).

=head2 $finder->no_trailing_space($blurb)

Determines if there is no trailing space in the source files. Returns true
no trailing space was found and false if trailing space was found.
It is equivalent to Test::More::ok(), with diagnostics to report if there is
trailing space.

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 SEE ALSO

=over 4

=item * Test::EOL

L<Test::EOL>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2012 Shlomi Fish.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut
