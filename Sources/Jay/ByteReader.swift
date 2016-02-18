//
//  ByteReader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ByteReader: Reader {
    
    private let content: [JChar]
    private var cursor: Array<JChar>.Index
    
    init(content: [JChar]) {
        self.content = content
        self.cursor = self.content.startIndex
    }
    
    mutating func next() {
        precondition(!self.isDone())
        self.cursor = self.cursor.successor()
    }
    
    func peek(next: Int) -> [JChar] {
        
        let take = min(next, self.content.endIndex - self.cursor)
        let range = self.cursor..<self.cursor.advancedBy(take)
        return Array(self.content[range])
    }
    
    func curr() -> JChar {
        precondition(!self.isDone())
        return self.content[self.cursor]
    }
    
    func isDone() -> Bool {
        return self.cursor == self.content.endIndex
    }
    
    init(content: String) {
        self.init(content: content.chars())
    }
}
