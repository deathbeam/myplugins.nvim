# Changelog

## [0.7.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.6.0...v0.7.0) (2025-08-26)


### Features

* **difftool:** disable rename detection by default ([#12](https://github.com/deathbeam/myplugins.nvim/issues/12)) ([9723854](https://github.com/deathbeam/myplugins.nvim/commit/9723854e57b39c7ca8fd9420d643dd2561380739))

## [0.6.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.5.0...v0.6.0) (2025-08-24)


### Features

* **bookmarks:** use native marks for bookmarks ([#8](https://github.com/deathbeam/myplugins.nvim/issues/8)) ([d73b228](https://github.com/deathbeam/myplugins.nvim/commit/d73b228ddc7fa4b6db709070773f2ea48d98bf0d))
* **diftool:** improve performance and delay initialization ([e697061](https://github.com/deathbeam/myplugins.nvim/commit/e697061afd639880bcaeb68f3048ef522798ad93))


### Bug Fixes

* **difftool:** improve performance slightly more ([#11](https://github.com/deathbeam/myplugins.nvim/issues/11)) ([cc5c06a](https://github.com/deathbeam/myplugins.nvim/commit/cc5c06aabe90f3f02d3b21db783515421b253e49))
* **difftool:** use current quickfix index for diff entry ([bf8a96c](https://github.com/deathbeam/myplugins.nvim/commit/bf8a96c92c9744f7635e60c3ff7e001157fc4f75))

## [0.5.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.4.1...v0.5.0) (2025-08-09)


### Features

* **lsp:** add lspdocs and rename signature to lspsignature ([4f90e09](https://github.com/deathbeam/myplugins.nvim/commit/4f90e09207e1118dac33c1e1dd8062c2f056c0a3))

## [0.4.1](https://github.com/deathbeam/myplugins.nvim/compare/v0.4.0...v0.4.1) (2025-08-07)


### Bug Fixes

* **plugin:** improve error reporting and httpyac exec cwd ([f1e4b3e](https://github.com/deathbeam/myplugins.nvim/commit/f1e4b3e3ac1a00cc8bc56753874d0ae5cbdf5462))

## [0.4.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.3.0...v0.4.0) (2025-04-16)


### Features

* improve http buffer display and error handling ([2ad781c](https://github.com/deathbeam/myplugins.nvim/commit/2ad781c63bf220eecaf901a6a3a5614c4f52b35c))
* **rooter:** add exrc markers ([45b3e48](https://github.com/deathbeam/myplugins.nvim/commit/45b3e48bbddc51d5c12818347b3c5082429d70c0))


### Bug Fixes

* add error handler to buffer completion callback ([9726738](https://github.com/deathbeam/myplugins.nvim/commit/9726738c89dcf303d3dd6e692a194069ceca5ad7))

## [0.3.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.2.1...v0.3.0) (2025-03-28)


### Features

* add --no-color flag to httpyac command ([80cc2a7](https://github.com/deathbeam/myplugins.nvim/commit/80cc2a7fc5c452b673a948b12b07229dc8b26b7e))
* **httpyac:** add plugin for running http files ([6fe5032](https://github.com/deathbeam/myplugins.nvim/commit/6fe50329ee3d2bd1dce0efd151d5002fea81258e))
* remove cursorhold diagnostic float ([86d847b](https://github.com/deathbeam/myplugins.nvim/commit/86d847bcc820536781ed1288d2b4f5a179411dae))
* **ui:** add window zoom toggle functionality ([05f2bbc](https://github.com/deathbeam/myplugins.nvim/commit/05f2bbc2d3377b05eccea03f5826814c53ab8b27))

## [0.2.1](https://github.com/deathbeam/myplugins.nvim/compare/v0.2.0...v0.2.1) (2025-03-18)


### Bug Fixes

* add missing setup function to bookmarks plugin ([2b6b677](https://github.com/deathbeam/myplugins.nvim/commit/2b6b6772c04a6ad085a496eb84ab309e17285361))

## [0.2.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.1.0...v0.2.0) (2025-03-18)


### Features

* add bookmarks plugin using quickfix lists ([dd67324](https://github.com/deathbeam/myplugins.nvim/commit/dd67324f9b6037de0a379198e209a21ccf6361b7))
* **session:** save and restore quickfix lists with sessions ([1bf137c](https://github.com/deathbeam/myplugins.nvim/commit/1bf137ccdff8ae43e70b1548a736a3e6e85be9cc))


### Bug Fixes

* handle empty quickfix list in bookmark navigation ([b0be3c8](https://github.com/deathbeam/myplugins.nvim/commit/b0be3c89f779725341a52a768c4b316e208314dd))
* improve LSP completion fallback handling ([aab6832](https://github.com/deathbeam/myplugins.nvim/commit/aab6832050afb461753bfb82c06b2d6d34f08c74))

## [0.1.0](https://github.com/deathbeam/myplugins.nvim/compare/v0.0.1...v0.1.0) (2025-03-15)


### Features

* **cmdcomplete:** add compatibility check for Neovim 0.11.0 ([67c93b3](https://github.com/deathbeam/myplugins.nvim/commit/67c93b328e1590225aa822cc4c65bd3fe468faaa))
