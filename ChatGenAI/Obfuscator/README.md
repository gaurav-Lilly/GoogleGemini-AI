# LillyObfuscator

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [Installation](#installation)
- [Example](#example)
  - [Vega](#vega)
- [Links](#links)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

- Add Lilly source in `Podfile`: `source 'https://github.com/EliLillyCo/PDS_DDRD_Podspecs.git'`
- Add `LillyObfuscator` in `Podfile`: `pod 'LillyObfuscator'`
- Run `pod install`

## Example

Run unit tests in `LillyObfuscator` to see the basic usable.

### Vega

This section shows how we use `LillyObfuscator` in project `Vega`.

1. In `Constants -> EnvConst`, we had plain strings like `enum { static let iv = "w5a3sse8asdfasdfasdfef2y2p2rhbg" }`; there's a copy in `VegaTests -> EnvRepositoryTests -> Keys` too.
2. To obfuscate it, go to `VegaTests -> EnvRepositoryTests`, and enable the line with `self.sharedObfuscator.obfuscate`
3. Change it to `self.sharedObfuscator.obfuscate(string: Keys.MMAID.iv, isPrintable: true)`
4. Run testing: `Command+U`
5. Because obfuscation is enabled, tests will stop at an `assertionFailure`
6. In console, you will find generated code like `static let RENAME_ME_OBFUSCATED = obfuscator.reveal(obfuscated: [11, 22, 33, 44, ...])`
7. Replace the string in item #1 with the one in item #6
8. Add a new test case `expect(EnvRepository.MMAID.iv).to(equal(Keys.MMAID.iv))`
9. Disable line in #2
10. Re-run unit tests to make sure revealed string is the same as the original one

To add a new constant, add it in `enum Keys`, obfuscate it, and add it in places like `EnvConst` in target Vega. Original string should only be complied in test target(s), which won't be included in archived `ipa`.

## Links

- [Changelog](CHANGELOG.md)
- [License](LICENSE.md)