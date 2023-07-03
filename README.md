# AdobeXD MacOS Quick Look Plugin

Enables previews of XD files [(Adobe Experience Designer)][adobe-xd].

[QL plugin discussion][ql-win-issue].

[XD format reference][xd-format-reference].

<!--
## Install

If you want to skip compilation and just install it, [download Release X][quick-look-xd-releases], unzip and copy `QuickLookXD.qlgenerator` to `~/Library/QuickLook/`. To reach that folder in Finder, go to your Home, click on the Go menu on the top bar, hold the Option key and `Library` will magically appear.

Or copy it from a terminal:

```sh
cp -R QuickLookXD.qlgenerator ~/Library/QuickLook/
```

Alternatively, if you use [Homebrew-Cask](https://github.com/caskroom/homebrew-cask), install with:

```sh
brew cask install quicklookxd
```
-->

## Notes

How to find the UTI of a file:

```sh
$ mdls -name kMDItemContentType ./docs/example/file01.xd
kMDItemContentType = "com.adobe.xd.project"
```

## Demo

![Image showing list of files with an XD file in preview](./docs/example/screenshot01.png)

![Image showing list of XD files with thumbnail previews](./docs/example/screenshot02.png)

<!-- Links -->

[adobe-xd]: https://www.adobe.com/ca/products/xd.html
[xd-format-reference]: https://docs.fileformat.com/web/xd
[ql-win-issue]: https://github.com/QL-Win/QuickLook/issues/307#issuecomment-1473989813
