//
//  SessionError.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionError: RawRepresentable, Error, Codable, Equatable {
	public typealias RawValue = String
	
	case unknown
	case fileNotFound
	case fileVersionMismatch
	case databaseUpdateFailed
	case failedToConnectToCompute
	case invalidRequest
	case permissionDenied
	case encoding
	case decoding
	case compute(code: SessionErrorCode, details: String?, transactionId: String?)

	public init?(rawValue: String) {
		switch rawValue {
			case "unknown": self = .unknown
			case "fileNotFound": self = .fileNotFound
			case "fileVersionMismatch": self = .fileVersionMismatch
			case "databaseUpdateFailed": self = .databaseUpdateFailed
			case "failedToConnectToCompute": self = .failedToConnectToCompute
			case "invalidRequest": self = .invalidRequest
			case "permissionDenied": self = .permissionDenied
			case "encoding": self = .encoding
			case "decoding": self = .decoding
			default: return nil
		}
	}
	
	public var rawValue: String {
		switch self {
		case .unknown: return "unknown"
		case .fileNotFound: return "fileNotFound"
		case .fileVersionMismatch: return "fileVersionMismatch"
		case .databaseUpdateFailed: return "databaseUpdateFailed"
		case .failedToConnectToCompute: return "failedToConnectToCompute"
		case .invalidRequest: return "invalidRequest"
		case .permissionDenied: return "permissionDenied"
		case .encoding: return "encoding"
		case .decoding: return "decoding"
		case .compute(code: let scode, details: _, transactionId: _): return "compute: \(scode.rawValue)"
		}
	}
	
	private enum CodingKeys: String, CodingKey {
		case type
		case code
		case details
		case transactionId
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let rvalue = try container.decode(String.self, forKey: .type)
		if rvalue == "compute" {
			let rawcode = try container.decode(Int.self, forKey: .code)
			guard let code = SessionErrorCode.init(rawValue: rawcode) else { throw SessionError.decoding }
			let details = try container.decodeIfPresent(String.self, forKey: .details)
			let transId = try container.decodeIfPresent(String.self, forKey: .transactionId)
			self = .compute(code: code, details: details, transactionId: transId)
		} else {
			self = SessionError(rawValue: rvalue)!
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if case let SessionError.compute(code: ecode, details: edetails, transactionId: transId) = self {
			try container.encode("compute", forKey: .type)
			try container.encode(ecode.rawValue, forKey: .code)
			try container.encodeIfPresent(edetails, forKey: .details)
			try container.encodeIfPresent(transId, forKey: .transactionId)
		} else {
			try container.encode(rawValue, forKey: .type)
		}
	}
	
	public static func == (lhs: SessionError, rhs: SessionError) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
}

public enum SessionErrorCode: Int, Codable {
	case unknown = 0
	case invalidDirectory = 101
	case createDirectoryFailed = 102
	case execInvalidInput = 103
	case execMarkdownFailed = 104
	case unknownFile = 105
}
