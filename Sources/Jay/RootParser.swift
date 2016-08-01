//
//  RootParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct RootParser: JsonParser {
    
    static func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try self.prepareForReading(with: reader)
        
        //the standard doesn't require handling of fragments, so here
        //we'll assume we're only parsing valid structured types (object/array)
        switch reader.curr() {
        case Const.BeginObject:
            return try ObjectParser.parse(with: reader)
        case Const.BeginArray:
            return try ArrayParser.parse(with: reader)
        default:
            throw JayError.unimplemented("ParseRoot")
        }
    }
}
