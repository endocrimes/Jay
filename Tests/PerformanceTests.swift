//
//  PerformanceTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

class PerformanceTests: XCTestCase {

    func loadFixture(name: String) -> [UInt8] {
        let url = NSBundle(forClass: PerformanceTests.classForCoder()).URLForResource(name, withExtension: "json")
        let data = Array(try! String(contentsOfURL: url!).utf8)
        return data
    }
    
    func loadFixtureNSData(name: String) -> NSData {
        let url = NSBundle(forClass: PerformanceTests.classForCoder()).URLForResource(name, withExtension: "json")!
        let data = NSData(contentsOfURL: url)!
        return data
    }

    func testPerf_ParseLargeJson() {
        
        //at the moment we're 39x slower in parsing than NSJSONSerialization :D
        //(in release). but to be fair, it took me 2 evenings to write this parser.
        let data = self.loadFixture("large")
        let jay = Jay()
        measureBlock {
            _ = try! jay.jsonFromData(data)
        }
    }
    
    func testPerf_ParseLargeJson_Darwin() {
        
        let data = self.loadFixtureNSData("large")
        measureBlock {
            _ = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        }
    }

    
    //Enable when we have formatting and can pretty print it/
    //format into data and compare data with NSJSONSerialization
//    func testCompareWithNSJSONSerialization() {
//        let data = self.loadFixture("large")
//        let jay = Jay()
//        let json = try! jay.jsonFromData(data)
//        
//        let data = self.loadFixtureNSData("large")
//        let json2 = try! NSJSONSerialization.JSONObjectWithData(d2, options: NSJSONReadingOptions())
//        
//        let j1 = String(json)
//        let j2 = String(json2)
//        let eq = j1 == j2
//        print(j1)
//        print(j2)
//        print(eq)
//    }
}
