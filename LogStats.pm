package LogStats;
use strict;
use warnings;

my $re = qr/^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) [^"]*" (\d+) (\d+|-)/;

sub parse_log {
    my ($log_text) = @_;
    
    my %ip_count;
    my %url_count;
    my %status_count;
    my $total_requests = 0;
    my $total_bytes = 0;
    my $skipped = 0;

    my @lines = split("\n", $log_text);
    
    for my $line (@lines) {
        chomp $line;
        if ($line =~ $re) {
            my ($ip, $time, $method, $url, $status, $bytes) = ($1, $2, $3, $4, $5, $6);
            if ($bytes eq '-') { $bytes = 0; }
            $ip_count{$ip}++;
            $url_count{$url}++;
            $status_count{$status}++;
            $total_requests++;
            $total_bytes += $bytes;
        } else {
            $skipped++;
        }
    }

    my @top_ips = grep { $_ ne '' } sort { $ip_count{$b} <=> $ip_count{$a} } keys %ip_count;
    my @top_urls = grep { $_ ne '' } sort { $url_count{$b} <=> $url_count{$a} } keys %url_count;
    my @top_status = grep { $_ ne '' } sort { $status_count{$b} <=> $status_count{$a} } keys %status_count;

    return {
        total_requests => $total_requests,
        total_bytes => $total_bytes,
        skipped => $skipped,
        top_ips => { map { $_ => $ip_count{$_} } @top_ips[0..9] },
        top_urls => { map { $_ => $url_count{$_} } @top_urls[0..9] },
        status_counts => { map { $_ => $status_count{$_} } @top_status[0..9] },
    };
}

1;