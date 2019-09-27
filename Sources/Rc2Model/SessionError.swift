//
//  SessionError.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// An error returned via REST or WebSocket
public enum SessionError: String, Error, Codable, Hashable {
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
	case encoding
	/// an error while decoding from JSON
	case decoding
	/// multiple objects met the requested criteria
	case duplicate
	/// the Compute Engine reported an error
	case compute
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
