# Log Analyzer

Upload an Apache/Nginx access log, get back the stats. A small Perl web app.

## What it shows

- Top 10 IPs by request count
- Top 10 requested URLs
- Status code breakdown (200 / 404 / 500 / ...)
- Total requests + total bytes transferred

## Stack

- Perl 5 + [Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite) (single file)
- No database — parse on upload, render, done
- Plain HTML + a little CSS, no JavaScript

## Run it

```bash
# one-time setup
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm Mojolicious

# CLI
perl analyze.pl access.log

# web app
morbo app.pl        # dev server, http://127.0.0.1:3000
```

See [PLAN.md](PLAN.md) for the build order and scope.
