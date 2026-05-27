#!/usr/bin/env perl
use strict;
use warnings;
use LogStats;

if (@ARGV != 1) {
    print STDERR "usage: $0 access.log\n";
    exit 1;
}

my $file = $ARGV[0];
open my $fh, '<', $file or die "cannot open: $file";
my $log_text = do { local $/; <$fh> };
close $fh;

my $stats = LogStats::parse_log($log_text);

print "requests=$stats->{total_requests} bytes=$stats->{total_bytes} skipped=$stats->{skipped}\n";

print "Top IPs:\n";
for my $k (sort { $stats->{top_ips}{$b} <=> $stats->{top_ips}{$a} } keys %{$stats->{top_ips}}) {
    print "  $k: $stats->{top_ips}{$k}\n";
}

print "Top URLs:\n";
for my $k (sort { $stats->{top_urls}{$b} <=> $stats->{top_urls}{$a} } keys %{$stats->{top_urls}}) {
    print "  $k: $stats->{top_urls}{$k}\n";
}

print "Status breakdown:\n";
for my $k (sort { $stats->{status_counts}{$b} <=> $stats->{status_counts}{$a} } keys %{$stats->{status_counts}}) {
    print "  $k: $stats->{status_counts}{$k}\n";
}
