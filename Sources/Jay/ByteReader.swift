//
//  ByteReader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ByteReader: Reader {
    
    private let content: [CChar]
    private var cursor: Array<CChar>.Index
    
    init(content: [CChar]) {
        self.content = content
        self.cursor = self.content.startIndex
    }
    
    mutating func next() {
        precondition(!self.isDone())
        self.cursor = self.cursor.successor()
    }
    
    func peek() -> CChar? {
        let nextCursor = self.cursor.successor()
        if nextCursor == self.content.endIndex {
            return nil
        }
        return self.content[nextCursor]
    }
    
    func curr() -> CChar {
        precondition(!self.isDone())
        return self.content[self.cursor]
    }
    
    func isDone() -> Bool {
        return self.cursor == self.content.endIndex
    }
    
    init(content: String) {
        self.init(content: content.cchars())
    }
}
