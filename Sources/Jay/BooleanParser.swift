//
//  BooleanParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct BooleanParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (JsonValue, Reader) {
        
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
}
