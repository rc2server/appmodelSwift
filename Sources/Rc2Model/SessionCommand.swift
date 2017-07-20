//
//  SessionCommand.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// a command that can be sent to the server
public enum SessionCommand: Codable {
	private enum CodingKeys: String, CodingKey {
		case executeFile
		case execute
		case fileOperation
		case getVariable
		case help
		case save
		case watchVariables
	}
	
	case executeFile(ExecuteFileParams)
	case execute(ExecuteParams)
	case fileOperation(FileOperationParams)
	case getVariable(String)
	case help(String)
	case save(SaveParams)
	case watchVariables(Bool)

	/// Factory function to create a command to execute arbitrary code
	///
	/// - Parameters:
	///   - source: the code to execute
	///   - transactionId: arbitrary transaction id, defaults to a new UUID
	///   - userInitiated: did the user request this. defaults to true. If false, no output is shown.
	/// - Returns: the execute command
	public static func makeExecute(_ source: String, transactionId: String = UUID().uuidString, userInitiated: Bool = true) -> SessionCommand
	{
		return .execute(ExecuteParams(sourceCode: source, transactionId: transactionId, userInitiated: userInitiated))
	}
	
	/// implementation of Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let efile = try? container.decode(ExecuteFileParams.self, forKey: .executeFile) {
			self = .executeFile(efile)
		} else if let script = try? container.decode(ExecuteParams.self, forKey: .execute) {
			self = .execute(script)
		} else if let varname = try? container.decode(String.self, forKey: .getVariable) {
			self = .getVariable(varname)
		} else if let opparams = try? container.decode(FileOperationParams.self, forKey: .fileOperation) {
			self = .fileOperation(opparams)
		} else if let topic = try? container.decode(String.self, forKey: .help) {
			self = .help(topic)
		} else if let savep = try? container.decode(SaveParams.self, forKey: .save) {
			self = .save(savep)
		} else if let enable = try? container.decode(Bool.self, forKey: .watchVariables) {
			self = .watchVariables(enable)
		} else {
			throw SessionError.decoding
		}
	}
	
	/// implementation of Encodable
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
			case .execute(let execParams):
				try container.encode(execParams, forKey: .execute)
			case .executeFile(let fileParams):
				try container.encode(fileParams, forKey: .executeFile)
			case .fileOperation(let opParams):
				try container.encode(opParams, forKey: .fileOperation)
			case .getVariable(let varName):
				try container.encode(varName, forKey: .getVariable)
			case .help(let topic):
				try container.encode(topic, forKey: .help)
			case .save(let sparams):
				try container.encode(sparams, forKey: .save)
			case .watchVariables(let enable):
				try container.encode(enable, forKey: .watchVariables)
		}
	}

	/// Parameters to execute a file
	public struct ExecuteFileParams: Codable , Equatable {
		/// the id of the File to execute
		public let fileId: Int
		/// the latest known version of the File. An error will be generated if this does not match the version on the server
		public let fileVersion: Int
		/// the range of lines to execute
		public let lineRange: CountableClosedRange<Int>?
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// if the output of execution should be output (the `echo` parameter of the R command `source`)
		public let echo: Bool
		
		/// Create a set of parameters to execute a file
		///
		/// - Parameters:
		///   - file: the file to execute
		///   - transactionId: a unique value to associate results to this command. Defaults to a new UUID
		///   - range: the range of lines to execute. Defaults to nil (all lines)
		///   - echo: should the output be echoed
		public init(file: File, transactionId: String = UUID().uuidString, range: CountableClosedRange<Int>? = nil, echo: Bool = true)
		{
			self.fileId = file.id
			self.fileVersion = file.version
			self.transactionId = transactionId
			self.lineRange = range
			self.echo = echo
		}

		public static func ==(lhs: SessionCommand.ExecuteFileParams, rhs: SessionCommand.ExecuteFileParams) -> Bool
		{
			return lhs.fileId == rhs.fileId && lhs.fileVersion == rhs.fileVersion && lhs.transactionId == rhs.transactionId && lhs.lineRange == rhs.lineRange && lhs.echo == rhs.echo
		}
}
	
	/// Parameters to execute arbitrary code
	public struct ExecuteParams: Codable, Equatable {
		/// the code to execute
		public let source: String
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// true if this is being executed by the user, or false if this is an internal command that should not be visible to the user
		public let isUserInitiated: Bool
		
		/// Create a a set of execution parameters
		///
		/// - Parameters:
		///   - sourceCode: the code to execute
		///   - transactionId: a unique value to associate responses with this command
		///   - userInitiated: if false, no output or record of this code should be saved
		public init(sourceCode: String, transactionId: String = UUID().uuidString, userInitiated: Bool = true)
		{
			self.source = sourceCode
			self.transactionId = transactionId
			self.isUserInitiated = userInitiated
		}

		public static func ==(lhs: SessionCommand.ExecuteParams, rhs: SessionCommand.ExecuteParams) -> Bool
		{
			return lhs.source == rhs.source && lhs.transactionId == rhs.transactionId && lhs.isUserInitiated == rhs.isUserInitiated
		}
}
	
	/// Parameters to save content of a file
	public struct SaveParams: Codable, Equatable {
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// the id of the File to execute
		public let fileId: Int
		/// the latest known version of the File. An error will be generated if this does not match the version on the server
		public let fileVersion: Int
		/// the content to save to the file
		public let content: Data
		
		/// Create a set of save parameters
		///
		/// - Parameters:
		///   - file: the file to save
		///   - transactionId: a unique value to associate responses with this command
		///   - content: the updated content of the file
		public init(file: File, transactionId: String = UUID().uuidString, content: Data)
		{
			self.fileId = file.id
			self.fileVersion = file.version
			self.transactionId = transactionId
			self.content = content
		}

		public static func ==(lhs: SessionCommand.SaveParams, rhs: SessionCommand.SaveParams) -> Bool
		{
			return lhs.transactionId == rhs.transactionId && lhs.fileId == rhs.fileId && lhs.fileVersion == rhs.fileVersion && lhs.content == rhs.content
		}
	}
	
	/// Parameters to perform an operation on a file
	public struct FileOperationParams: Codable, Equatable {
		/// the operation to perform
		public let operation: FileOperation
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// the id of the File to execute
		public let fileId: Int
		/// the latest known version of the File. An error will be generated if this does not match the version on the server
		public let fileVersion: Int
		/// if the operation is `.rename`, the new name for the file
		public let newName: String?
		
		public init(file: File, operation: FileOperation, newName: String? = nil, transactionId: String = UUID().uuidString)
		{
			if operation == .rename && newName == nil {
				fatalError("rename operation must include new name")
			}
			fileId = file.id
			fileVersion = file.version
			self.transactionId = transactionId
			self.operation = operation
			self.newName = newName
		}

		public static func ==(lhs: SessionCommand.FileOperationParams, rhs: SessionCommand.FileOperationParams) -> Bool
		{
			return lhs.operation == rhs.operation && lhs.fileId == rhs.fileId && lhs.fileVersion == rhs.fileVersion && lhs.transactionId == rhs.transactionId && lhs.newName == rhs.newName
		}
	}
}

extension SessionCommand: Equatable {
	public static func ==(lhs: SessionCommand, rhs: SessionCommand) -> Bool
	{
		switch (lhs, rhs) {
		case(.execute(let params1), .execute(let params2)):
			return params1 == params2
		case(.executeFile(let params1), .executeFile(let params2)):
			return params1 == params2
		case(.getVariable(let params1), .getVariable(let params2)):
			return params1 == params2
		case(.help(let params1), .help(let params2)):
			return params1 == params2
		case(.fileOperation(let params1), .fileOperation(let params2)):
			return params1 == params2
		case(.save(let params1), .save(let params2)):
			return params1 == params2
		case(.watchVariables(let params1), .watchVariables(let params2)):
			return params1 == params2
		default:
			return false
		}
	}
	
	
}

