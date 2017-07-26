//
//  File.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct File: Codable {
	let id: Int
	let wspaceId: Int
	let name: String
	let version: Int
	let dateCreated: Date
	let lastModified: Date
	let fileSize: Int
	
	public init(id: Int, wspaceId: Int, name: String, version: Int, dateCreated: Date, lastModified: Date, fileSize: Int)
	{
		self.id = id
		self.name = name
		self.wspaceId = wspaceId
		self.version = version
		self.dateCreated = dateCreated
		self.lastModified = lastModified
		self.fileSize = fileSize
	}
}
