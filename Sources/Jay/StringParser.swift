//
//  StringParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

struct StringParser: JsonParser {
    
    func parse(withReader r: Reader) throws -> (JsonValue, Reader) {
        
    
        //        var reader = try self.prepareForReading(withReader: r)
        throw Error.Unimplemented("String")
    }
    
    func isValidUnicodeHexDigit(chars: [CChar]) -> Bool {
        guard chars.count == 5 else { //uXXXX
            return false
        }
        //ensure the five characters match this format
        let validHexCode = chars
            .dropFirst()
            .map { Const.HexDigits.contains($0) }
            .reduce(true, combine: { $0 && $1 })
        guard chars[0] == Const.UnicodeStart && validHexCode else { return false }
        return true
    }
    
    func unescapedCharacter(r: Reader) throws -> (UnicodeScalar, Reader) {
        
        var reader = r
        
        //this MUST start with reverse solidus, otherwise there's a logic error
        precondition(reader.curr() == Const.Escape)
        try reader.nextAndCheckNotDone()
        
        //first check for the set escapable chars
        if Const.Escaped.contains(reader.curr()) {
            
            //we encountered one of the simple escapable characters, just add it
            let char = UnicodeScalar(UInt8(reader.curr()))
            try reader.nextAndCheckNotDone()
            return (char, reader)
        }
        
        //now the char must be 'u', otherwise this is invalid escaping
        guard reader.curr() == Const.UnicodeStart else {
            throw Error.InvalidEscape(reader)
        }
        
        //validate the current + next 4 digits (total of 5)
        let unicode = try reader.readNext(5)
        guard self.isValidUnicodeHexDigit(unicode) else {
            throw Error.InvalidUnicodeSpecifier(reader)
        }
        
        //TODO: do we need to loop here and potentially parse all 
        //unicode code points at once? read up on this. test with emoji.
        
        let last4 = try Array(unicode.suffix(4)).string()
        let char = UnicodeScalar(Int(strtoul("0x\(last4)", nil, 16)))
        return (char, reader)
    }
}