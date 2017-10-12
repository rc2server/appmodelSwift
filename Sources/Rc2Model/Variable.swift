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
	public let summary: String
	
	public init(name: String, length: Int, type: VariableType, className: String = "<unknown>", summary: String = "")
	{
		self.name = name
		self.length = length
		self.type = type
		self.classNameR = className
		self.summary = summary.count > 0 ? summary: "\(classNameR)[\(length)]"
	}

	/// a string representation of the value for display. e.g. for a factor, the name and number of possible values
	public var description: String { return "\(classNameR)[\(length)]" }
	
	//the number of values in this variable locally (since all R variables are vectors)
	public var count: Int { return 0 }
	
	public var isPrimitive: Bool { if case .primitive(_) = type { return true }; return false }
	public var isFactor: Bool { if case .factor(_, _) = type { return true }; return false }
	public var isDate: Bool { if case .date(_) = type { return true }; return false }
	public var isDateTime: Bool { if case .dateTime(_) = type { return true }; return false }
	
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

