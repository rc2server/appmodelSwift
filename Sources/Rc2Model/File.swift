//
//  File.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct File: Codable, Hashable, CustomStringConvertible {
	/// old client property name, should be changed to `id`
	@available(*, deprecated)
	public var fileId: Int { return id }

	public let id: Int
	public let wspaceId: Int
	public let name: String
	public let version: Int
	public let dateCreated: Date
	public let lastModified: Date
	public let fileSize: Int
	public let path: String
	public let directory: Bool
	public let children: [Int]?

	public init(id: Int, wspaceId: Int, name: String, version: Int, dateCreated: Date, lastModified: Date, fileSize: Int, path: String, directory: Bool = false, 
		children: [Int]? = nil)
	{
		self.id = id
		self.name = name
		self.wspaceId = wspaceId
		self.version = version
		self.dateCreated = dateCreated
		self.lastModified = lastModified
		self.fileSize = fileSize
		self.path = path
		self.directory = directory
		self.children = children
	}

	/// value used in REST calls to allow http caching of file contents
	public var eTag: String { return "f/\(id)/\(version)" }
	
	public var description: String {
		return "<File: \(name) (\(id) v\(version))>"
	}

	/// equality is based on id and version
	public static func == (lhs: File, rhs: File) -> Bool {
		return lhs.id == rhs.id && lhs.version == rhs.version
	}
}

