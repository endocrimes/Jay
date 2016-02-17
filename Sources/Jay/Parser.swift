//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //assuming data [Int8]
    func parseJsonFromData(data: [CChar]) throws -> Any {
        
        //create a reader for this data
        let reader = ByteReader(content: data)
        
        //delegate parsing
        let result = try self.parseRoot(withReader: reader)
        
        return result
    }
}

extension Parser {

    //MARK: Parse specific cases

    func parseRoot(withReader r: Reader) throws -> (Any, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        
        //the standard doesn't require handling of fragments, so here
        //we'll assume we're only parsing valid structured types (object/array)
        let root: JsonValue
        switch reader.curr() {
        case Const.BeginObject:
            (root, reader) = try self.parseObject(withReader: reader)
        default:
            throw Error.Unimplemented("ParseRoot")
        }
        return (root, reader)
    }
    
    func parseValue(withReader r: Reader) throws -> (JsonValue, Reader) {

        var reader = try self.prepareForReading(withReader: r)
        
        let val: JsonValue
        switch reader.curr() {
        case let x where StartChars.Object.contains(x):
            (val, reader) = try self.parseObject(withReader: reader)
        case let x where StartChars.Array.contains(x):
            (val, reader) = try self.parseArray(withReader: reader)
        case let x where StartChars.Number.contains(x):
            (val, reader) = try self.parseNumber(withReader: reader)
        case let x where StartChars.String.contains(x):
            (val, reader) = try self.parseString(withReader: reader)
        case let x where StartChars.Boolean.contains(x):
            (val, reader) = try self.parseBoolean(withReader: reader)
        case let x where StartChars.Null.contains(x):
            (val, reader) = try self.parseNull(withReader: reader)
        default:
            throw Error.UnexpectedCharacter(reader)
        }
        return (val, reader)
    }
    
    func parseObject(withReader r: Reader) throws -> (JsonValue, Reader) {
        
//        var reader = try self.prepareForReading(withReader: r)
        throw Error.Unimplemented("Object")
//        return (JsonValue.Null, reader)
    }
    
    func parseArray(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        
        //detect opening bracket
        guard reader.curr() == Const.BeginArray else {
            throw Error.UnexpectedCharacter(reader)
        }
        reader.next()
        
        //move along, now start looking for values
        reader = try self.prepareForReading(withReader: reader)

        //check curr value for closing bracket, to handle empty array
        if reader.curr() == Const.EndArray {
            //empty array
            reader.next()
            return (JsonValue.Array([]), reader)
        }
        
        //now start scanning for values
        var values = [JsonValue]()
        repeat {
            
            //scan for value
            let ret = try self.parseValue(withReader: reader)
            values.append(ret.0)
            reader = ret.1
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing bracket
            reader = try self.prepareForReading(withReader: reader)
            switch reader.curr() {
            case Const.EndArray: reader.next(); return (JsonValue.Array(values), reader)
            case Const.ValueSeparator: reader.next(); break //comma, so another value must come. let the loop repeat.
            default: throw Error.UnexpectedCharacter(reader)
            }
        } while true
    }
    
    func parseNumber(withReader r: Reader) throws -> (JsonValue, Reader) {
        
//        var reader = try self.prepareForReading(withReader: r)
        throw Error.Unimplemented("Number")
//        return (JsonValue.Null, reader)
    }

    func parseString(withReader r: Reader) throws -> (JsonValue, Reader) {
        
//        var reader = try self.prepareForReading(withReader: r)
        throw Error.Unimplemented("String")
//        return (JsonValue.Null, reader)
    }

    func parseBoolean(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        func parseTrue(rr: Reader) throws -> (JsonValue, Reader) {
            var rd = rr
            //try to read the "true" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.True))
            return (JsonValue.Boolean(JsonBoolean.True), rd)
        }
        
        func parseFalse(rr: Reader) throws -> (JsonValue, Reader) {
            var rd = rr
            //try to read the "false" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.False))
            return (JsonValue.Boolean(JsonBoolean.False), rd)
        }
        
        let reader = try self.prepareForReading(withReader: r)
        
        //find whether we're parsing "true" or "false"
        let char = reader.curr()
        switch char {
        case Const.True[0]: return try parseTrue(reader)
        case Const.False[0]: return try parseFalse(reader)
        default: throw Error.UnexpectedCharacter(reader)
        }
    }

    func parseNull(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        
        //try to read the "null" literal, throw if anything goes wrong
        try reader.stopAtFirstDifference(ByteReader(content: Const.Null))
        return (JsonValue.Null, reader)
    }
}

extension Parser {
    
    //MARK: Utils
    
    func prepareForReading(withReader r: Reader) throws -> Reader {
        
        var reader = r
        
        //ensure no leading whitespace
        reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        guard !reader.isDone() else { throw Error.UnexpectedEnd(reader) }
        
        return reader
    }
}

