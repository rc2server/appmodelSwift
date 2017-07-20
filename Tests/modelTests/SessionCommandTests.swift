//
//  SessionCommandTests.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import XCTest
@testable import Rc2Model

class SessionCommandTests: XCTestCase {
	
	func testExecute() {
		let execCommand = SessionCommand.makeExecute("2 * 2")
		let encoder = createEncoder()
		let data = try! encoder.encode(execCommand)
		let decoder = createDecoder()
		let command = try! decoder.decode(SessionCommand.self, from: data)
		XCTAssertEqual(execCommand, command)
	}
	
	func createEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.dataEncodingStrategy = .base64Encode
		encoder.dateEncodingStrategy = .secondsSince1970
		encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Inf", negativeInfinity: "-Inf", nan: "NaN")
		return encoder
	}
	
	func createDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dataDecodingStrategy = .base64Decode
		decoder.dateDecodingStrategy = .secondsSince1970
		decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "Inf", negativeInfinity: "-Inf", nan: "NaN")
		return decoder
	}
	
	static var allTests = [
		("testExecute", testExecute)
	]
}
