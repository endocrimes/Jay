//
//  PerformanceTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

#if os(Linux)
    extension PerformanceTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                ("testPerf_ParseLargeJson", testPerf_ParseLargeJson),
                ("testPerf_ParseLargeJson_Darwin", testPerf_ParseLargeJson_Darwin)
            ]
        }
    }
#endif

#if os(Linux)
#else
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
    
    func assertEqual(my: [UInt8], exp: [UInt8]) {
        
        //iterate over both and find the first difference
        for (index, char) in exp.enumerate() {
            
            guard index < my.endIndex else {
                XCTFail("Ran out of my data at index \(index)")
                return
            }
            
            if my[index] == char {
                continue
            }
            
            //different
            XCTFail("Mismatch at index \(index)")
        }
        
        if my.count > exp.count {
            XCTFail("We have \(my.count) bytes, exp has \(exp.count)")
        }
    }
    
    //can't do until we can ensure that the original data 
    //has sorted keys in objects. otherwise not reproducible.
//    func test_LoopTest() {
//        
//        //first we parse it
//        let data = self.loadFixture("large_min")
//        let jay = Jay()
//        let json = try! jay.jsonFromData(data)
//        
//        //then we format it
//        let outData = try! jay.dataFromJson(json)
//        
//        //compare data
//        assertEqual(outData, exp: data)
//    }

    //can't test pure data either because order isn't preserved
//    func test_FormatLargeJson_SameAsNSJSONSerialization() {
//        
//        let nsDataIn = self.loadFixtureNSData("large")
//        let obj = try! NSJSONSerialization.JSONObjectWithData(nsDataIn, options: NSJSONReadingOptions())
//
//        //first we format it
//        let jay = Jay()
//        let myDataOut = try! jay.dataFromJson(obj)
//        
//        //nsjson parses it
//        let nsNSDataOut = try! NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions())
//        let nsDataOut = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(nsNSDataOut.bytes), count: nsNSDataOut.length))
//        
//        //compare
//        assertEqual(myDataOut, exp: nsDataOut)
//    }
    
    
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
#endif

