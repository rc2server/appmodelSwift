//
//  Workspace.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct Workspace: Codable {
	public let id: Int
	public let version: Int
	public let name: String
	public let userId: Int
	public let projectId: Int
	public let uniqueId: String
	public let lastAccess: Date
	public let dateCreated: Date

	public init(id: Int, version: Int, name: String, userId: Int, projectId: Int, uniqueId: String, lastAccess: Date, dateCreated: Date)
	{
		self.id = id
		self.version = version
		self.name = name
		self.userId = userId
		self.projectId  = projectId
		self.uniqueId = uniqueId
		self.lastAccess = lastAccess
		self.dateCreated = dateCreated
	}
}
