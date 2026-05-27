#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;

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
    if ($upload) {
        $c->render(text => "got file " . $upload->filename . " size " . $upload->size);
    } else {
        $c->render(text => "no file");
    }
};

app->start;
__DATA__
@@ notused.html.ep
