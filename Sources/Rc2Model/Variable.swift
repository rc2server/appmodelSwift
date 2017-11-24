//
//  Variable.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

open class Variable: Codable, Equatable, CustomStringConvertible {
	public let name: String
	public let length: Int
	public let type: VariableType
	public let classNameR: String
	///a more descriptive description: e.g. for a factor, list all the values
	public let _summary: String?
	
	public init(name: String, length: Int, type: VariableType, className: String = "<unknown>", summary: String = "")
	{
		self.name = name
		self.length = length
		self.type = type
		self.classNameR = className
		_summary = summary.count > 0 ? summary: nil
	}

	/// a string representation of the value for display. e.g. for a factor, the name and number of possible values
	public var description: String { return "\(classNameR)[\(length)]" }
	
	public var summary: String {
		switch type {
		case .primitive(let pval):
			return pval.description
		default:
			return _summary ?? description
		}
	}
	
	//the number of values in this variable locally (since all R variables are vectors)
	public var count: Int { return 0 }
	
	public var isPrimitive: Bool { if case .primitive(_) = type { return true }; return false }
	public var isFactor: Bool { if case .factor = type { return true }; return false }
	public var isDate: Bool { if case .date = type { return true }; return false }
	public var isDateTime: Bool { if case .dateTime = type { return true }; return false }

	/// if a primitive type, the primitive value
	public var primitiveValue: PrimitiveValue? { if case .primitive(let pval) = type { return pval }; return nil }
	/// the date value if this variable represents a date or datetime
	public var dateValue: Date? {
		switch type {
			case .date(let dval): return dval
			case .dateTime(let dval): return dval
			default: return nil
		}
	}
	/// if this variable is a matrix, the matrix data
	public var matrixData: MatrixData? { if case .matrix(let data) = type { return data }; return nil }
	/// if htis variable is a data frame, the dataFrame data
	public var dataFrameData: DataFrameData? { if case .dataFrame(let data) = type { return data }; return nil }
	
	///if a function type, returns the source code for the function
	public var functionBody: String? { if case let .function(val) = type { return val }; return nil }
	///if a factor, returns the levels
	public var levels: [String]? { return nil }
	
	public static func == (lhs: Variable, rhs: Variable) -> Bool {
		return lhs.name == rhs.name && lhs.count == rhs.count && lhs.type == rhs.type && lhs.classNameR == rhs.classNameR && lhs.summary == rhs.summary
	}
}

extension Variable {
	static public func compareByName (lhs: Variable, rhs: Variable) -> Bool {
		//compare based on name. TODO: used to allow nil names. Is that really possible?
		return lhs.name < rhs.name
	}
}

//public final class GenericVariable: Variable {
//	fileprivate let values: [Variable]
//
//	override init(json: JSON) throws {
//		values = try json.getArray(at: "value").map { try Variable.variableForJson($0) }
//		try super.init(json: json)
//	}
//
//	override public var count: Int { return values.count }
//
//	override public func stringValueAtIndex(_ index: Int) -> String? {
//		return values[index].description
//	}
//
//	override public func variableAtIndex(_ index: Int) -> Variable? { return values[index] }
//}

