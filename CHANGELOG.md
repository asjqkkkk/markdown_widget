### [2.3.2+]
- 2.3.2+1
  - Remove the use of `textScaleFactor`
- 2.3.2+2
  - Fix: [#143](https://github.com/asjqkkkk/markdown_widget/issues/143)
- 2.3.2+3
  - Fix: richTextBuilder not working
- 2.3.2+4
  - Upgrade dependencies version
  - Fix [#159](https://github.com/asjqkkkk/markdown_widget/issues/159)
- 2.3.2+5
- 2.3.2+6
  - Fix static analysis issues

### [2.3.2]
- Feat: auto check code language and show it
- Feat: add `RichTextBuilder`
- Update README
- Fix: sub lists flexible layout

### [2.3.1]
- Fix: config not used in markdown widget

### [2.3.0]
- Fixed some issue
  - [#116](https://github.com/asjqkkkk/markdown_widget/issues/116)
  - [#117](https://github.com/asjqkkkk/markdown_widget/issues/117)
- Reopen some issue
  - [#95](https://github.com/asjqkkkk/markdown_widget/issues/95)
  - [#105](https://github.com/asjqkkkk/markdown_widget/issues/105)
- Updates minimum supported SDK version to Flutter 3.10/Dart 3.0 
- Remove `MarkdownGeneratorConfig`
- Update README

### [2.2.0]
- Fixed some issue
  - [#91](https://github.com/asjqkkkk/markdown_widget/issues/91)
  - [#95](https://github.com/asjqkkkk/markdown_widget/issues/95)
  - [#98](https://github.com/asjqkkkk/markdown_widget/issues/98)
  - [#104](https://github.com/asjqkkkk/markdown_widget/issues/104)
  - [#105](https://github.com/asjqkkkk/markdown_widget/issues/105)
- Added `MarkdownBlock` that will adapt to the width automatically
- Added `styleNotMatched` within `PreConfig` 

### [2.1.0]
- Added several examples to illustrate how to use custom tags and nodes, such as LaTeX and certain custom HTML tags.
- Added showcases for desktop, mobile, and web platforms in the README.
- Added a showcase for the Select All and Copy function in the README.
- Fixed incorrect address references in the README.
- Replaced some images in the examples with local images to resolve cross-domain issues in the web demo.
- Added release files to GitHub action.
- Added a screenshot description to the YAML file
- Added a copy button to the code block and removed its default padding.
- Added left and right scrolling and increased padding to the table.
- Fixed the TOC function in mobile mode.


### [2.0.0+1] 
- fix README error

### [2.0.0] 
- The entire code has been completely redesigned according to the [CommonMark Spec 3.0](https://spec.commonmark.org/0.30/) compared to the 1.x versions. This brings a lot of breaking changes, but also more standardized markdown rendering logic and more robust and scalable code

### [1.3.0+2] 
- fix textStyle not working for `pre` config 

### [1.3.0+1] 
- fix static analysis issues

### [1.3.0]
- support flutter 3.3
- embedded `scrollable_positioned_list` until it publishes new version
- fix some issues
    - [#2](https://github.com/asjqkkkk/markdown_widget/issues/2)
    - [#68](https://github.com/asjqkkkk/markdown_widget/issues/68)
    - [#70](https://github.com/asjqkkkk/markdown_widget/issues/70)

### [1.2.9] 
- support flutter 3.0

### [1.2.8] 
- get tag widget from class instead of function

### [1.2.7] 
- update dependencies

### [1.2.6-
nullsafety] - migrating to null safety

### [1.2.6] 
- modify some description in README, upgrade `video_player` dependencies

### [1.2.5] 
- update markdown package to fix the [issue](https://github.com/dart-lang/markdown/issues/300), remove `chewie` package

### [1.2.4] 
- update dependencies

### [1.2.3] 
- add comments for some methods, merge pr [#42](https://github.com/asjqkkkk/markdown_widget/pull/42)

### [1.2.2] 
- fix issue [#36](https://github.com/asjqkkkk/markdown_widget/issues/36), expose some properties in `TocController` by [#40](https://github.com/asjqkkkk/markdown_widget/pull/40)

#### [1.2.1+2] - add `padding` property to `MarkdownWidget` (thanks to @[jarekb123](https://github.com/jarekb123)). It adds ability to set custom padding of under-the-hood scrollable view.

#### [1.2.1+1] - expose `tocList` and `currentToc` properties in `TocController` (thanks to @[jarekb123](https://github.com/jarekb123)). It adds ability to create custom Table of Content widgets

### [1.2.1] 
-  fix issue [#25](https://github.com/asjqkkkk/markdown_widget/issues/25) [#28](https://github.com/asjqkkkk/markdown_widget/issues/28) [#29](https://github.com/asjqkkkk/markdown_widget/issues/29) [#32](https://github.com/asjqkkkk/markdown_widget/issues/32)

### [1.2.0] 
-  add `TextConfig` to set `TextAlign` and `TextDirection`,solve issue [#21](https://github.com/asjqkkkk/markdown_widget/issues/21)

### [1.1.9] 
-  add `initialIndex` and `isInitialIndexForTitle` in `TocController` to solve [#22](https://github.com/asjqkkkk/markdown_widget/issues/22)

### [1.1.8] 
-  add some property to `MarkdownWidget`, fix `PreWidget` null error

### [1.1.7] 
-  make PreWidget match its parent's size

### [1.1.6] 
-  add `text` to `PreWrapper`

### [1.1.5] 
-  add `PreWrapper`, and **HighlightCode** can be automatically detected with null `language`

### [1.1.4] 
- fix issue [#13](https://github.com/asjqkkkk/markdown_widget/issues/13) and [#16](https://github.com/asjqkkkk/markdown_widget/issues/16), deprecated `compute` function

### [1.1.3] 
- add `loadingWidget` before data is ready, improve performance in the first rendering

### [1.1.2] 
- support dark mode now! see issue [#12](https://github.com/asjqkkkk/markdown_widget/issues/12)

### [1.1.1] 
- offer custom html tag to user, fix issue [#8](https://github.com/asjqkkkk/markdown_widget/issues/8)

### [1.1.0] 
- fix issue [#6](https://github.com/asjqkkkk/markdown_widget/issues/6)

### [1.0.9] 
- add `LinkGesture` to  `PConfig` to fix issue [#4](https://github.com/asjqkkkk/markdown_widget/issues/4)

### [1.0.8] 
- add `CommonStyle` to title, add `selectable` to `PConfig`

### [1.0.7] 
- fix `ImgBuilder` send a null image url

### [1.0.6] 
- fix `ImgBuilder` not working correctly

### [1.0.5] 
- Add `CodeConfig`, format code and change `markdown_widget` description

### [1.0.4] 
- Add `ImgConfig`, Improve code description and online demo

### [1.0.3] 
- Fix `TocListWidget` data error in mobile, edit README

### [1.0.2] 
- Reduce the difficulty of TOC function, improve the basic functions of the package

### [1.0.1] 
- Add `ImgConfig`, clear data when markdown_widget rebuild

### [1.0.0] 
- Complete base functions
