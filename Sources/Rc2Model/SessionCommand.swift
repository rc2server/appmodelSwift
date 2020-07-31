//
//  SessionCommand.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// a command that can be sent to the server
public enum SessionCommand: Codable, CustomStringConvertible, Hashable {
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
		case createEnvironment
		case initPreview
		case updatePreview
		case removePreview
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
	case createEnvironment(CreateEnvironmentParams)
	/// parameter is the fileId
	case initPreview(InitPreviewParams)
	/// update the results of code Chunks
	case updatePreview(UpdatePreviewParams)
	/// parramater is the previewId from the initPreview response
	case removePreview(Int)

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
			return "clear environment(\(envId))"
		case .createEnvironment(_):
			return "create environment"
		case .initPreview(let fileId):
			return "initPreview \(fileId)"
		case .updatePreview(let upData):
			return "updatePreview \(upData.previewId)/\(upData.chunkId ?? -1)"
		case.removePreview(let previewId):
			return "removePreview \(previewId)"
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
		} else if let params = try? container.decode(CreateEnvironmentParams.self, forKey: .createEnvironment) {
			self = .createEnvironment(params)
		} else if let params = try? container.decode(InitPreviewParams.self, forKey: .initPreview) {
			self = .initPreview(params)
		} else if let updateData = try? container.decode(UpdatePreviewParams.self, forKey: .updatePreview) {
			self = .updatePreview(updateData)
		} else if let previewId = try? container.decode(Int.self, forKey: .removePreview) {
			self = .removePreview(previewId)
		} else {
			modelLog.warning("failed to parse a SessionCommand")
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
			case .createEnvironment(let params):
				try container.encode(params, forKey: .createEnvironment)
			case .initPreview(let fileId):
				try container.encode(fileId, forKey: .initPreview)
			case .updatePreview(let updateData):
				try container.encode(updateData, forKey: .updatePreview);
			case .removePreview(let previewId):
				try container.encode(previewId, forKey: .removePreview)
		}
	}

	/// Parameters to execute a file
	public struct ExecuteFileParams: Codable, Hashable {
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
		/// should this command override the global watch settings
		public let watchVariables: Bool
		
		/// Create a set of parameters to execute a file
		///
		/// - Parameters:
		///   - file: the file to execute
		///   - transactionId: a unique value to associate results to this command. Defaults to a new UUID
		///   - range: the range of lines to execute. Defaults to nil (all lines)
		///   - echo: should the output be echoed
		public init(file: File, transactionId: String = UUID().uuidString, range: CountableClosedRange<Int>? = nil, echo: Bool = true, watchVariables: Bool = false)
		{
			self.fileId = file.id
			self.fileVersion = file.version
			self.transactionId = transactionId
			self.lineRange = range
			self.echo = echo
			self.watchVariables = watchVariables
		}
}
	
	/// Parameters to execute arbitrary code
	public struct ExecuteParams: Codable, Hashable {
		/// the code to execute
		public let source: String
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// true if this is being executed by the user, or false if this is an internal command that should not be visible to the user
		public let isUserInitiated: Bool
		/// the context (file) this command refers to
		public let environmentId: Int?
		/// should this command override the global watch settings
		public let watchVariables: Bool

		/// Create a a set of execution parameters
		///
		/// - Parameters:
		///   - sourceCode: the code to execute
		///   - transactionId: a unique value to associate responses with this command
		///   - userInitiated: if false, no output or record of this code should be saved
		public init(sourceCode: String, transactionId: String = UUID().uuidString, userInitiated: Bool = true, environmentId: Int?, watchVariables: Bool  = false)
		{
			self.source = sourceCode
			self.transactionId = transactionId
			self.isUserInitiated = userInitiated
			self.environmentId = environmentId
			self.watchVariables = watchVariables
		}
	}
	
	public struct VariableParams: Codable, Hashable {
		/// the name of the variable to get
		public let name: String
		/// the context to search for this variable. nil means search the global environment
		public let environmentId: Int?
		
		/// Create a set of variable parameters
		///
		/// - Parameters:
		///   - name: the name of the variable
		///   - environmentId: the id of the context to search
		public init(name: String, environmentId: Int?) {
			self.name = name
			self.environmentId = environmentId
		}
	}
	
	public struct WatchVariablesParams: Codable, Hashable {
		/// should watching be enabled or disabled
		public let watch: Bool
		/// the context to search for this variable. nil means search the global environment
		public let environmentId: Int?
		
		/// creates a struct of parameters
		///
		/// - Parameters:
		///   - watch: enable/disable watching of variables
		///   - environmentId: the id of the context to search
		public init(watch: Bool, environmentId: Int?) {
			self.watch = watch
			self.environmentId = environmentId
		}
	}
	/// Parameters to save content of a file
	public struct SaveParams: Codable, Hashable {
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
	public struct FileOperationParams: Codable, Hashable {
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
	
	/// Parameters to create an environment
	public struct CreateEnvironmentParams: Codable, Hashable {
		/// The id of the parent environment. Zero means the global enviroment
		public let parendId: Int
		/// a unique, client-specified identifier for this command to allow matching results to it
		public let transactionId: String
		/// a variable name to assign the environment to
		public let variableName: String?
	}
	
	/// Parameters to initialize a preview
	public struct InitPreviewParams: Codable, Hashable {
		/// target file of this preview
		public let fileId: Int
		/// identifier to match the response to the request
		public let updateIdentifier: String
		
		public init(fileId: Int, updateIdentifier: String) {
			self.fileId = fileId
			self.updateIdentifier = updateIdentifier
		}
	}
	
	/// parameters to execute a chunk, and optionally, all chunks preceding it
	public struct UpdatePreviewParams: Codable, Hashable {
		/// id of the preview created by .initPreview
		public let previewId: Int
		/// chunk number to execute
		public let chunkId: Int?
		/// true if all previous chunks should be executed
		public let includePrevious: Bool
		/// unique id to group updates to a single udpate command
		public let updateIdentifier: String
		
		public init(previewId: Int, chunkId: Int?, includePrevious: Bool, identifier: String = UUID().uuidString) {
			self.previewId = previewId
			self.chunkId = chunkId
			self.includePrevious = includePrevious
			self.updateIdentifier = identifier
		}
	}
}
