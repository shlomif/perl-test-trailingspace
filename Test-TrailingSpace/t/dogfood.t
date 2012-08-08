
use strict;
use warnings;

use Test::More tests => 1;

use Test::TrailingSpace;

my $finder = Test::TrailingSpace->new(
    {
        root => '.',
        filename_regex => qr/(?:\.(?:t|pm|pl|PL|yml|json))|README|Changes\z/,
    },
);

# TEST
$finder->no_trailing_space(
    "No trailing space was found."
);

