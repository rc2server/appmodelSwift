//
//  SessionCommand.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// a command that can be sent to the server
public enum SessionCommand: Codable, CustomStringConvertible, Equatable {
	private enum CodingKeys: String, CodingKey {
		case executeFile
		case execute
		case fileOperation
		case getVariable
		case help
		case info
		case save
		case watchVariables
		case clearEnvironment
	}
	
	case executeFile(ExecuteFileParams)
	case execute(ExecuteParams)
	case fileOperation(FileOperationParams)
	case getVariable(VariableParams)
	case help(String)
	case info
	case save(SaveParams)
	/// the environment id, 0 for global
	case clearEnvironment(Int)
	/// if true, send all values. Even if was already true
	case watchVariables(WatchVariablesParams)

	public var description: String {
		switch self {
		case .execute(_):
			return "execute"
		case .executeFile(let params):
			return "executeFile \(params.fileId)"
		case .fileOperation(let op):
			return "fileOperation \(op.operation.rawValue)"
		case .getVariable(let varname):
			return "getVariable \(varname)"
		case .help(let topic):
			return "help \(topic)"
		case .info:
			return "workspace info"
		case .save(let saveinfo):
			return "save \(saveinfo.fileId)"
		case .watchVariables(let turnon):
			return "watchVariables \(turnon)"
		case .clearEnvironment(let envId):
			return "clear Environment(\(envId))"
		}
	}
	
	/// implementation of Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let efile = try? container.decode(ExecuteFileParams.self, forKey: .executeFile) {
			self = .executeFile(efile)
		} else if let script = try? container.decode(ExecuteParams.self, forKey: .execute) {
			self = .execute(script)
		} else if let varParams = try? container.decode(VariableParams.self, forKey: .getVariable) {
			self = .getVariable(varParams)
		} else if let opparams = try? container.decode(FileOperationParams.self, forKey: .fileOperation) {
			self = .fileOperation(opparams)
		} else if let topic = try? container.decode(String.self, forKey: .help) {
			self = .help(topic)
		} else if let _ = try? container.decode(Bool.self, forKey: .info) {
			self = .info
		} else if let savep = try? container.decode(SaveParams.self, forKey: .save) {
			self = .save(savep)
		} else if let enable = try? container.decode(WatchVariablesParams.self, forKey: .watchVariables) {
			self = .watchVariables(enable)
		} else if let envId = try? container.decode(Int.self, forKey: .clearEnvironment) {
			self = .clearEnvironment(envId)
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
			case .getVariable(let varParams):
				try container.encode(varParams, forKey: .getVariable)
			case .help(let topic):
				try container.encode(topic, forKey: .help)
			case .info:
				try container.encode(true, forKey: .info)
			case .save(let sparams):
				try container.encode(sparams, forKey: .save)
			case .watchVariables(let enable):
				try container.encode(enable, forKey: .watchVariables)
			case .clearEnvironment(let envId):
				try container.encode(envId, forKey: .clearEnvironment)
		}
	}

	/// Parameters to execute a file
	public struct ExecuteFileParams: Codable, Equatable {
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
}
	
	/// Parameters to execute arbitrary code
	public struct ExecuteParams: Codable, Equatable {
		/// the code to execute
		public let source: String
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// true if this is being executed by the user, or false if this is an internal command that should not be visible to the user
		public let isUserInitiated: Bool
		/// the context (file) this command refers to
		public let contextId: Int?
		
		/// Create a a set of execution parameters
		///
		/// - Parameters:
		///   - sourceCode: the code to execute
		///   - transactionId: a unique value to associate responses with this command
		///   - userInitiated: if false, no output or record of this code should be saved
		public init(sourceCode: String, transactionId: String = UUID().uuidString, userInitiated: Bool = true, contextId: Int?)
		{
			self.source = sourceCode
			self.transactionId = transactionId
			self.isUserInitiated = userInitiated
			self.contextId = contextId
		}
	}
	
	public struct VariableParams: Codable, Equatable {
		/// the name of the variable to get
		public let name: String
		/// the context to search for this variable. nil means search the global environment
		public let contextId: Int?
		
		/// Create a set of variable parameters
		///
		/// - Parameters:
		///   - name: the name of the variable
		///   - contextId: the id of the context to search
		public init(name: String, contextId: Int?) {
			self.name = name
			self.contextId = contextId
		}
	}
	
	public struct WatchVariablesParams: Codable, Equatable {
		/// should watching be enabled or disabled
		public let watch: Bool
		/// the context to search for this variable. nil means search the global environment
		public let contextId: Int?
		
		/// creates a struct of parameters
		///
		/// - Parameters:
		///   - watch: enable/disable watching of variables
		///   - contextId: the id of the context to search
		public init(watch: Bool, contextId: Int?) {
			self.watch = watch
			self.contextId = contextId
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
	}
}
