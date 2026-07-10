> Find processes occupying a given port

# lsofi [![stability][0]][1]

[![npm version][6]][7] [![CI][8]][9]

## Rationale

- `lsof -i :<port>` for unix, darwin and win32 alike

## Installation

```bash
npm install --save lsofi
```

## Usage

### ESM

```js
import lsofi from 'lsofi'

const occupied = await lsofi(1337)
const free = await lsofi(1338)

console.log(occupied, free)
// => 9834 null
```

### CommonJS

```js
const lsofi = require('lsofi')

const occupied = await lsofi(1337)
const free = await lsofi(1338)

console.log(occupied, free)
// => 9834 null
```

## Migration Notes

- Minimum supported Node.js version is now `20.0.0`.
- Package now ships dual entry points using `exports`:
  - `import lsofi from 'lsofi'` (ESM)
  - `require('lsofi')` (CommonJS compatibility)
- Runtime dependencies removed:
  - `is-number`: replaced with native `Number()` and `Number.isFinite()` validation.
  - `through2`: replaced with native stream parsing via `readline`.

## See also

- [krampus](https://github.com/marionebl/krampus) - Kill processes occupying a given port

---
lsofi is built by [marionebl](https://github.com/marionebl) and [contributors](https://github.com/marionebl/lsofi/graphs/contributors). It is released under the [MIT](https://github.com/marionebl/lsofi/blob/master/LICENSE) license.

[0]: https://img.shields.io/badge/stability-experimental-orange.svg?style=flat-square
[1]: https://nodejs.org/api/documentation.html#documentation_stability_index
[6]: https://img.shields.io/npm/v/lsofi.svg?style=flat-square
[7]: https://npmjs.org/package/lsofi
[8]: https://img.shields.io/github/actions/workflow/status/marionebl/lsofi/ci.yml?branch=master&style=flat-square
[9]: https://github.com/marionebl/lsofi/actions/workflows/ci.yml
