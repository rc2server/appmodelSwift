//
//  CountableClosedRange+Codable.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// extension to implement Codable for a CountableClosedRange with Bound == Int
/// the `where Bound == Int` will be added once SE-0143 is implemented
extension CountableClosedRange: Codable {
	private enum CodingKeys: String, CodingKey {
		case lowerBound
		case upperBound
	}
	
	/// Decodable support
	///
	/// - Warning: Only works with Bounds == Int. Can't constrain extension until SE-0143 is implemented
	/// - Parameter decoder: the decoder
	/// - Throws: decoding error
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let lb = try container.decode(Int.self, forKey: .lowerBound) as! Bound
		let ub = try container.decode(Int.self, forKey: .upperBound) as! Bound
		self.init(uncheckedBounds: (lb, ub))
	}
	
	/// Encodable support
	///
	/// - Warning: Only works with Bounds == Int. Can't constrain extension until SE-0143 is implemented
	/// - Parameter encoder: the encoder
	/// - Throws: encoding error
	public func encode(to encoder: Encoder) throws {
		guard let lbound = lowerBound as? Int,
			let ubound = upperBound as? Int
			else { fatalError("only Int range types supported")}
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(lbound, forKey: .lowerBound)
		try container.encode(ubound, forKey: .upperBound)
	}
}

