//
//  VariableType.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// possible variable types
public enum VariableType: Codable, Equatable {
	/// an unknown/unsupported variable
	case unknown
	/// a variable whose .primitiveType will be set to a valid value
	case primitive(PrimitiveValue)
	/// a R Date object returned as a DateVariable object
	case date(Date)
	/// an R value of type POSIXct or POSIXlt as a DateVariable object
	case dateTime(Date)
	case vector
	case matrix
	case array
	case list([Variable])
	/// returned as a FactorVariable
	case factor(values: [Int], levelNames: [String]?)
	case dataFrame
	case environment
	case function(String)
	case s3Object
	case s4Object
	
	func isContainer() -> Bool {
		switch self {
		case .array, .dataFrame, .matrix, .list(_), .environment:
			return true
		default:
			return false
		}
	}
	
	private enum CodingKeys: String, CodingKey {
		case unknown
		case primitive
		case date
		case dateTime
		case vector
		case matrix
		case array
		case list
		case factor
		case factorValues
		case factorLevels
		case dataFrame
		case environment
		case function
		case s3Object
		case s4Object
	}
	
	/// implementation of Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let _ = try? container.decode(Bool.self, forKey: .unknown) {
			self = .unknown
		} else if let value = try? container.decode(PrimitiveValue.self, forKey: .primitive) {
			self = .primitive(value)
		} else if let value = try? container.decode(Date.self, forKey: .date) {
			self = .date(value)
		} else if let value = try? container.decode(Date.self, forKey: .dateTime) {
			self = .dateTime(value)
		} else if let _ = try? container.decode(Bool.self, forKey: .vector) {
			self = .vector
		} else if let _ = try? container.decode(Bool.self, forKey: .array) {
			self = .array
		} else if let _ = try? container.decode(Bool.self, forKey: .matrix) {
			self = .matrix
		} else if let values = try? container.decode(Array<Variable>.self, forKey: .list) {
			self = .list(values)
		} else if let values = try? container.decode(Array<Int>.self, forKey: .factorValues) {
			let levels: [String]? = try container.decodeIfPresent(Array<String>.self, forKey: .factorLevels)
			self = .factor(values: values, levelNames: levels)
		} else if let _ = try? container.decode(Bool.self, forKey: .dataFrame) {
			self = .dataFrame
		} else if let _ = try? container.decode(Bool.self, forKey: .environment) {
			self = .environment
		} else if let value = try? container.decode(String.self, forKey: .function) {
			self = .function(value)
		} else if let _ = try? container.decode(Bool.self, forKey: .s3Object) {
			self = .s3Object
		} else if let _ = try? container.decode(Bool.self, forKey: .s4Object) {
			self = .s4Object
		} else {
			throw SessionError.decoding
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .unknown:
			try container.encode(true, forKey: .unknown)
		case .primitive(let pdata):
			try container.encode(pdata, forKey: .primitive)
		case .date(let date):
			try container.encode(date, forKey: .date)
		case .dateTime(let date):
			try container.encode(date, forKey: .dateTime)
		case .vector:
			try container.encode(true, forKey: .vector)
		case .array:
			try container.encode(true, forKey: .array)
		case .matrix:
			try container.encode(true, forKey: .matrix)
		case .list:
			try container.encode(true, forKey: .list)
		case .factor(values: let vals, levelNames: let levels):
			try container.encode(vals, forKey: .factorValues)
			try container.encodeIfPresent(levels, forKey: .factorLevels)
		case .dataFrame:
			try container.encode(true, forKey: .dataFrame)
		case .environment:
			try container.encode(true, forKey: .environment)
		case .function(let body):
			try container.encode(body, forKey: .function)
		case .s3Object:
			try container.encode(true, forKey: .s3Object)
		case .s4Object:
			try container.encode(true, forKey: .s4Object)
		}
	}

	public static func == (lhs: VariableType, rhs: VariableType) -> Bool {
		switch (lhs, rhs) {
		case (.unknown, .unknown):
			return true
		case (.primitive(let val1), .primitive(let val2)):
			return val1 == val2
		case (.date(let val1), .date(let val2)):
			return val1 == val2
		case (.dateTime(let val1), .dateTime(let val2)):
			return val1 == val2
		case (.vector, .vector):
			return true
		case (.matrix, .matrix):
			return true
		case (.array, .array):
			return true
		case (.list(let v1), .list(let v2)):
			return v1 == v2
		case (.factor(let v1, let l1), .factor(let v2, let l2)):
			if v1 != v2 { return false }
			if l1 == nil && l2 == nil { return true }
			guard let no1 = l1, let no2 = l2 else { return false }
			return no1 == no2
		case (.dataFrame, .dataFrame):
			return true
		case (.environment, .environment):
			return true
		case (.function(let b1), .function(let b2)):
			return b1 == b2
		case (.s3Object, .s3Object):
			return true
		case (.s4Object, .s4Object):
			return true
		default:
			return false
		}
	}
}


