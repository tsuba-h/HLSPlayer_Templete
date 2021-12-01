//
//  HLSManager_Test.swift
//  HLS_TempleteTests
//
//  Created by hattori tsubasa on 2021/12/01.
//

import XCTest
@testable import HLS_Templete

class HLSManager_Test: XCTestCase {

    let hlsManager = HLSManager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let i = hlsManager.setupPlayer(url: "")
        XCTe
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
