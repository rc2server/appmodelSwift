//
//  FileType.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct FileType: Codable {
	let name: String
	let fileExtension: String
	let uti: String
	let details: String?
	let rawMimeType: String?
	let isImportable: Bool
	let isCreatable: Bool
	let isExecutable: Bool
	let isSource: Bool
	let isDualUse: Bool
	let isText: Bool
	var isImage: Bool { return (rawMimeType ?? "").hasPrefix("image/") }
	var isEditable: Bool { return isSource || isDualUse }

	private enum CodingKeys: String, CodingKey {
		case Name
		case Extension
		case UTTypeIdentifier
		case MimeType
		case Importable
		case Creatable
		case IsSrc
		case DualUse
		case Executable
		case IsTextFile
		case IsImage
		case Description
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .Name)
		fileExtension = try container.decode(String.self, forKey: .Extension)
		uti = try container.decode(String.self, forKey: .UTTypeIdentifier)
		details = try container.decodeIfPresent(String.self, forKey: .Description)
		rawMimeType = try container.decodeIfPresent(String.self, forKey: .MimeType)
		isImportable = try container.decodeIfPresent(Bool.self, forKey: .Importable) ?? false
		isSource = try container.decodeIfPresent(Bool.self, forKey: .IsSrc) ?? false
		isDualUse = try container.decodeIfPresent(Bool.self, forKey: .DualUse) ?? false
		isText = try container.decodeIfPresent(Bool.self, forKey: .IsTextFile) ?? false
		isCreatable = try container.decodeIfPresent(Bool.self, forKey: .Creatable) ?? false
		isExecutable = try container.decodeIfPresent(Bool.self, forKey: .Executable) ?? false
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .Name)
		try container.encode(fileExtension, forKey: .Extension)
		try container.encode(uti, forKey: .UTTypeIdentifier)
		try container.encodeIfPresent(details, forKey: .Description)
		try container.encodeIfPresent(rawMimeType, forKey: .MimeType)
		if isCreatable { try container.encode(true, forKey: .Creatable) }
		if isImportable { try container.encode(true, forKey: .Importable) }
		if isExecutable { try container.encode(true, forKey: .Executable) }
		if isSource { try container.encode(true, forKey: .IsSrc) }
		if isDualUse { try container.encode(true, forKey: .DualUse) }
		if isText { try container.encode(true, forKey: .IsTextFile) }
	}
}

