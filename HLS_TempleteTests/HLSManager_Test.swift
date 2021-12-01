//
//  HLSManager_Test.swift
//  HLS_TempleteTests
//
//  Created by hattori tsubasa on 2021/12/01.
//

import XCTest
@testable import HLS_Templete

class HLSManager_Test: XCTestCase {

    var readyToPlayExpextation: XCTestExpectation?
    var totalTimeExpectation: XCTestExpectation?

    let hlsManager = HLSManager()


    override func setUp() {
        hlsManager.delegate = self
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


    func testFailedSetupPlayer() throws {
        let i = hlsManager.setupPlayer(url: "")
        XCTAssertNil(i)
    }

    func testSuccessSetupPlayer() throws {
        let o = hlsManager.setupPlayer(url: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
        XCTAssertNotNil(o)

        readyToPlayExpextation = expectation(description: "readyToPlay")
        totalTimeExpectation = expectation(description: "totalTime")

        wait(for: [readyToPlayExpextation!, totalTimeExpectation!], timeout: 5)
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension HLSManager_Test: HLSManagerDelegate {
    func readyToPlay() {
        readyToPlayExpextation?.fulfill()
    }

    func totalTime(time: Float) {
        totalTimeExpectation?.fulfill()
    }

    func updateTime(time: Float) {
    }
}
