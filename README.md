# burakbasci.de

Portfolio website of Burak Basci, built with Flutter web. Live at
https://www.burakbasci.de (GitHub Pages); `burakbasci.de` redirects there.

## Branches

| branch   | content                                              |
|----------|------------------------------------------------------|
| `source` | the Flutter project - work here                      |
| `main`   | the built site, served by GitHub Pages (do not edit) |

## Working on the site

```
git clone -b source git@github.com:burak-basci/burak-basci.github.io.git
flutter pub get
flutter run -d chrome
```

Flutter version: the one pinned in `.github/workflows/main.yml` (3.44.4 at the time of writing; that workflow builds every push as a check).

## Deploying

```
tools/deploy.sh
```

Builds `web/` and pushes the result to `main`; static files under `web/`
(favicons, `signatur/` used by the e-mail signature, `robots.txt`, `sitemap.xml`)
are carried over as they are.

## Credits

Originally forked from [David Cobbina's Flutter portfolio](https://github.com/david-legend/david-legend.github.io),
inspired by [Julius Guevarra's design on Behance](https://www.behance.net/gallery/63574251/Personal-Portfolio-Website-Design).
