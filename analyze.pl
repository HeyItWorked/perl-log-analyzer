#!/usr/bin/env perl
use strict;
use warnings;

my $re = qr/^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) [^"]*" (\d+) (\d+|-)/;

if (@ARGV != 1) {
    print STDERR "usage: $0 access.log\n";
    exit 1;
}

my %ip_count;
my %url_count;
my %status_count;
my $total_requests = 0;
my $total_bytes = 0;
my $skipped = 0;

my $file = $ARGV[0];
open my $fh, '<', $file or die "cannot open: $file";
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ $re) {
        my ($ip, $time, $method, $url, $status, $bytes) = ($1, $2, $3, $4, $5, $6);
        if ($bytes eq '-') { $bytes = 0; }
        $ip_count{$ip}++;
        $url_count{$url}++;
        $status_count{$status}++;
        $total_requests++;
        $total_bytes += $bytes;
        # debug print still here for now
        print "MATCH ip=$ip status=$status bytes=$bytes\n";
    } else {
        $skipped++;
        print "NO MATCH: $line\n";
    }
}
close $fh;

print "requests=$total_requests bytes=$total_bytes skipped=$skipped\n";

print "Top IPs:\n";
my @ips = sort { $ip_count{$b} <=> $ip_count{$a} } keys %ip_count;
for my $i (0..9) { last if $i > $#ips; my $k=$ips[$i]; print "  $k: $ip_count{$k}\n"; }

print "Top URLs:\n";
my @urls = sort { $url_count{$b} <=> $url_count{$a} } keys %url_count;
for my $i (0..9) { last if $i > $#urls; my $k=$urls[$i]; print "  $k: $url_count{$k}\n"; }

print "Status breakdown:\n";
my @sts = sort { $status_count{$b} <=> $status_count{$a} } keys %status_count;
for my $i (0..9) { last if $i > $#sts; my $k=$sts[$i]; print "  $k: $status_count{$k}\n"; }
