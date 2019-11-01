//
//  FileType.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public struct FileType: Codable, Hashable {
	public let name: String
	public let fileExtension: String
	public let uti: String
	public let details: String?
	let rawMimeType: String?
	public let isImportable: Bool
	public let isCreatable: Bool
	public let isExecutable: Bool
	public let isSource: Bool
	public let isDualUse: Bool
	public let isText: Bool
	public var isImage: Bool { return (rawMimeType ?? "").hasPrefix("image/") }
	public var isEditable: Bool { return isSource || isDualUse }
	/// Name of Image in asset catalog to represent a file of this type.
	public let iconName: String?
	public var mimeType: String {
		if rawMimeType != nil { return rawMimeType! }
		return (isText ? "text/plain": "application/octet-stream") as String
	}

	/// array of all available FileTypes
	public static let allFileTypes: [FileType] = {
		let decoder = JSONDecoder()
		do {
			return try decoder.decode([FileType].self, from: fileTypeJson.data(using: .utf8)!)
		} catch {
			fatalError("failed to load default json: \(error)")
		}
	}()

	/// all FileTypes that are images
	public static var imageFileTypes: [FileType] = { allFileTypes.filter { return $0.isImage } }()
	/// all FileTypes that are text files
	public static var textFileTypes: [FileType] = { allFileTypes.filter { return $0.isText } }()
	/// all FileTypes that can be imported
	public static var importableFileTypes: [FileType] = { allFileTypes.filter { return $0.isImportable } }()
	/// all FileTypes that can be created
	public static var creatableFileTypes: [FileType] = { allFileTypes.filter { return $0.isCreatable } }()
	
	/// return FileType for a file extension
	///
	/// - Parameter ext: the file extension
	/// - Returns: the matching FileType, or nil if not found
	public static func fileType(withExtension ext: String) -> FileType? {
		let filtered: [FileType] = FileType.allFileTypes.filter { return $0.fileExtension == ext }
		return filtered.first
	}
	
	/// return FileType for the specified file name
	///
	/// - Parameter fileName: the name of the file
	/// - Returns: the matching FileType, or nil if not found
	public static func fileType(forFileName fileName: String) -> FileType? {
		guard let range = fileName.range(of: ".", options: .backwards) else {
			return nil
		}
		return fileType(withExtension: String(fileName[range.upperBound...]))
	}

	// capitalized since the json keys are capitalized
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
		case IconName
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .Name)
		fileExtension = try container.decode(String.self, forKey: .Extension)
		uti = try container.decode(String.self, forKey: .UTTypeIdentifier)
		details = try container.decodeIfPresent(String.self, forKey: .Description)
		rawMimeType = try container.decodeIfPresent(String.self, forKey: .MimeType)
		iconName = try container.decodeIfPresent(String.self, forKey: .IconName)
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
		try container.encodeIfPresent(iconName, forKey: .IconName)
		if isCreatable { try container.encode(true, forKey: .Creatable) }
		if isImportable { try container.encode(true, forKey: .Importable) }
		if isExecutable { try container.encode(true, forKey: .Executable) }
		if isSource { try container.encode(true, forKey: .IsSrc) }
		if isDualUse { try container.encode(true, forKey: .DualUse) }
		if isText { try container.encode(true, forKey: .IsTextFile) }
	}
}

fileprivate let fileTypeJson = """
[
	{
	"Extension": "R",
	"UTTypeIdentifier": "org.r-project.R",
	"Importable": true,
	"Creatable": true,
	"IsSrc": true,
	"Executable": true,
	"Name": "R file",
	"IsTextFile": true,
	"Description": "R source File (.R)",
	"IconName": "Rdoc"
	},
	{
	"Extension": "Rnw",
	"UTTypeIdentifier": "org.r-project.Rnw",
	"Importable": true,
	"Creatable": true,
	"IsSrc": true,
	"Executable": true,
	"IsSweave": true,
	"Name": "Sweave",
	"IsTextFile": true,
	"Description": "Sweave source file (.Rnw)",
	"IconName": "Rnw"
	},
	{
	"Extension": "Rmd",
	"UTTypeIdentifier": "org.r-project.Rmd",
	"Importable": true,
	"Creatable": true,
	"IsSrc": true,
	"Executable": true,
	"IsRMarkdown": true,
	"Name": "R markdown",
	"IsTextFile": true,
	"Description": "R markdown file (.Rmd)",
	"IconName": "Rmd"
	},
	{
	"Extension": "txt",
	"UTTypeIdentifier": "public.plain-text",
	"Importable": true,
	"Creatable": true,
	"Name": "Text",
	"IsTextFile": true,
	"DualUse": true,
	"Description": "Text file (.txt)"
	},
	{
	"Extension": "csv",
	"UTTypeIdentifier": "public.plain-text",
	"Importable": true,
	"Creatable": true,
	"Name": "CSV file",
	"IsTextFile": true,
	"DualUse": true,
	"Description": "Comma Separated Values (.csv)"
	},
	{
	"Extension": "html",
	"UTTypeIdentifier": "public.html",
	"Importable": true,
	"Creatable": true,
	"MimeType": "text/html",
	"Name": "HTML file",
	"IsTextFile": true,
	"Description": "HTML source file (.html)",
	"IconName": "htmldoc"
	},
	{
	"Extension": "pdf",
	"UTTypeIdentifier": "com.adobe.pdf",
	"Importable": true,
	"MimeType": "application/pdf",
	"Name": "PDF",
	"IsTextFile": false,
	"IconName": "pdfdoc"
	},
	{
	"Extension": "png",
	"UTTypeIdentifier": "public.png",
	"Importable": false,
	"IsImage": true,
	"MimeType": "image/png",
	"Name": "PNG image"
	},
	{
	"Extension": "jpg",
	"UTTypeIdentifier": "public.jpeg",
	"Importable": false,
	"IsImage": true,
	"MimeType": "image/jpeg",
	"Name": "JPEG image"
	},
	{
	"Extension": "gif",
	"UTTypeIdentifier": "com.compuserve.gif",
	"Importable": false,
	"IsImage": true,
	"MimeType": "image/gif",
	"Name": "GIF image"
	}
]
"""

