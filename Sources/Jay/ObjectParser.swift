//
//  ObjectParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ObjectParser: JsonParser {
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        
        try self.prepareForReading(with: r)
        
        //detect opening brace
        guard reader.curr() == Const.BeginObject else {
            throw JayError.unexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //move along, now start looking for name/value pairs
        try self.prepareForReading(with: r)

        //check curr value for closing bracket, to handle empty object
        if reader.curr() == Const.EndObject {
            //empty object
            try reader.next()
            return .object([:])
        }

        //now start scanning for name/value pairs
        var pairs: [(String, JSON)] = []
        repeat {
            
            //scan for name
            let nameRet = try StringParser.parse(with: r)
            let name: String
            switch nameRet {
            case .string(let n): name = n; break
            default: fatalError("Logic error: Should have returned a dictionary")
            }
            
            //scan for name separator :
            try self.prepareForReading(with: r)
            guard reader.curr() == Const.NameSeparator else {
                throw JayError.objectNameSeparatorMissing(reader)
            }
            try reader.nextAndCheckNotDone()
            
            //scan for value
            let value = try ValueParser.parse(with: r)
            
            //append name/value pair
            pairs.append((name, value))
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing brace
            try self.prepareForReading(with: r)
            switch reader.curr() {
            case Const.EndObject:
                try reader.next()
                let exported = self.exportArray(pairs)
                return .object(exported)
            case Const.ValueSeparator:
                //comma, so another value must come. let the loop repeat.
                try reader.next()
                continue
            default: throw JayError.unexpectedCharacter(reader)
            }
        } while true
    }
    
    static func exportArray(_ pairs: [(String, JSON)]) -> [String: JSON] {
        var object: [String: JSON] = [:]
        for i in pairs {
            object[i.0] = i.1
        }
        return object
    }
}
