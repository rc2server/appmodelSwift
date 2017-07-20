//
//  FileOperation.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// the type of file operations that can be performed
public enum FileOperation: String, Codable {
	case remove
	case rename
	case duplicate
}
