package App::Write::Index;
use 5.010;
use strict;
use warnings;
use Config;
use File::Find 'find';
use Getopt::Long qw(:config no_auto_abbrev no_ignore_case);
use JSON::PP;
use List::Util 'sum';
use Pod::Usage 'pod2usage';

our $VERSION = "0.01";

# header is copied from Carmel::App::write_index
sub write_index {
    my ($self, $fh, @distribution) = @_;

    my $count = sum(0, map { scalar(@{$_->{package}}) } @distribution) + 1;

    print $fh <<EOF;
File:         02packages.details.txt
URL:          http://www.perl.com/CPAN/modules/02packages.details.txt
Description:  Package names found in local directories
Columns:      package name, version, path
Intended-For: Automated fetch routines, namespace documentation.
Written-By:   @{[ sprintf "%s %s", __PACKAGE__, __PACKAGE__->VERSION ]}
Line-Count:   $count
Last-Updated: @{[ scalar localtime ]}

EOF

    for my $dist (@distribution) {
        my $pathname = $dist->{pathname};
        for my $package (@{ $dist->{package} }) {
        printf $fh "%-36s %-8s %s\n",
            $package->{name}, $package->{version} // 'undef', $pathname;
        }
    }
}

sub new { bless {}, shift }

sub parse_options {
    my ($self, @argv) = @_;
    local @ARGV = @argv;
    GetOptions
        "h|help" => sub { pod2usage(0) },
        "v|version" => sub { printf "%s %s\n", __PACKAGE__, __PACKAGE__->VERSION; exit },
        "d|dir=s@" => \(my $dir = ["local"]),
    or pod2usage(1);
    $self->{dir} = $self->build_dir(@$dir);
    $self;
}

sub run {
    my ($self, $argv) = @_;
    my @install_json = $self->gather_install_json;
    my @distribution;
    for my $json (@install_json) {
        my $meta = decode_json do { local (@ARGV, $/) = $json; <> };
        push @distribution, {
            pathname => $meta->{pathname},
            package => [
                map +{
                    name => $_,
                    version => $meta->{provides}{$_}{version},
                }, sort keys %{$meta->{provides}}
            ],
        };
    }
    $self->write_index(\*STDOUT, @distribution);
}

sub gather_install_json {
    my $self = shift;
    my @install_json;
    find sub {
        return unless -f $_ && $_ eq "install.json";
        push @install_json, $File::Find::name;
    }, @{$self->{dir}};
    sort @install_json;
}

sub build_dir {
    my ($self, @dir) = @_;
    [ grep -d, map "$_/lib/perl5/$Config{archname}/.meta", @dir ];
}

1;
__END__

=encoding utf-8

=head1 NAME

App::Write::Index - write 02packages.details.txt for your local lib

=head1 SYNOPSIS

    > write-index

=head1 DESCRIPTION

C<write-index> writes 02packages.details.txt for your local lib.
You should look at https://github.com/miyagawa/Carmel

=head1 HOW TO USE

Let's assume your project has cpanfile.

In you local machine, install deps to local/ dir, and git-commit index.txt:

    [local] $ cpanm -Llocal --installdeps .
    [local] $ write-index > index.txt
    [local] $ git add index.txt && git commit -m 'add index.txt'

Then deployment time, install deps from index.txt:

    [remote] $ cpanm --mirror-index $PWD/index.txt -Llocal --installdeps .

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

