# Jay

[![Build Status](https://travis-ci.org/czechboy0/Jay.svg?branch=master)](https://travis-ci.org/czechboy0/Jay)
[![Latest Release](https://img.shields.io/github/release/czechboy0/jay.svg)](https://github.com/czechboy0/jay/releases/latest)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-swiftpm%20%7C%20CocoaPods-yellow.svg)

[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

> Pure-Swift JSON parser. Linux &amp; OS X ready. Replacement for NSJSONSerialization.

JSON Spec: Implemented from [RFC4627](http://www.ietf.org/rfc/rfc4627.txt)

# :question: Why?
We all use JSON. Especially when writing server-side Swift that needs to run on Linux. `#0dependencies`

`NSJSONSerialization` is not yet fully implemented in the Swift standard libraries, so this is my take on how parsers should work. *This is not another JSON mapping utility library.* This is an actual **JSON parser**. Check out the code, it was fun to write 😇

# Features
- [x] Parsing of JSON object from data
- [ ] Formatting a JSON object into data

# Usage
```swift
do {
	//get data from disk/network
	let data: [UInt8] = ...

	//ask Jay to parse your data
	let json = try Jay().jsonFromData(data)

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

# Installation

## Swift Package Manager

```swift
.Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 0)
```
## CocoaPods

```
pod 'Jay'
```

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)