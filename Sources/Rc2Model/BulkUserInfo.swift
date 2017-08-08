//
//  BulkUserInfo.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct BulkUserInfo: Codable {
	/// the user in question
	public let user: User
	/// array of user's projects
	public let projects: [Project]
	/// dictionary of workspaces per project, keyed off the projectId
	public let workspaces: [Int: [Workspace]]
	/// dictionary of files per workspace, keyed off the workspaceId
	public let files: [Int: [File]]
	
	public init(user: User, projects: [Project], workspaces: [Int: [Workspace]], files: [Int: [File]])
	{
		self.user = user
		self.projects = projects
		self.workspaces = workspaces
		self.files = files
	}
}
