//
//  RestInfo.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// structure returned from a create workspace REST command
public struct CreateWorkspaceResult: Codable {
	public let wspaceId: Int
	public let bulkInfo: BulkUserInfo
	
	public init(wspaceId: Int, bulkInfo: BulkUserInfo) {
		self.wspaceId = wspaceId
		self.bulkInfo = bulkInfo
	}
}

