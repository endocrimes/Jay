//
//  ObjectParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ObjectParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (JsonValue, Reader) {
        
        var reader = try self.prepareForReading(withReader: r)
        
        //detect opening brace
        guard reader.curr() == Const.BeginObject else {
            throw Error.UnexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //move along, now start looking for name/value pairs
        reader = try self.prepareForReading(withReader: reader)

        //check curr value for closing bracket, to handle empty object
        if reader.curr() == Const.EndObject {
            //empty object
            reader.next()
            return (JsonValue.Object([:]), reader)
        }

        //now start scanning for name/value pairs
        var pairs = [(JsonString, JsonValue)]()
        repeat {
            
            //scan for name
            let nameRet = try StringParser().parse(withReader: reader)
            reader = nameRet.1
            let name: JsonString
            switch nameRet.0 {
            case .String(let n): name = n; break
            default: fatalError("Logic error: Should have returned a dictionary")
            }
            
            //scan for name separator :
            reader = try self.prepareForReading(withReader: reader)
            guard reader.curr() == Const.NameSeparator else {
                throw Error.ObjectNameSeparatorMissing(reader)
            }
            try reader.nextAndCheckNotDone()
            
            //scan for value
            let valRet = try ValueParser().parse(withReader: reader)
            reader = valRet.1
            let value = valRet.0
            
            //append name/value pair
            pairs.append((name, value))
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing brace
            reader = try self.prepareForReading(withReader: reader)
            switch reader.curr() {
            case Const.EndObject:
                reader.next()
                let exported = self.exportArray(pairs)
                return (JsonValue.Object(exported), reader)
            case Const.ValueSeparator:
                //comma, so another value must come. let the loop repeat.
                reader.next()
                continue
            default: throw Error.UnexpectedCharacter(reader)
            }
        } while true
    }
    
    func exportArray(pairs: [(JsonString, JsonValue)]) -> [JsonString: JsonValue] {
        
        var object = [JsonString: JsonValue]()
        for i in pairs {
            object[i.0] = i.1
        }
        return object
    }
}
