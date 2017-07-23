//
//  BaseTest.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import XCTest

protocol Rc2TestAdditions {}

extension Rc2TestAdditions {
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
}
