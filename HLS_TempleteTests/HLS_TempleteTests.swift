//
//  HLS_TempleteTests.swift
//  HLS_TempleteTests
//
//  Created by hattori tsubasa on 2021/12/01.
//

import XCTest
@testable import HLS_Templete

class HLS_TempleteTests: XCTestCase {

    /// テストの開始時に最初に一度呼ばれる関数。テストケースを回すために必要な設定やインスタンスの生成などを行う。
    override func setUp() {
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

    /// パフォーマンスの計測用の関数です。 self.measure {} のクロージャの中に計測したい処理を記述するとその処理にかかった時間を教えてくれます。
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
