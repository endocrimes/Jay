//
//  NullParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct NullParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (ParsedJsonToken, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        let start = reader.currIndex()
        
        //try to read the "null" literal, throw if anything goes wrong
        try reader.stopAtFirstDifference(ByteReader(content: Const.Null))
        let range = reader.rangeFrom(start)
        return (ParsedJsonToken(.Null, range), reader)
    }
}
