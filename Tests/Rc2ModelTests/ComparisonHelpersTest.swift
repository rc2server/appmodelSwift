//
//  ComparisonHelpersTests.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import XCTest
@testable import Rc2Model

class ComparisonHelpersTests: XCTestCase {
	
	func testOptionalArrayCompare() {
		XCTAssertFalse(compare([true, false], nil))
		XCTAssertTrue(compare([true, true], [true, true]))
		XCTAssertFalse(compare([true, false], [true, true]))
		XCTAssertTrue(compare(nil as [Bool]? , nil))
	}
	
	func testOptionalValueCompare() {
		XCTAssertTrue(compare([true, nil], [true, nil]))
		XCTAssertFalse(compare([true, nil], [nil, true]))
		XCTAssertTrue(compare([true, false], [true, false]))
		XCTAssertFalse(compare([true, false], [false, true]))
		XCTAssertFalse(compare([true, nil, false], [true, nil, true]))
	}
	
	func testOptionalDoubleCompare() {
		XCTAssertTrue(compare([Double.infinity, 3.14, -Double.infinity], [Double.infinity, 3.14, -Double.infinity]))
		XCTAssertFalse(compare([nil, Double.infinity, 3.14, -Double.infinity], [nil, Double.infinity, 3.14, Double.infinity]))
	}
	
	static var allTests = [
		("testOptionalArrayCompare", testOptionalArrayCompare),
		("testOptionalValueCompare", testOptionalValueCompare),
		("testOptionalDoubleCompare", testOptionalDoubleCompare)
	]
}
