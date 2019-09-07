//
//  Project.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct Project: Codable, Hashable {
	public let id: Int
	public let version: Int
	public let userId: Int
	public let name: String
	
	public init(id: Int, version: Int, userId: Int, name: String) {
		self.id = id
		self.version = version
		self.userId = userId
		self.name = name
	}
}
