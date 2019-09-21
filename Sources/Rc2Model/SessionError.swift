//
//  SessionError.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// An error returned via REST or WebSocket
public enum SessionError: String, Error, Codable, Hashable {
	public typealias RawValue = String
	
	case unknown
	case fileNotFound
	case fileVersionMismatch
	case databaseUpdateFailed
	case failedToConnectToCompute
	case computeConnectionClosed
	case invalidRequest
	case invalidLogin
	case permissionDenied
	case encoding
	case decoding
	case duplicate
	case compute
}

/// Used when details need to be included with an error
public struct DetailedError: Codable {
	/// the actual error
	public let error: SessionError
	/// details about the error
	public let details: String
	
	public init(error: SessionError, details: String) {
		self.error = error
		self.details = details
	}
}

/// Compatible with error codes sent from the compute server
public enum SessionErrorCode: Int, Codable {
	case unknown = 0
	case invalidDirectory = 101
	case createDirectoryFailed = 102
	case execInvalidInput = 103
	case execMarkdownFailed = 104
	case unknownFile = 105
}
