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

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.wspaceId = try container.decode(Int.self, forKey: .wspaceId)
		self.bulkInfo = try container.decode(BulkUserInfo.self, forKey: .bulkInfo)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(wspaceId, forKey: .wspaceId)
		try container.encode(bulkInfo, forKey: .bulkInfo)
	}
	
	private enum CodingKeys: String, CodingKey {
		case wspaceId
		case bulkInfo
	}
}

