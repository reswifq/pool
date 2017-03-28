# Pool

![Swift](https://img.shields.io/badge/swift-3.1-brightgreen.svg)
[![Build Status](https://api.travis-ci.org/reswifq/pool.svg?branch=master)](https://travis-ci.org/reswifq/pool)
[![Code Coverage](https://codecov.io/gh/reswifq/pool/branch/master/graph/badge.svg)](https://codecov.io/gh/reswifq/pool)

A generic object pool implementation for Swift that works on macOS and Linux.

## 🏁 Getting Started

#### Import Pool into your project using [Swift Package Manager](https://swift.org/package-manager):

``` swift
import PackageDescription

let package = Package(
    name: "YourProject",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/reswifq/pool.git", majorVersion: 1)
    ]
)
```

#### Create a pool of elements:

``` swift
let pool = Pool(maxElementCount: 10) { 
	return "I am a pool element"
}
```

#### Draw an element from the pool:

``` swift
let element = try pool.draw()
```

#### Do something with it:

``` swift
print(element) // "I am a pool element"
```

#### Put it back in the pool, so it can be reused:

``` swift
pool.release(element)
```

#### Optionally you can wait until it has been released:

``` swift
pool.release(element) {
	print("element has been released and it's ready to be drawn again")
}
```

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.

## 📖 License

Created by [Valerio Mazzeo](https://github.com/valeriomazzeo).

Copyright © 2017 [VMLabs Limited](https://www.vmlabs.it). All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the [GNU Lesser General Public License](http://www.gnu.org/licenses) for more details.
