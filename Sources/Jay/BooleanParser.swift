//
//  BooleanParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct BooleanParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (ParsedJsonToken, Reader) {
        
        func parseTrue(rr: Reader) throws -> (ParsedJsonToken, Reader) {
            var rd = rr
            let start = rd.currIndex()
            //try to read the "true" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.True))
            let range = rd.rangeFrom(start)
            return (ParsedJsonToken(.Boolean(JsonBoolean.True), range), rd)
        }
        
        func parseFalse(rr: Reader) throws -> (ParsedJsonToken, Reader) {
            var rd = rr
            let start = rd.currIndex()
            //try to read the "false" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.False))
            let range = rd.rangeFrom(start)
            return (ParsedJsonToken(.Boolean(JsonBoolean.False), range), rd)
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
