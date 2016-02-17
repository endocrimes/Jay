//
//  RootParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct RootParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        
        //the standard doesn't require handling of fragments, so here
        //we'll assume we're only parsing valid structured types (object/array)
        let root: JsonValue
        switch reader.curr() {
        case Const.BeginObject:
            (root, reader) = try ObjectParser().parse(withReader: reader)
        case Const.BeginArray:
            (root, reader) = try ArrayParser().parse(withReader: reader)
        default:
            throw Error.Unimplemented("ParseRoot")
        }
        return (root, reader)
    }
}
