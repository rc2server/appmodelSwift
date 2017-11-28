//
//  VariableType.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation
import LoggerAPI

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
	case generic([String: Variable])
	case matrix(MatrixData)
	case array
	case list([Variable])
	/// returned as a FactorVariable
	case factor(values: [Int], levelNames: [String]?)
	case dataFrame(DataFrameData)
	case environment
	case function(String)
	case s4Object
	
	func isContainer() -> Bool {
		switch self {
		case .array, .dataFrame, .matrix, .list(_), .environment:
			return true
		default:
			return false
		}
	}
	
	public enum Errors: String, Error {
		case invalidType
	}
	
	/// the key .rawType is the raw value of this enum. Which items are actually encoded are based on that type.
	/// for example: a matrix will have .rawType = .matrix.rawValue, and .matrix = MatrixData
	private enum CodingKeys: String, CodingKey {
		case unknown
		case primitive
		case date
		case dateTime
		case generic
		case matrix
		case array
		case list
		case factor
		case factorValues
		case factorLevels
		case dataFrame
		case environment
		case function
		case s4Object
		case rawType
	}
	
	/// implementation of Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		guard let typeKey = try? container.decode(String.self, forKey: .rawType),
			let key = CodingKeys(stringValue: typeKey)
			else { throw Errors.invalidType }
		do {
			switch key {
			case .unknown:
				self = .unknown
			case .primitive:
				self = .primitive(try container.decode(PrimitiveValue.self, forKey: .primitive))
			case .date:
				self = .date(try container.decode(Date.self, forKey: .date))
			case .dateTime:
				self = .dateTime(try container.decode(Date.self, forKey: .date))
			case .generic:
				self = .generic(try container.decode([String: Variable].self, forKey: .generic))
			case .array:
				self = .array
			case .matrix:
				self = .matrix(try container.decode(MatrixData.self, forKey: .matrix))
			case .list:
				self = .list(try container.decode(Array<Variable>.self, forKey: .list))
			case .factor:
				let values = try container.decode(Array<Int>.self, forKey: .factorValues)
				let levels = try container.decodeIfPresent(Array<String>.self, forKey: .factorLevels)
				self = .factor(values: values, levelNames: levels)
			case .dataFrame:
				self = .dataFrame(try container.decode(DataFrameData.self, forKey: .dataFrame))
			case .environment:
				self = .environment
			case .function:
				self = .function(try container.decode(String.self, forKey: .function))
			case .s4Object:
				self = .s4Object
			default:
				throw Errors.invalidType
			}
		} catch {
			Log.warning("invalid VariableType: \(typeKey), error: \(error)")
			throw Errors.invalidType
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .unknown:
			try container.encode(CodingKeys.unknown.rawValue, forKey: .rawType)
		case .primitive(let pdata):
			try container.encode(CodingKeys.primitive.rawValue, forKey: .rawType)
			try container.encode(pdata, forKey: .primitive)
		case .date(let date):
			try container.encode(CodingKeys.date.rawValue, forKey: .rawType)
			try container.encode(date, forKey: .date)
		case .dateTime(let date):
			try container.encode(CodingKeys.dateTime.rawValue, forKey: .rawType)
			try container.encode(date, forKey: .dateTime)
		case .generic(let dict):
			try container.encode(CodingKeys.generic.rawValue, forKey: .rawType)
			try container.encode(dict, forKey: .generic)
		case .array:
			try container.encode(CodingKeys.array.rawValue, forKey: .rawType)
		case .matrix(let matrixData):
			try container.encode(CodingKeys.matrix.rawValue, forKey: .rawType)
			try container.encode(matrixData, forKey: .matrix)
		case .list:
			try container.encode(CodingKeys.list.rawValue, forKey: .rawType)
			try container.encode(true, forKey: .list)
		case .factor(values: let vals, levelNames: let levels):
			try container.encode(CodingKeys.factor.rawValue, forKey: .rawType)
			try container.encode(vals, forKey: .factorValues)
			try container.encodeIfPresent(levels, forKey: .factorLevels)
		case .dataFrame(let dfData):
			try container.encode(CodingKeys.dataFrame.rawValue, forKey: .rawType)
			try container.encode(dfData, forKey: .dataFrame)
		case .environment:
			try container.encode(CodingKeys.environment.rawValue, forKey: .rawType)
			try container.encode(true, forKey: .environment)
		case .function(let body):
			try container.encode(CodingKeys.function.rawValue, forKey: .rawType)
			try container.encode(body, forKey: .function)
		case .s4Object:
			try container.encode(CodingKeys.s4Object.rawValue, forKey: .rawType)
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
		case (.generic(let val1), .generic(let val2)):
			return val1 == val2
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
		case (.dataFrame(let df1), .dataFrame(let df2)):
			return df1 == df2
		case (.environment, .environment):
			return true
		case (.function(let b1), .function(let b2)):
			return b1 == b2
		case (.s4Object, .s4Object):
			return true
		default:
			return false
		}
	}
}

/// value representing the data necessary to describe a DataFrame
public struct DataFrameData: Codable, Equatable {
	/// data describing a column in a DataFrame
	public struct Column: Codable, Equatable {
		public let name: String
		public let value: PrimitiveValue

		public init(name: String, value: PrimitiveValue) {
			self.name = name
			self.value = value
		}
		
		public static func ==(lhs: DataFrameData.Column, rhs: DataFrameData.Column) -> Bool {
			return lhs.name == rhs.name && lhs.value == rhs.value
		}
	}
	
	public let columns: [Column]
	public let rowCount: Int
	public let rowNames: [String]?
	
	public init(columns: [Column], rowCount: Int, rowNames: [String]?) {
		self.columns = columns
		self.rowCount = rowCount
		self.rowNames = rowNames
	}
	
	public static func ==(lhs: DataFrameData, rhs: DataFrameData) -> Bool {
		guard lhs.columns == rhs.columns, lhs.rowCount == rhs.rowCount, compare(lhs.rowNames, rhs.rowNames) else { return false }
		return true
	}
}

/// value representing the data necessary to describe a Matrix
public struct MatrixData: Codable {
	public let value: PrimitiveValue
	public let rowCount: Int
	public let colCount: Int
	public let colNames: [String]?
	public let rowNames: [String]?
	
	public init(value: PrimitiveValue, rowCount: Int, colCount: Int, colNames: [String]?, rowNames: [String]?) {
		self.value = value
		self.rowCount = rowCount
		self.colCount = colCount
		self.colNames = colNames
		self.rowNames = rowNames
	}
}
