//
//  OutputStream.swift
//  Jay
//
//  Created by Honza Dvorsky on 5/21/16.
//
//

public protocol JsonOutputStream {
    func print(_ bytes: [UInt8])
}

precedencegroup LeftAssociativity {
    associativity: left
}
infix operator <<< : LeftAssociativity

@discardableResult
func <<<(stream: JsonOutputStream, value: UInt8) -> JsonOutputStream {
    stream.print([value])
    return stream
}

@discardableResult
func <<<(stream: JsonOutputStream, value: [UInt8]) -> JsonOutputStream {
    stream.print(value)
    return stream
}

public class ConsoleOutputStream: JsonOutputStream {
    
    public init() { }

    /// Writes the textual representation of the provided bytes into the standard output.
    public func print(_ bytes: [UInt8]) {
        let str = try? bytes.string()
        Swift.print(str ?? "UNFORMATTABLE DATA", terminator: "")
    }
}

public class ByteArrayOutputStream: JsonOutputStream {
    
    public var bytes: [UInt8]
    
    public init() {
        self.bytes = []
    }
    
    public func print(_ bytes: [UInt8]) {
        self.bytes += bytes
    }
}
