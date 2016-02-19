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
        
        var reader = try self.prepareForReading(withReader: r)
        
        //ensure we're starting with a quote
        guard reader.curr() == Const.QuotationMark else {
            throw Error.UnexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //if another quote, it's just an empty string
        if reader.curr() == Const.QuotationMark {
            return (JsonValue.String(""), reader)
        }
        
        let str: String
        (str, reader) = try self.parseString(reader)
        let obj = JsonValue.String(str)
        return (obj, reader)
    }
    
    func parseString(r: Reader) throws -> (String, Reader) {
        
        var str = ""
        var reader = r
        while true {
            
            switch reader.curr() {
                
            case 0x00...0x1F:
                //unescaped control chars, invalid
                throw Error.UnescapedControlCharacterInString(reader)
                
            case Const.QuotationMark:
                //end of string, return what we have
                try reader.nextAndCheckNotDone()
                return (str, reader)
                
            case Const.Escape:
                //something that needs escaping, delegate
                var char: UnicodeScalar
                (char, reader) = try self.unescapedCharacter(reader)
                str.append(char)
                
            default:
                //nothing special, just append a regular unicode character
                var char: UnicodeScalar
                (char, reader) = try self.readUnicodeCharacter(reader)
                str.append(char)
            }
        }
    }
    
    func readUnicodeCharacter(r: Reader) throws -> (UnicodeScalar, Reader) {
        
        //we need to keep reading from the reader until either
        //- result is returned, at which point we parsed a valid char
        //- error is returned, at which point we throw
        //- emptyInput is called, at which point we throw bc we unexpectatly
        //  ran out of characters
        
        //since we read 8bit chars and the largest unicode char is 32bit,
        //when we're parsing a long character, we'll be getting an error
        //up until we reach 32 bits. if we get an error even then, it's an
        //invalid character and throw.
        
        var reader = r
        var buffer = [JChar]()
        
        while buffer.count < 4 {
            
            buffer.append(reader.curr())
            var gen = buffer.generate()
            
            var utf = UTF8()
            switch utf.decode(&gen) {
            case .Result(let unicodeScalar):
                try reader.nextAndCheckNotDone()
                return (unicodeScalar, reader)
            case .EmptyInput, .Error:
                //continue because we might be reading a longer char
                try reader.nextAndCheckNotDone()
                continue
            }
        }
        //we ran out of parsing attempts and we've read 4 8bit chars, error out
        throw Error.UnicodeCharacterParsing(buffer, reader)
    }
    
    func isValidUnicodeHexDigit(chars: [JChar]) -> Bool {
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
    
    func unescapedCharacter(r: Reader, expectingLowSurrogate: Bool = false) throws -> (UnicodeScalar, Reader) {
        
        var reader = r
        
        //this MUST start with escape
        guard reader.curr() == Const.Escape else {
            throw Error.InvalidEscape(reader)
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
            return (uniScalar, reader)
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
        
        let last4 = try Array(unicode.suffix(4)).string()
        let value = self.fourBytesToUnicodeCode(last4)
        
        //check for high/low surrogate pairs
        if let complexScalarRet = try self.parseSurrogate(reader, value: value) {
            return complexScalarRet
        }
        
        //nope, normal unicode char
        let char = UnicodeScalar(value)
        return (char, reader)
    }
    
    func fourBytesToUnicodeCode(last4: String) -> UInt16 {
        return UInt16(strtoul("0x\(last4)", nil, 16))
    }
    
    //nil means no surrogate found, parse normally
    func parseSurrogate(r: Reader, value: UInt16) throws -> (UnicodeScalar, Reader)? {
        
        var reader = r
        
        //no surrogate starting
        guard UTF16.isLeadSurrogate(value) else { return nil }
        
        //this MUST start with escape - the low surrogate
        guard reader.curr() == Const.Escape else {
            throw Error.InvalidEscape(reader)
        }
        try reader.nextAndCheckNotDone()

        let high = value
        
        //validate u + next 4 digits (total of 5)
        let unicode = try reader.readNext(5)
        guard self.isValidUnicodeHexDigit(unicode) else {
            throw Error.InvalidUnicodeSpecifier(reader)
        }
        let last4 = try Array(unicode.suffix(4)).string()
        let low = self.fourBytesToUnicodeCode(last4)
        
        //must be a low, otherwise invalid
        guard UTF16.isTrailSurrogate(low) else {
            throw Error.InvalidSurrogatePair(high, low, reader)
        }
        
        //we have a high and a low surrogate, both as UTF-16
        //append and parse them as such
        let data = [high, low]
        var utf = UTF16()
        var gen = data.generate()
        switch utf.decode(&gen) {
        case .Result(let char):
            return (char, reader)
        case .EmptyInput, .Error:
            throw Error.InvalidSurrogatePair(high, low, reader)
        }
    }
    
    
    
    
}