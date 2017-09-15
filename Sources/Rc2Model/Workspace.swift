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

/// struct for tracking a project/workspace combination
public struct WorkspaceIdentifier: Codable, Hashable, CustomStringConvertible {
	public let projectId: Int
	public let wspaceId: Int
	
	public var description: String { return "wspace \(projectId)/\(wspaceId)" }
	// read on the Interwebs that multiplying by a weird constant will prevent equal values from hashing the same
	public var hashValue: Int { return projectId.hashValue ^ (wspaceId.hashValue &* 9_874_431) }
	
	public init(projectId: Int, wspaceId: Int) {
		self.projectId = projectId
		self.wspaceId = wspaceId
	}
	
	public init?(_ wspace: Workspace?) {
		guard let wspace = wspace else { return nil }
		projectId = wspace.projectId
		wspaceId = wspace.id
	}
	
	public static func == (lhs: WorkspaceIdentifier, rhs: WorkspaceIdentifier) -> Bool {
		return lhs.projectId == rhs.projectId && lhs.wspaceId == rhs.wspaceId
	}
}
