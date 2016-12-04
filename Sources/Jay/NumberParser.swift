//
//  NumberParser.swift
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

struct NumberParser: JsonParser {
    
    var parsing: Jay.ParsingOptions

    //phase    1         2   3        4
    //number = [ minus ] int [ frac ] [ exp ]
    //exp = e [ minus / plus ] 1*DIGIT
    //frac = decimal-point 1*DIGIT
    //int = zero / ( digit1-9 *DIGIT )
    
    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try prepareForReading(with: reader)
        
        //1. Optional minus
        let negative = try self.parseMinus(reader)
        
        //2. Integer part & 3. Frac part
        //here we need to read the first digit 
        // - if it's 0
        //      - must be followed by a number terminating char or
        //      - continue to the frac part right away
        // - if it's 1...9, continue to parsing integer part first
        let integer: Int
        let frac: String
        if reader.curr() == Const.Zero {
            try reader.nextAndCheckNotDone()
            
            //no int part means 0
            integer = 0
            
            //now if any number terminator is here, finish up with 0
            if Const.NumberTerminators.contains(reader.curr()) {
                return .number(.unsignedInteger(0))
            }
            
            //else there MUST be a frac part
            frac = try self.parseFrac(reader)
        } else {
            //parse int part
            integer = try self.parseInt(reader)
            //check whether we have a frac part
            if reader.curr() == Const.DecimalPoint {
                frac = try self.parseFrac(reader)
            } else {
                frac = ""
            }
        }
        
        //4. Exp part
        let exp = try self.parseOptionalExp(reader)
        
        //Generate the final number
        let number = self.generateNumber(negative: negative, integer: integer, frac: frac, exp: exp)
        let value: JSON = .number(number)
        return value
    }
    
    private func generateNumber(negative: Bool, integer: Int, frac: String, exp: Int?) -> JSON.Number {
        
        //form the int section
        var int = integer
        let sign = negative ? -1 : 1
        int *= sign
        
        //if that's it, let's call it an integer
        if frac.isEmpty && exp == nil {
            if negative {
                //if it's negative, make it a signed integer
                return .integer(int)
            } else {
                //if it's positive, make it a uint
                return .unsignedInteger(UInt(int))
            }
        }
        
        //now we're using double
        var dbl = Double(int)
        
        //if it's a frac, append the fraction section
        if !frac.isEmpty {
            //double
            let fracAdd = Double("0.\(frac)")! * Double(sign)
            dbl += fracAdd
        }

        //exponent just means that we need to multiply the number
        //by 10^exp
        if let exp = exp {
            let multi = pow(10.0, Double(exp))
            dbl *= multi
        }
        
        return .double(dbl)
    }
    
    private func parseMinus<R: Reader>(_ reader: R) throws -> Bool {
        if reader.curr() == Const.Minus {
            try reader.nextAndCheckNotDone()
            return true
        }
        return false
    }
    
    private func parseInt<R: Reader>(_ reader: R) throws -> Int {
        
        var digs = [JChar]()
        
        //take first digit, which can only be 1...9
        var digits = Const.Digits1to9
        guard digits.contains(reader.curr()) else {
            throw JayError.numberParsingFailed(reader)
        }
        digs.append(reader.curr())
        try reader.nextAndCheckNotDone()
        
        digits = Const.Digits0to9
        
        //once we're detecting the int-section,
        //things that can legally end this section are
        //1. decimal point -> frac
        //2. e/E -> exp
        //3. whitespace, end of array, end of object, value-separator -> end of number
        //that's it. everything else is illegal and we need to raise an error
        let intTerm = Const.NumberTerminators.union(Const.Exponent).union([Const.DecimalPoint])
        
        //now get into a loop - look for allowed chars
        while true {
            
            //look for allowed int digits
            if digits.contains(reader.curr()) {
                digs.append(reader.curr())
                try reader.nextAndCheckNotDone()
                continue
            }
            
            //look for other number-allowed chars in this context
            //although int-section terminating
            if intTerm.contains(reader.curr()) {
                //gracefully end this section
                let intString = try digs.string()
                let int = Int(intString)!
                return int
            }
            
            //okay, we encountered an illegal character, error out
            throw JayError.numberParsingFailed(reader)
        }
    }
    
    private func parseFrac<R: Reader>(_ reader: R) throws -> String {
        
        //frac part MUST start with decimal point!
        guard reader.curr() == Const.DecimalPoint else {
            throw JayError.numberParsingFailed(reader)
        }
        try reader.nextAndCheckNotDone()
        
        var digs = [JChar]()
        
        //at least one digit 0...9 must follow
        guard Const.Digits0to9.contains(reader.curr()) else {
            throw JayError.numberParsingFailed(reader)
        }
        digs.append(reader.curr())
        try reader.nextAndCheckNotDone()
        
        //once we're detecting the frac-section,
        //things that can legally end this section are
        //1. e/E -> exp
        //2. whitespace, end of array, end of object, value-separator -> end of number
        //that's it. everything else is illegal and we need to raise an error
        let fracTerm = Const.NumberTerminators.union(Const.Exponent)

        //now read in a loop
        while true {
            
            if Const.Digits0to9.contains(reader.curr()) {
                digs.append(reader.curr())
                try reader.nextAndCheckNotDone()
                continue
            }
            
            //look for other number-allowed chars in this context
            //although frac-section terminating
            if fracTerm.contains(reader.curr()) {
                //gracefully end this section
                let fracString = try digs.string()
                return fracString
            }
            
            //okay, we encountered an illegal character, error out
            throw JayError.numberParsingFailed(reader)
        }
    }
    
    private func parseOptionalExp<R: Reader>(_ reader: R) throws -> Int? {
        
        //exp part MUST start with e/E
        //otherwise it isn't there
        guard Const.Exponent.contains(reader.curr()) else {
            return nil
        }
        try reader.nextAndCheckNotDone()
        
        var sign = 1
        //optionally there can be a sign: + or -
        if Set<JChar>([Const.Plus, Const.Minus]).contains(reader.curr()) {
            //found a sign, if it's plus, there's nothing to do,
            //if it's minus, change out sign var
            if reader.curr() == Const.Minus {
                sign = -1
            }
            try reader.nextAndCheckNotDone()
        }
        
        var digs = [JChar]()
        
        //at least one digit 1...9 must follow
        guard Const.Digits1to9.contains(reader.curr()) else {
            throw JayError.numberParsingFailed(reader)
        }
        digs.append(reader.curr())
        try reader.nextAndCheckNotDone()
        
        //once we're detecting the exp-section,
        //things that can legally end this section are
        //1. whitespace, end of array, end of object, value-separator -> end of number
        //that's it. everything else is illegal and we need to raise an error
        let expTerm = Const.NumberTerminators
        
        //now read in a loop
        while true {
            
            if Const.Digits0to9.contains(reader.curr()) {
                digs.append(reader.curr())
                try reader.nextAndCheckNotDone()
                continue
            }
            
            //look for other number-allowed chars in this context
            //although exp-section terminating
            if expTerm.contains(reader.curr()) {
                //gracefully end this section
                let expString = try digs.string()
                let exp = Int(expString)! * sign
                return exp
            }
            
            //okay, we encountered an illegal character, error out
            throw JayError.numberParsingFailed(reader)
        }
    }
}



