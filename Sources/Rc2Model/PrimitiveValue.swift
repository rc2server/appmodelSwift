//
//  PrimitiveValue.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// The possible primitive value types
///
public enum PrimitiveValue: Codable, Equatable, CustomStringConvertible {
	case boolean([Bool?])
	case integer([Int?])
	case double([Double?])
	case string([String?])
	case complex([String?])
	case raw
	case null
	
	private enum CodingKeys: String, CodingKey {
		case boolean
		case integer
		case double
		case string
		case complex
		case raw
		case null
	}
	
	/// implementation of Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let value = try? container.decode(Array<Bool>.self, forKey: .boolean) {
			self = .boolean(value)
		} else if let value = try? container.decode(Array<Int>.self, forKey: .integer) {
			self = .integer(value)
		} else if let value = try? container.decode(Array<Double>.self, forKey: .double) {
			self = .double(value)
		} else if let value = try? container.decode(Array<String?>.self, forKey: .string) {
			self = .string(value)
		} else if let value = try? container.decode(Array<String?>.self, forKey: .complex) {
			self = .complex(value)
		} else if let _ = try? container.decode(Bool.self, forKey: .raw) {
			self = .raw
		} else if let _ = try? container.decode(Bool.self, forKey: .null) {
			self = .null
		} else {
			throw SessionError.decoding
		}
	}
	
	/// implementation of Encodable
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .boolean(let vals):
			try container.encode(vals, forKey: .boolean)
		case .integer(let vals):
			try container.encode(vals, forKey: .integer)
		case .double(let vals):
			try container.encode(vals, forKey: .double)
		case .string(let vals):
			try container.encode(vals, forKey: .string)
		case .complex(let vals):
			try container.encode(vals, forKey: .complex)
		case .raw:
			try container.encode(true, forKey: .raw)
		case .null:
			try container.encode(true, forKey: .null)
		}
	}
	
	public var description: String {
		switch self {
		case .boolean(let vals):
			return "[\((vals.map { $0 == nil ? "<NA>" : String($0!) }).joined(separator: ", "))]"
		case .integer(let vals):
			return "[\((vals.map { $0 == nil ? "<NA>" : String($0!) }).joined(separator: ", "))]"
		case .double(let vals):
			return "[\((vals.map { $0 == nil ? "<NA>" : String($0!) }).joined(separator: ", "))]"
		case .string(let vals):
			return "[\((vals.map { String($0 ?? "<NA>") }).joined(separator: ", "))]"
		case .complex(let vals):
			return "[\((vals.map { String($0 ?? "<NA>") }).joined(separator: ", "))]"
		case .raw:
			return "RAW"
		case .null:
			return "NULL"
		}
	}

	public static func == (lhs: PrimitiveValue, rhs: PrimitiveValue) -> Bool {
		switch (lhs, rhs) {
		case (.boolean(let b1), .boolean(let b2)):
			return compare(b1, b2)
		case (.integer(let i1), .integer(let i2)):
			return compare(i1, i2)
		case (.double(let d1), .double(let d2)):
			return compare(d1, d2)
		case (.string(let s1), .string(let s2)):
			return compare(s1, s2)
		case (.complex(let c1), .complex(let c2)):
			return compare(c1, c2)
		case (.raw, .raw):
			return true
		case (.null, .null):
			return true
		default:
			return false
		}
	}
}

