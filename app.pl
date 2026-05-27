#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use LogStats;

get '/' => sub {
    my $c = shift;
    $c->render(inline => <<'EOF');
<!doctype html><html><body>
<form action="/analyze" method="post" enctype="multipart/form-data">
<input type="file" name="logfile"><br>
<input type="submit" value="Analyze">
</form>
</body></html>
EOF
};

post '/analyze' => sub {
    my $c = shift;
    my $upload = $c->req->upload('logfile');
    my $results;

    if ($upload) {
        $results = LogStats::parse_log(scalar $upload->slurp);
    } else {
        $results = {
            total_requests => 0,
            total_bytes => 0,
            skipped => 0,
            top_ips => {},
            top_urls => {},
            status_counts => {}
        };
    }

    $c->stash(results => $results);
    $c->render('results');
};

app->start;
__DATA__
@@ results.html.ep
<!doctype html>
<html>
<head>
<style>
body {
    max-width: 800px;
    margin: 0 auto;
    font-family: monospace;
}
table {
    border-collapse: collapse;
    width: 100%;
}
table, th, td {
    border: 1px solid lightgray;
    padding: 5px;
}
.status-error {
    color: red;
}
</style>
</head>
<body>
<h2>Log Analysis Results</h2>

<h3>Totals</h3>
<p>
requests=<%= $results->{total_requests} %> 
bytes=<%= $results->{total_bytes} %> 
skipped=<%= $results->{skipped} %>
</p>

<h3>Top IPs</h3>
<table>
    <tr><th>IP</th><th>Count</th></tr>
    % for my $ip (sort { $results->{top_ips}{$b} <=> $results->{top_ips}{$a} } keys %{$results->{top_ips}}) {
        <tr><td><%= $ip %></td><td><%= $results->{top_ips}{$ip} %></td></tr>
    % }
</table>

<h3>Top URLs</h3>
<table>
    <tr><th>URL</th><th>Count</th></tr>
    % for my $url (sort { $results->{top_urls}{$b} <=> $results->{top_urls}{$a} } keys %{$results->{top_urls}}) {
        <tr><td><%= $url %></td><td><%= $results->{top_urls}{$url} %></td></tr>
    % }
</table>

<h3>Status Breakdown</h3>
<table>
    <tr><th>Status</th><th>Count</th></tr>
    % for my $status (sort { $results->{status_counts}{$b} <=> $results->{status_counts}{$a} } keys %{$results->{status_counts}}) {
        <tr class="<%= $status =~ /^[45]/ ? 'status-error' : '' %>">
            <td><%= $status %></td><td><%= $results->{status_counts}{$status} %></td>
        </tr>
    % }
</table>
</body>
</html>
