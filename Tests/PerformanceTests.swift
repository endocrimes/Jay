//
//  PerformanceTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

class PerformanceTests: XCTestCase {
    
    func testPerf_ParseLargeJson() {
        
        let url = NSBundle(forClass: PerformanceTests.classForCoder()).URLForResource("large", withExtension: "json")
        let data = Array(try! String(contentsOfURL: url!).utf8)

        let jay = Jay()
        measureBlock {
            _ = try! jay.jsonFromData(data)
        }
    }
}
