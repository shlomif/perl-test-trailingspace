#!/usr/bin/perl

use strict;
use warnings;

use lib './t/lib';

use Test::Builder::Tester tests => 3;

use File::Path qw( rmtree );

use File::Find::Object::TreeCreate;
use Test::TrailingSpace;

{
    my $test_id = "no-trailing-space-1";
    my $test_dir = "t/sample-data/$test_id";
    my $tree =
    {
        'name' => "$test_id/",
        'subs' =>
        [
            {
                'name' => "a/",
                subs =>
                [
                    {
                        'name' => "b.pm",
                        'contents' => "This file was spotted in the wild.",
                    },
                ],
            },
            {
                'name' => "foo/",
                'subs' =>
                [
                    {
                        'name' => "t.door.txt",
                        'contents' => "A T Door",
                    },
                    {
                        'name' => "yet/",
                    },
                ],
            },
        ],
    };

    my $t = File::Find::Object::TreeCreate->new();
    $t->create_tree("./t/sample-data/", $tree);

    my $finder = Test::TrailingSpace->new(
        {
            root => "./$test_dir",
            filename_regex => qr/\.(?:pm|txt)\z/,
        }
    );

    test_out("ok 1 - no trailing space FOO");
    $finder->no_trailing_space("no trailing space FOO");
    test_test("no trailing space was reported");
    rmtree($t->get_path("./$test_dir"))
}

{
    my $test_id = "with-trailing-space-1";
    my $test_dir = "t/sample-data/$test_id";
    my $tree =
    {
        'name' => "$test_id/",
        'subs' =>
        [
            {
                'name' => "a/",
                subs =>
                [
                    {
                        'name' => "b.pm",
                        'contents' =>
                        "This file.    \nI don't like it.",
                    },
                ],
            },
            {
                'name' => "foo/",
                'subs' =>
                [
                    {
                        'name' => "t.door.txt",
                        'contents' => "A T Door",
                    },
                    {
                        'name' => "yet/",
                    },
                ],
            },
        ],
    };

    my $t = File::Find::Object::TreeCreate->new();
    $t->create_tree("./t/sample-data/", $tree);

    my $finder = Test::TrailingSpace->new(
        {
            root => "./$test_dir",
            filename_regex => qr/\.(?:pm|txt)\z/,
        }
    );

    test_out("not ok 1 - with trailing space CLAM");
    test_fail(+1);
    $finder->no_trailing_space("with trailing space CLAM");
    test_test(title => "with trailing space was reported", skip_err => 1,);
    rmtree($t->get_path("./$test_dir"))
}

{
    my $test_id = "no-trailing-space-2";
    my $test_dir = "t/sample-data/$test_id";
    my $tree =
    {
        'name' => "$test_id/",
        'subs' =>
        [
            {
                'name' => "a/",
                subs =>
                [
                    {
                        'name' => "b.pm",
                        'contents' => "This file was spotted in the wild.",
                    },
                ],
            },
            {
                'name' => "foo/",
                'subs' =>
                [
                    {
                        'name' => "t.door.txt",
                        'contents' => "A T Door",
                    },
                    {
                        'name' => "yet/",
                    },
                ],
            },
            {
                'name' => "lib/",
                subs =>
                [
                    {
                        'name' => "foo.pm",
                        'contents' => "File with trailing space     \nhello\n",
                    }
                ],
            },
        ],
    };

    my $t = File::Find::Object::TreeCreate->new();
    $t->create_tree("./t/sample-data/", $tree);

    my $finder = Test::TrailingSpace->new(
        {
            root => "./$test_dir",
            filename_regex => qr/\.(?:pm|txt)\z/,
            abs_path_prune_re => qr#(?:\A|/)lib/#ms,
        }
    );

    test_out("ok 1 - no trailing space BAR");
    $finder->no_trailing_space("no trailing space BAR");
    test_test("no trailing space was reported");
    rmtree($t->get_path("./$test_dir"))
}
