# Jay

[![Build Status](https://travis-ci.org/czechboy0/Jay.svg?branch=master)](https://travis-ci.org/czechboy0/Jay)
[![Latest Release](https://img.shields.io/github/release/czechboy0/jay.svg)](https://github.com/czechboy0/jay/releases/latest)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-swiftpm%20%7C%20CocoaPods-yellow.svg)

[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

> Pure-Swift JSON parser & formatter. Linux &amp; OS X ready. Replacement for NSJSONSerialization.

Jay conforms to the following specifications:
- JSON [RFC4627](http://www.ietf.org/rfc/rfc4627.txt)

# :question: Why?
We all use JSON. Especially when writing server-side Swift that needs to run on Linux. `#0dependencies`

`NSJSONSerialization` is not yet fully implemented in the Swift standard libraries, so this is my take on how parsers should work. *This is not another JSON mapping utility library.* This is an actual **JSON parser** and **formatter**. Check out the code, it was fun to write 😇

# Features
- [x] Parsing: data -> JSON object
- [x] Formatting: JSON object -> data

# Usage

## Parsing from data
```swift
do {
	//get data from disk/network
	let data: [UInt8] = ...

	//ask Jay to parse your data
	let json = try Jay().jsonFromData(data) // Any

	//if it doesn't throw an error, all went well
	if let dictionary = json as? [String: Any] {
		//you have a dictionary root object
	} else if let array = json as? [Any] {
		//you have an array root object
	}
} catch {
	print("Parsing error: \(error)")
}
```

## Formatting into data
```swift
do {
	//get a json object
	let json: [String: Any] = ... // [String: Any] or [Any]

	//ask Jay to generate data
	let data = try Jay().dataFromJson(json) // [UInt8]

	//send data over network, save to disk
} catch {
	print("Formatting error: \(error)")
}
```

# Installation

## Swift Package Manager

```swift
.Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 0)
```
## CocoaPods

```
pod 'Jay'
```

## Swift Versions
This project was originally created for a Swift server running on Linux, so it's always built (and assumes) the latest Swift and SwiftPM versions. To manage Swift versions easily, I recommend you use [swiftenv](https://github.com/kylef/swiftenv#installation). You can see which Swift version Jay requires at the moment in the [`.swift-version`](https://github.com/czechboy0/Jay/blob/master/.swift-version) file in the root of the repository. Please make sure you're always running at least that version if you want to use Jay in your project.

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)