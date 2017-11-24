//
//  ComparisonHelpers.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// Compares two arrays of optionals
/// - Parameter array1: An array of T?
/// - Parameter array2: An array of T?
/// - Returns: true if the array elements are equal
internal func compare<T: Equatable>(_ array1: [T?], _ array2: [T?]) -> Bool {
	guard array1.count == array2.count else { return false }
	for index in array1.indices {
		if array1[index] == nil && array2[index] == nil { continue }
		if array1[index] == nil || array2[index] == nil { return false }
		let val1 = array1[index], val2 = array2[index]
		if val1 != val2 { return false }
	}
	return true
}

/// Compares two optional arrays
/// - Parameter array1: An optional array of T
/// - Parameter array2: An optional array of T
/// - Returns: true if the arrays are equal
internal func compare<T: Equatable>(_ value1: [T]?, _ value2: [T]?) -> Bool {
	if value1 == nil && value2 == nil { return true }
	if value1 == nil || value2 == nil { return false }
	return value1! == value2!
}
