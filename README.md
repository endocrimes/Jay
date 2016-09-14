# Jay

[![Build Status](https://travis-ci.org/DanToml/Jay.svg?branch=master)](https://travis-ci.org/DanToml/Jay)
[![Latest Release](https://img.shields.io/github/release/DanToml/jay.svg)](https://github.com/DanToml/jay/releases/latest)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-SwiftPM-yellow.svg)

> Pure-Swift JSON parser & formatter. Fully streamable input and output. Linux &amp; OS X ready. Replacement for NSJSONSerialization.

Jay conforms to the following specifications:
- JSON [RFC4627](http://www.ietf.org/rfc/rfc4627.txt)
- [Open Swift C7 JSON](https://github.com/open-swift/C7/blob/master/Sources/JSON.swift) with the use of [Jay-C7](https://github.com/czechboy0/Jay-C7)

For extra convenience functions when working with the JSON enum, check out [Jay-Extras](https://github.com/czechboy0/Jay-Extras).

# :question: Why?
We all use JSON. Especially when writing server-side Swift that needs to run on Linux. `#0dependencies`

This is my take on how a JSON parser should work. *This is not another JSON mapping utility library.* This is an actual **JSON parser** and **formatter**. Check out the code, it was fun to write 😇

# Features
- [x] Parsing: data -> JSON object
- [x] Formatting: JSON object -> data
- [x] Pretty printing
- [x] Streaming input and output, low memory footprint

# Usage

## Parsing from data (deserialization)
```swift
do {
	//get data from disk/network
	let data: [UInt8] = ...

	//ask Jay to parse your data
	let json = try Jay().jsonFromData(data) // JSON
	//or
	let json = try Jay().anyJsonFromData(data) // [String: Any] or [Any]

	//if it doesn't throw an error, all went well
	if let tasks = json.dictionary?["today"]?.array {
	    //you have a dictionary root object, with an array under the key "today"
	    print(tasks) //["laundry", "cook dinner for gf"]
	} 
} catch {
	print("Parsing error: \(error)")
}
```

## Formatting into data (serialization)
```swift
do {
	//get a json object (works for both [String: Any] and typesafe versions - JSON)

	//ask Jay to generate data
	let anyContainer = ... // [String: Any] or [Any]
	let data = try Jay(formatting: .prettified).dataFromJson(any: json) // [UInt8]
	//or
	let json: JSON = ... // JSON
	let data = try Jay(formatting: .prettified).dataFromJson(json: json) // [UInt8]

	//send data over network, save to disk
} catch {
	print("Formatting error: \(error)")
}
```

# Installation

## Swift Package Manager

```swift
.Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 1)
```

:blue_heart: Code of Conduct
------------
Please note that this project is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)
