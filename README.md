# aaronweiss.us

This is the latest iteration of my personal website. It's powered proudly by [Hakyll][hakyll], and
hosted on [GitHub Pages][gh-pages]. You can find the production website [here][awe].

## Building the Site

With [`stack`][stack] installed, you can build the site from the shell:
```fish
stack exec site build
```

Or you can run a local server that rebuilds on file system update like so:
```fish
stack exec site watch
```

## Licensing

The code that powers this website (e.g. `css/`, `templates/`, and `site.hs`) is in the public domain
(via the [CC0][cc0] dedication), but the content (e.g. `posts/`, `pubs/`, and `images/`) remain
under their respective licenses (defaulting to all rights reserved).

[awe]: https://aaronweiss.us/
[hakyll]: http://jaspervdj.be/hakyll/
[gh-pages]: https://pages.github.com/
[stack]: https://haskellstack.org/
[cc0]: https://creativecommons.org/share-your-work/public-domain/cc0/
