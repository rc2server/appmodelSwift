//
//  VariableType.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation
import Logging

/// possible variable types
public enum VariableType: Codable, Hashable {
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
	case symbol(String)
	case pairlist(RPairList)
	
	func isContainer() -> Bool {
		switch self {
		case .array, .dataFrame, .matrix, .list(_), .environment, .pairlist(_):
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
		case symbol
		case pairlist
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
			case .symbol:
				self = .symbol(try container.decode(String.self, forKey: .symbol))
			case .pairlist:
				self = .pairlist(try container.decode(RPairList.self, forKey: .pairlist))
			default:
				throw Errors.invalidType
			}
		} catch {
			modelLog.warning("invalid VariableType: \(typeKey), error: \(error)")
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
		case .symbol(let name):
			try container.encode(CodingKeys.symbol.rawValue, forKey: .rawType)
			try container.encode(name, forKey: .symbol)
		case .pairlist(let plist):
			try container.encode(CodingKeys.pairlist.rawValue, forKey: .rawType)
			try container.encode(plist, forKey: .pairlist)
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
		case (.symbol(let s1), .symbol(let s2)):
			return s1 == s2
		case (.pairlist(let p1), .pairlist(let p2)):
			return p1 == p2
		default:
			return false
		}
	}
}

/// value representing the data necessary to describe a DataFrame
public struct DataFrameData: Codable, Hashable {
	/// data describing a column in a DataFrame
	public struct Column: Codable, Hashable {
		public let name: String
		public let value: PrimitiveValue

		public init(name: String, value: PrimitiveValue) {
			self.name = name
			self.value = value
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
}

/// value representing the data necessary to describe a Matrix
public struct MatrixData: Codable, Hashable {
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

/// a pair of name and value that is stored in an R pairList
public struct RPair: Codable, Hashable {
	public let key: String
	public let value: Variable
}

/// Representation of an R pairlist
public struct RPairList: Collection, Codable, Hashable, ExpressibleByArrayLiteral {

	public init(arrayLiteral elements: RPair...) {
		_values = elements
	}
	
	public typealias ArrayLiteralElement = RPair
	
	public typealias Index = Int
	public typealias Element = RPair
	
	private var _values: [RPair] = []
	
	public var startIndex: RPairList.Index { return 0 }
	public var endIndex: RPairList.Index { return _values.count }
	
	public func index(after i: RPairList.Index) -> RPairList.Index {
		return i + 1
	}
	
	public subscript(position: RPairList.Index) -> RPairList.Element {
		precondition(position >= 0 && position < _values.count, "invalid index")
		return _values[position]
	}
	
	/// Find a Pair by name. This is 0(n), complexity,  not 0(1).
	public subscript(_ key: String) -> Element? {
		return _values.first(where: { $0.key == key })
	}
	
	public func makeIterator() -> RPairList.Iterator {
		return (Iterator(values: _values))
	}
	
	/// Iterator for a PairList
	public struct Iterator: IteratorProtocol {
		public typealias Element = RPair
		var idx: Int = 0
		let values: [Element]
				
		public mutating func next() -> RPairList.Iterator.Element? {
			defer { idx += 1 }
			return idx < values.count ? values[idx] : nil
		}
	}
}
