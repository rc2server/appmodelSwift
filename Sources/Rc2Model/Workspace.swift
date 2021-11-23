//
//  Workspace.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct Workspace: Codable, Hashable {
	public let id: Int
	public let version: Int
	public let name: String
	public let userId: Int
	public let projectId: Int
	public let rootFileId: Int
	public let uniqueId: String
	public let lastAccess: Date
	public let dateCreated: Date

	public init(id: Int, version: Int, name: String, userId: Int, projectId: Int, rootFileId: Int, uniqueId: String, lastAccess: Date, dateCreated: Date)
	{
		self.id = id
		self.version = version
		self.name = name
		self.userId = userId
		self.projectId  = projectId
		self.rootFileId = rootFileId
		self.uniqueId = uniqueId
		self.lastAccess = lastAccess
		self.dateCreated = dateCreated
	}

	/// equality is based on id and version
	public static func == (lhs: Workspace, rhs: Workspace) -> Bool {
		return lhs.id == rhs.id && lhs.version == rhs.version
	}
}

/// struct for tracking a project/workspace combination
public struct WorkspaceIdentifier: Codable, Hashable, CustomStringConvertible {
	public let projectId: Int
	public let wspaceId: Int
	
	public var description: String { return "wspace \(projectId)/\(wspaceId)" }
	
	public init(projectId: Int, wspaceId: Int) {
		self.projectId = projectId
		self.wspaceId = wspaceId
	}
	
	public init?(_ wspace: Workspace?) {
		guard let wspace = wspace else { return nil }
		projectId = wspace.projectId
		wspaceId = wspace.id
	}
}
