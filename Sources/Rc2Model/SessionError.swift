//
//  SessionError.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionError: String, Error, Codable {
	case unknown
	case fileNotFound
	case fileVersionMismatch
	case databaseUpdateFailed
	case failedToConnectToCompute
	case invalidRequest
	case permissionDenied
	case computeEngine
	case encoding
	case decoding
}

public enum SessionErrorCode: Int, Codable {
	case unknown = 0
	case invalidDirectory = 101
	case createDirectoryFailed = 102
	case execInvalidInput = 103
	case execMarkdownFailed = 104
	case unknownFile = 105
}
