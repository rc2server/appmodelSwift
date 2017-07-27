//
//  SessionImage.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct SessionImage: Codable {
	public let id: Int
	public let sessionId: Int
	public let batchId: Int
	public let name: String
	public let title: String?
	public let dateCreated: Date
	public let imageData: Data
}

extension SessionImage: Equatable {
	public static func == (lhs: SessionImage, rhs: SessionImage) -> Bool {
		return lhs.id == rhs.id
	}
}
