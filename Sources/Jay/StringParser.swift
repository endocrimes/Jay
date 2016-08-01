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
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        
        try self.prepareForReading(with: r)
        
        //ensure we're starting with a quote
        guard reader.curr() == Const.QuotationMark else {
            throw JayError.unexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //if another quote, it's just an empty string
        if reader.curr() == Const.QuotationMark {
            try reader.nextAndCheckNotDone()
            return .string("")
        }
        
        let str = try self.parseString(r)
        return .string(str)
    }
    
    static func parseString<R: Reader>(_ r: Unmanaged<R>) throws -> String {
        
        let reader = r.takeUnretainedValue()
        
        var str = ""
        while true {
            
            switch reader.curr() {
                
            case 0x00...0x1F:
                //unescaped control chars, invalid
                throw JayError.unescapedControlCharacterInString(reader)
                
            case Const.QuotationMark:
                //end of string, return what we have
                try reader.nextAndCheckNotDone()
                return str
                
            case Const.Escape:
                //something that needs escaping, delegate
                var char: UnicodeScalar
                char = try self.unescapedCharacter(r)
                str.append(String(char))
                
            default:
                //nothing special, just append a regular unicode character
                var char: UnicodeScalar
                char = try self.readUnicodeCharacter(r)
                str.append(String(char))
            }
        }
    }
    
    static func readUnicodeCharacter<R: Reader>(_ r: Unmanaged<R>) throws -> UnicodeScalar {
        
        let reader = r.takeUnretainedValue()
        
        //we need to keep reading from the reader until either
        //- result is returned, at which point we parsed a valid char
        //- error is returned, at which point we throw
        //- emptyInput is called, at which point we throw bc we unexpectatly
        //  ran out of characters
        
        //since we read 8bit chars and the largest unicode char is 32bit,
        //when we're parsing a long character, we'll be getting an error
        //up until we reach 32 bits. if we get an error even then, it's an
        //invalid character and throw.
        
        var buffer: [JChar] = []
        
        while buffer.count < 4 {
            
            buffer.append(reader.curr())
            var gen = buffer.makeIterator()
            
            var utf = UTF8()
            switch utf.decode(&gen) {
            case .scalarValue(let unicodeScalar):
                try reader.nextAndCheckNotDone()
                return unicodeScalar
            case .emptyInput, .error:
                //continue because we might be reading a longer char
                try reader.nextAndCheckNotDone()
                continue
            }
        }
        //we ran out of parsing attempts and we've read 4 8bit chars, error out
        throw JayError.unicodeCharacterParsing(buffer, reader)
    }
    
    static func isValidUnicodeHexDigit(_ chars: [JChar]) -> Bool {
        guard chars.count == 5 else { //uXXXX
            return false
        }
        //ensure the five characters match this format
        let validHexCode = chars
            .dropFirst()
            .map { Const.HexDigits.contains($0) }
            .reduce(true, { $0 && $1 })
        guard chars[0] == Const.UnicodeStart && validHexCode else { return false }
        return true
    }
    
    static func unescapedCharacter<R: Reader>(_ r: Unmanaged<R>, expectingLowSurrogate: Bool = false) throws -> UnicodeScalar {
        
        let reader = r.takeUnretainedValue()
        
        //this MUST start with escape
        guard reader.curr() == Const.Escape else {
            throw JayError.invalidEscape(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //first check for the set escapable chars
        if Const.Escaped.contains(reader.curr()) {
            
            let char: JChar
            if let replacement = Const.EscapingRules[reader.curr()] {
                //rule based, replace properly
                char = replacement
            } else {
                //we encountered one of the simple escapable characters, just add it
                char = reader.curr()
            }
            
            let uniScalar = UnicodeScalar(char)
            try reader.nextAndCheckNotDone()
            return uniScalar
        }
        
        //now the char must be 'u', otherwise this is invalid escaping
        guard reader.curr() == Const.UnicodeStart else {
            throw JayError.invalidEscape(reader)
        }
        
        //validate the current + next 4 digits (total of 5)
        let unicode = try reader.readNext(5)
        guard self.isValidUnicodeHexDigit(unicode) else {
            throw JayError.invalidUnicodeSpecifier(reader)
        }
        
        let last4 = try Array(unicode.suffix(4)).string()
        let value = self.fourBytesToUnicodeCode(last4)
        
        //check for high/low surrogate pairs
        if let complexScalarRet = try self.parseSurrogate(r, value: value) {
            return complexScalarRet
        }
        
        //nope, normal unicode char
        let char = UnicodeScalar(value)
        return char
    }
    
    static func fourBytesToUnicodeCode(_ last4: String) -> UInt16 {
        return UInt16(strtoul("0x\(last4)", nil, 16))
    }
    
    //nil means no surrogate found, parse normally
    static func parseSurrogate<R: Reader>(_ r: Unmanaged<R>, value: UInt16) throws -> UnicodeScalar? {
        
        let reader = r.takeUnretainedValue()
        
        //no surrogate starting
        guard UTF16.isLeadSurrogate(value) else { return nil }
        
        //this MUST start with escape - the low surrogate
        guard reader.curr() == Const.Escape else {
            throw JayError.invalidEscape(reader)
        }
        try reader.nextAndCheckNotDone()

        let high = value
        
        //validate u + next 4 digits (total of 5)
        let unicode = try reader.readNext(5)
        guard self.isValidUnicodeHexDigit(unicode) else {
            throw JayError.invalidUnicodeSpecifier(reader)
        }
        let last4 = try Array(unicode.suffix(4)).string()
        let low = self.fourBytesToUnicodeCode(last4)
        
        //must be a low, otherwise invalid
        guard UTF16.isTrailSurrogate(low) else {
            throw JayError.invalidSurrogatePair(high, low, reader)
        }
        
        //we have a high and a low surrogate, both as UTF-16
        //append and parse them as such
        let data = [high, low]
        var utf = UTF16()
        var gen = data.makeIterator()
        switch utf.decode(&gen) {
        case .scalarValue(let char):
            return char
        case .emptyInput, .error:
            throw JayError.invalidSurrogatePair(high, low, reader)
        }
    }
}
