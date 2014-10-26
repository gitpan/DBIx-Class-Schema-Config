#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::MockObject;
use DBIx::Class::Schema::Config;

Test::MockObject->fake_module(
    'Config::Any',
    'load_stems' => sub {
        return [
            {
                'some_file' => { 
                    SOME_DATABASE => {
                        dsn => 'dbi:SQLite:dbfile=:memory:',
                        user => 'MyUser',
                        pass => 'MyPass',
                    },
                    AWESOME_DB => {
                        dsn => 'dbi:mysql:dbname=epsilon', 
                        user => 'Bravo',
                        pass => 'ShiJulIanDav',
                    }
                },
                'some_other_file' => {
                    SOME_DATABASE => {
                        dsn => 'dbi:mysql:dbname=acronym', 
                        user => 'YawnyPants',
                        pass => 'WhyDoYouHateUs?',
                    },
                }
            }
        ]
    }
);

my $tests = [
    {
        put => { dsn => 'SOME_DATABASE', user => '', password => '' },
        get => {
                dsn => 'dbi:SQLite:dbfile=:memory:',
                user => 'MyUser',
                pass => 'MyPass',
        },
        title => "Get DB info from hashref.",
    },
    {
        put => [ 'SOME_DATABASE' ],
        get => {
                dsn  => 'dbi:SQLite:dbfile=:memory:',
                user => 'MyUser',
                pass => 'MyPass',
        },
        title => "Get DB info from array.",
    },
    {
        put => { dsn => 'AWESOME_DB' },
        get => {
                dsn  => 'dbi:mysql:dbname=epsilon', 
                user => 'Bravo',
                pass => 'ShiJulIanDav',
        },
        title => "Get DB from hashref without user and pass.",
    },
    {
        put => [ 'dbi:mysql:dbname=foo', 'username', 'password' ],
        get => {
            dsn  => 'dbi:mysql:dbname=foo',
            user => 'username',
            password => 'password',
            options => undef,
        },
        title => "Pass through of normal ->connect as array.",
    },
    {
        put => {
            dsn  => 'dbi:mysql:dbname=foo', 
            user => 'username', 
            password => 'password'
        },
        get => {
            dsn  => 'dbi:mysql:dbname=foo',
            user => 'username',
            password => 'password',
            options => {},
        },
        title => "Pass through of normal ->connect as hashref.",
    },


];

for my $test ( @$tests ) {
    is_deeply( 
        DBIx::Class::Schema::Config->load_credentials( 
            DBIx::Class::Schema::Config->_make_config(
                ref $test->{put} eq 'ARRAY' ? @{$test->{put}} : $test->{put})
        ), $test->{get}, $test->{title} );
}



done_testing;
