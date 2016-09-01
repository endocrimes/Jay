//
//  Jay.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//Implemented from scratch based on http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf and https://www.ietf.org/rfc/rfc4627.txt

public struct Jay {
  
    /// The formatting to apply to the `JSON`.
    public enum Formatting {
        case minified
        case prettified
    }
    
    public struct ParsingOptions: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let none = ParsingOptions(rawValue: 0)
        
        /// Allows single line (starting //) or multi-line (/* ... */) comments,
        /// strips them out during parsing.
        public static let allowComments = ParsingOptions(rawValue: 1 << 0)
    }
  
    /// The formatting used.
    public let formatting: Formatting
    
    /// Parsing options
    public let parsing: ParsingOptions
  
    /// Initializes and returns the `Jay` object.
    /// - Parameter formatting: The `Formatting` to use. Defaults to `.minified`.
    /// - Parameter parsing: The `ParsingOptions` to use. Defaults to `.none`.
    public init(formatting: Formatting = .minified, parsing: ParsingOptions = .none) {
        self.formatting = formatting
        self.parsing = parsing
    }
    
    /// Parses data into a dictionary `[String: Any]` or array `[Any]`.
    /// - Note: Does not allow fragments. Test by conditional
    /// casting whether you received what you expected.
    /// - Throws: A descriptive error in case of any problem.
    public func anyJsonFromData(_ data: [UInt8]) throws -> Any {
        return try NativeParser(options: parsing).parse(data)
    }
  
    /// Parses the reader to `Any`.
    /// - Throws: A descriptive error in case of any problem.
    public func anyJsonFromReader<R: Reader>(_ reader: R) throws -> Any {
        return try NativeParser(options: parsing).parse(reader)
    }
    
    /// Formats your JSON-compatible object into data.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(jsonWrapper: JaySON) throws -> [UInt8] {
        return try self.dataFromAnyJson(jsonWrapper.json)
    }

    /// Outputs the data from json to the provided stream.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(jsonWrapper: JaySON, output: JsonOutputStream) throws {
        try self.dataFromAnyJson(jsonWrapper.json, output: output)
    }

    /// Parses the json to data.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(anyDictionary: [String: Any]) throws -> [UInt8] {
        return try self.dataFromAnyJson(anyDictionary)
    }

    /// Outputs the data from json to the provided stream.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(anyDictionary: [String: Any], output: JsonOutputStream) throws {
        try self.dataFromAnyJson(anyDictionary, output: output)
    }

    /// Parses the json to data.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(anyArray: [Any]) throws -> [UInt8] {
        return try self.dataFromAnyJson(anyArray)
    }

    /// Outputs the data from json to the provided stream.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(anyArray: [Any], output: JsonOutputStream) throws {
        try self.dataFromAnyJson(anyArray, output: output)
    }

    /// Parses the json to data.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(any: Any) throws -> [UInt8] {
        return try self.dataFromAnyJson(any)
    }

    /// Outputs the data from json to the provided stream.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(any: Any, output: JsonOutputStream) throws {
        try self.dataFromAnyJson(any, output: output)
    }

    private func dataFromAnyJson(_ json: Any) throws -> [UInt8] {
        let output = ByteArrayOutputStream()
        try dataFromAnyJson(json, output: output)
        return output.bytes
    }
    
    func dataFromAnyJson(_ json: Any, output: JsonOutputStream) throws {
        let jayType = try NativeTypeConverter().toJayType(json)
        try jayType.format(to: output, with: formatting.formatter())
    }
}

struct Formatter {
    let indentStep: Int
    var indentation: Int = 0
    
    func nextLevel() -> Formatter {
        return Formatter(indentStep: indentStep, indentation: indentation + indentStep)
    }
    
    func clean() -> Formatter {
        return Formatter(indentStep: indentStep, indentation: 0)
    }
    
    func indent() -> [JChar] {
        return Array(repeating: Const.Space, count: indentation)
    }
    
    func newline() -> [JChar] {
        return indentStep > 0 ? [Const.NewLine] : []
    }
    
    func newlineAndIndent() -> [JChar] {
        return newline() + indent()
    }
    
    func separator() -> [JChar] {
        return indentStep > 0 ? [Const.Space] : []
    }
}

extension Jay.Formatting {
    func formatter() -> Formatter {
        switch self {
        case .minified: return Formatter(indentStep: 0, indentation: 0)
        case .prettified: return Formatter(indentStep: 4, indentation: 0)
        }
    }
}

//Typesafe
extension Jay {
    
    /// Allows users to get the `JSON` representation in a typesafe matter.
    /// However, these types are wrapped, so the user is responsible for
    /// manually unwrapping each value recursively.
    /// - SeeAlso: If you just want Swift types with less
    /// type-information, use `jsonFromData()` above.
    public func jsonFromData(_ data: [UInt8]) throws -> JSON {
        return try Parser(parsing: parsing).parseJsonFromData(data)
    }
  
    /// Allows users to get the `JSON` representation in a typesafe matter.
    /// However, these types are wrapped, so the user is responsible for
    /// manually unwrapping each value recursively.
    /// - SeeAlso: If you just want Swift types with less
    /// type-information, use `jsonFromReader()` above.
    public func jsonFromReader<R: Reader>(_ reader: R) throws -> JSON {
        return try Parser(parsing: parsing).parseJsonFromReader(reader)
    }

    /// Formats your JSON-compatible object into data.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(json: JSON) throws -> [UInt8] {
        let output = ByteArrayOutputStream()
        try dataFromJson(json: json, output: output)
        return output.bytes
    }
  
    /// Outputs your JSON-compatible object as data to the provided stream.
    /// - Throws: A descriptive error in case of any problem.
    public func dataFromJson(json: JSON, output: JsonOutputStream) throws {
        try json.format(to: output, with: formatting.formatter())
    }
}



