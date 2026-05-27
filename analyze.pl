#!/usr/bin/env perl
use strict;
use warnings;

my $re = qr/^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) [^"]*" (\d+) (\d+|-)/;

if (@ARGV != 1) {
    print STDERR "usage: $0 access.log\n";
    exit 1;
}

my $file = $ARGV[0];
open my $fh, '<', $file or die "cannot open: $file";
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ $re) {
        my ($ip, $time, $method, $url, $status, $bytes) = ($1, $2, $3, $4, $5, $6);
        if ($bytes eq '-') { $bytes = 0; }
        print "MATCH ip=$ip time=$time method=$method url=$url status=$status bytes=$bytes\n";
    } else {
        print "NO MATCH: $line\n";
    }
}
close $fh;
