//
//  ArrayParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ArrayParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (ParsedJsonToken, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        let start = reader.currIndex()
        
        //detect opening bracket
        guard reader.curr() == Const.BeginArray else {
            throw Error.UnexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //move along, now start looking for values
        reader = try self.prepareForReading(withReader: reader)
        
        //check curr value for closing bracket, to handle empty array
        if reader.curr() == Const.EndArray {
            //empty array
            reader.next()
            let range = reader.rangeFrom(start)
            return (ParsedJsonToken(.Array([]), range), reader)
        }
        
        //now start scanning for values
        var values = [ParsedJsonToken]()
        repeat {
            
            //scan for value
            let ret = try ValueParser().parse(withReader: reader)
            values.append(ret.0)
            reader = ret.1
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing bracket
            reader = try self.prepareForReading(withReader: reader)
            switch reader.curr() {
            case Const.EndArray:
                reader.next()
                let range = reader.rangeFrom(start)
                return (ParsedJsonToken(.Array(values), range), reader)
            case Const.ValueSeparator: reader.next(); break //comma, so another value must come. let the loop repeat.
            default: throw Error.UnexpectedCharacter(reader)
            }
        } while true
    }
}

