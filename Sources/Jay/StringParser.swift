//
//  StringParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct StringParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        //Turning unicode nums to chars UnicodeScalar(Int(strtoul("0x00A9", nil, 16)))
        
        //        var reader = try self.prepareForReading(withReader: r)
        throw Error.Unimplemented("String")
    }
}