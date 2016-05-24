//
//  Jay.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//Implemented from scratch based on http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf and https://www.ietf.org/rfc/rfc4627.txt

public struct Jay {
    
    public enum Formatting {
        case minified
        case prettified
    }
    
    public let formatting: Formatting
    
    public init(formatting: Formatting = .minified) {
        self.formatting = formatting
    }
    
    //Parses data into a dictionary [String: Any] or array [Any].
    //Does not allow fragments. Test by conditional
    //casting whether you received what you expected.
    //Throws a descriptive error in case of any problem.
    public func jsonFromData(_ data: [UInt8]) throws -> Any {
        return try NativeParser().parse(data)
    }
    
    public func jsonFromReader(_ reader: Reader) throws -> Any {
        return try NativeParser().parse(reader)
    }
    
    //Formats your JSON-compatible object into data or throws an error.
    public func dataFromJson(_ json: JaySON) throws -> [UInt8] {
        return try self.dataFromAnyJson(json.json)
    }
    
    public func dataFromJson(_ json: JaySON, output: JsonOutputStream) throws {
        try self.dataFromAnyJson(json.json, output: output)
    }

    public func dataFromJson(_ json: [String: Any]) throws -> [UInt8] {
        return try self.dataFromAnyJson(json)
    }

    public func dataFromJson(_ json: [String: Any], output: JsonOutputStream) throws {
        try self.dataFromAnyJson(json, output: output)
    }

    public func dataFromJson(_ json: [Any]) throws -> [UInt8] {
        return try self.dataFromAnyJson(json)
    }

    public func dataFromJson(_ json: [Any], output: JsonOutputStream) throws {
        try self.dataFromAnyJson(json, output: output)
    }

    public func dataFromJson(_ json: Any) throws -> [UInt8] {
        return try self.dataFromAnyJson(json)
    }

    public func dataFromJson(_ json: Any, output: JsonOutputStream) throws {
        try self.dataFromAnyJson(json, output: output)
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
    
    //Allows users to get the JSON representation in a typesafe matter.
    //However these types are wrapped, so the user is responsible for
    //manually unwrapping each value recursively. If you just want
    //Swift types with less type-information, use `jsonFromData()` above.
    public func typesafeJsonFromData(_ data: [UInt8]) throws -> JSON {
        return try Parser().parseJsonFromData(data)
    }
    
    public func typesafeJsonFromReader(_ reader: Reader) throws -> JSON {
        return try Parser().parseJsonFromReader(reader)
    }

    //Formats your JSON-compatible object into data or throws an error.
    public func dataFromJson(json: JSON) throws -> [UInt8] {
        let output = ByteArrayOutputStream()
        try dataFromJson(json: json, output: output)
        return output.bytes
    }
    
    public func dataFromJson(json: JSON, output: JsonOutputStream) throws {
        try json.format(to: output, with: formatting.formatter())
    }
}



