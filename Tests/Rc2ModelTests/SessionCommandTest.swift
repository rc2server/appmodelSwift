//
//  SessionCommandTest.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import XCTest
@testable import Rc2Model

class SessionCommandTest: XCTestCase, Rc2TestAdditions {
	
	func testExecute() {
		let execCommand = SessionCommand.execute(SessionCommand.ExecuteParams(sourceCode: "2 * 2", contextId: nil))
		let encoder = createEncoder()
		let data = try! encoder.encode(execCommand)
		let decoder = createDecoder()
		let command = try! decoder.decode(SessionCommand.self, from: data)
		XCTAssertEqual(execCommand, command)
	}
	
	static var allTests = [
		("testExecute", testExecute)
	]
}
