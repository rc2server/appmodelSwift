//
//  User.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct User: Codable, Equatable, CustomDebugStringConvertible {
	public let id: Int
	public let version: Int
	public let login: String
	public let passwordHash: String?
	public let firstName: String?
	public let lastName: String?
	public let email: String
	public let isAdmin: Bool
	public let isEnabled: Bool
	
	enum CodingKeys: String, CodingKey {
		case id
		case version
		case login
		case firstName
		case lastName
		case email
		case isAdmin
		case isEnabled
	}
	
	public init(id: Int, version: Int, login: String, email: String, passwordHash: String? = nil, firstName: String? = nil, lastName: String? = nil, isAdmin: Bool = false, isEnabled: Bool = true)
	{
		self.id = id
		self.version = version
		self.login = login
		self.email = email
		self.passwordHash = passwordHash
		self.firstName = firstName
		self.lastName = lastName
		self.isEnabled = isEnabled
		self.isAdmin = isAdmin
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		version = try container.decode(Int.self, forKey: .version)
		login = try container.decode(String.self, forKey: .login)
		firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
		lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
		email = try container.decode(String.self, forKey: .email)
		isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
		isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
		passwordHash = nil
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(version, forKey: .version)
		try container.encode(login, forKey: .login)
		try container.encodeIfPresent(firstName, forKey: .firstName)
		try container.encodeIfPresent(lastName, forKey: .lastName)
		try container.encode(email, forKey: .email)
		try container.encode(isEnabled, forKey: .isEnabled)
		try container.encode(isAdmin, forKey: .isAdmin)
	}
	
	public var debugDescription: String { return "<User: \(login) \(id)" }

}
