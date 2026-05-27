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

    sub top_n {
        my ($counts, $n) = @_;
        my @keys = sort { $counts->{$b} <=> $counts->{$a} } keys %$counts;
        @keys = @keys[0 .. $n - 1] if @keys > $n;
        return { map { $_ => $counts->{$_} } @keys };
    }

    return {
        total_requests => $total_requests,
        total_bytes => $total_bytes,
        skipped => $skipped,
        top_ips => top_n(\%ip_count, 10),
        top_urls => top_n(\%url_count, 10),
        status_counts => top_n(\%status_count, 10),
    };
}

1;