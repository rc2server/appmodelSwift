//
//  SessionError.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// An error returned via REST or WebSocket
public enum SessionError: Error, Codable, Hashable {
	/// an unknow error happened
	case unknown
	/// the specified file was not found
	case fileNotFound
	/// an attempt to edit a file that has already been changed since the edit started
	case fileVersionMismatch
	/// failed to insert/update/delete from the database
	case databaseUpdateFailed
	/// failed to open connection to Compute Engine
	case failedToConnectToCompute
	/// the Compute Engine connection was unexpectedly closed
	case computeConnectionClosed
	/// the request , or possibly its arguments, were invalid
	case invalidRequest
	/// no user was found with the specified llogin and password
	case invalidLogin
	/// user does not have permission
	case permissionDenied
	/// an error while encoding to JSON
	case encoding(String)
	/// an error while decoding from JSON
	case decoding(String)
	/// multiple objects met the requested criteria
	case duplicate
	/// the Compute Engine reported an error
	case compute

	private enum CodingKeys: CodingKey {
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

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let _ = try? container.decode(Bool.self, forKey: .unknown) {
			self = .unknown
		} else if let _ = try? container.decode(Bool.self, forKey: .fileNotFound) {
			self = .fileNotFound
		} else if let _ = try? container.decode(Bool.self, forKey: .fileVersionMismatch) {
			self = .fileVersionMismatch
		} else if let _ = try? container.decode(Bool.self, forKey: .databaseUpdateFailed) {
			self = .databaseUpdateFailed
		} else if let _ = try? container.decode(Bool.self, forKey: .failedToConnectToCompute) {
			self = .failedToConnectToCompute
		} else if let _ = try? container.decode(Bool.self, forKey: .computeConnectionClosed) {
			self = .computeConnectionClosed
		} else if let _ = try? container.decode(Bool.self, forKey: .invalidRequest) {
			self = .invalidRequest
		} else if let _ = try? container.decode(Bool.self, forKey: .invalidLogin) {
			self = .invalidLogin
		} else if let _ = try? container.decode(Bool.self, forKey: .permissionDenied) {
			self = .permissionDenied
		} else if let _ = try? container.decode(Bool.self, forKey: .duplicate) {
			self = .duplicate
		} else if let _ = try? container.decode(Bool.self, forKey: .compute) {
			self = .compute
		} else if let desc = try? container.decode(String.self, forKey: .encoding) {
			self = .encoding(desc)
		} else if let desc = try? container.decode(String.self, forKey: .decoding) {
			self = .decoding(desc)
		} else {
			throw SessionResorationError.failedToDecode
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .unknown:
			try container.encode(true, forKey: .unknown)
		case .fileNotFound:
			try container.encode(true, forKey: .fileNotFound)
		case .fileVersionMismatch:
			try container.encode(true, forKey: .fileVersionMismatch)
		case .databaseUpdateFailed:
			try container.encode(true, forKey: .databaseUpdateFailed)
		case .failedToConnectToCompute:
			try container.encode(true, forKey: .failedToConnectToCompute)
		case .computeConnectionClosed:
			try container.encode(true, forKey: .computeConnectionClosed)
		case .invalidRequest:
			try container.encode(true, forKey: .invalidRequest)
		case .invalidLogin:
			try container.encode(true, forKey: .invalidLogin)
		case .permissionDenied:
			try container.encode(true, forKey: .permissionDenied)
		case .encoding(let str):
			try container.encode(str, forKey: .encoding)
		case .decoding(let str):
			try container.encode(str, forKey: .decoding)
		case .duplicate:
			try container.encode(true, forKey: .duplicate)
		case .compute:
			try container.encode(true, forKey: .compute)
		}
	}
}

/// Used when details need to be included with an error
public struct DetailedError: Codable {
	/// the actual error
	public let error: SessionError
	/// details about the error
	public let details: String
	
	/// initialize an error
	public init(error: SessionError, details: String) {
		self.error = error
		self.details = details
	}
}

extension SessionError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown: return "unknown error"
		case .fileNotFound: return "file not found"
		case .fileVersionMismatch: return "file has been changed by another session"
		case .databaseUpdateFailed: return "failed to update database"
		case .failedToConnectToCompute: return "failed to open connection to compute engine"
		case .computeConnectionClosed: return "connection to compute engine unexpectedly closed"
		case .invalidLogin: return "invalid login or password"
		case .invalidRequest: return "invalid request"
		case .permissionDenied: return "permission denied"
		case .encoding: return "error encoding object"
		case .decoding: return "error decoding object"
		case .duplicate: return "that object already exists"
		case .compute: return "compute error"
		}
	}
}
