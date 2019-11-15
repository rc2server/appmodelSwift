//
//  SessionResponse.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionResponse: Codable {
	case computeStatus(ComputeStatus)
	case connected(BulkUserInfo)
	case closed(CloseData)
	case echoExecute(ExecuteData)
	case echoExecuteFile(ExecuteFileData)
	case error(ErrorData)
	case execComplete(ExecCompleteData)
	case fileChanged(FileChangedData)
	case fileOperation(FileOperationData)
	case help(HelpData)
	case info(InfoData)
	case results(ResultsData)
	case save(SaveData)
	case showOutput(ShowOutputData)
	case variableValue(VariableValueData)
	case variables(ListVariablesData)
	case environmentCreated(CreatedEnvironment)
	
	private enum CodingKeys: String, CodingKey {
		case computeStatus
		case connected
		case closed
		case echoExecute
		case echoExecuteFile
		case codedError
		case execComplete
		case fileChanged
		case fileOperation
		case help
		case info
		case results
		case save
		case showOutput
		case variables
		case variableValue
		case environmentCreated
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let data = try? container.decode(ExecuteData.self, forKey: .echoExecute) {
			self = .echoExecute(data)
		} else if let data = try? container.decode(ExecuteFileData.self, forKey: .echoExecuteFile) {
			self = .echoExecuteFile(data)
		} else if let data = try? container.decode(CloseData.self, forKey: .closed) {
			self = .closed(data)
		} else if let data = try? container.decode(ErrorData.self, forKey: .codedError) {
			self = .error(data)
		} else if let data = try? container.decode(ExecCompleteData.self, forKey: .execComplete) {
			self = .execComplete(data)
		} else if let data = try? container.decode(FileChangedData.self, forKey: .fileChanged) {
			self = .fileChanged(data)
		} else if let data = try? container.decode(FileOperationData.self, forKey: .fileOperation) {
			self = .fileOperation(data)
		} else if let data = try? container.decode(HelpData.self, forKey: .help) {
			self = .help(data)
		} else if let data = try? container.decode(ResultsData.self, forKey: .results) {
			self = .results(data)
		} else if let data = try? container.decode(InfoData.self, forKey: .info) {
			self = .info(data)
		} else if let data = try? container.decode(SaveData.self, forKey: .save) {
			self = .save(data)
		} else if let data = try? container.decode(ShowOutputData.self, forKey: .showOutput) {
			self = .showOutput(data)
		} else if let data = try? container.decode(ListVariablesData.self, forKey: .variables) {
			self = .variables(data)
		} else if let data = try? container.decode(BulkUserInfo.self, forKey: .connected) {
			self = .connected(data)
		} else if let data = try? container.decode(VariableValueData.self, forKey: .variableValue) {
			self = .variableValue(data)
		} else if let status = try? container.decode(ComputeStatus.self, forKey: .computeStatus) {
			self = .computeStatus(status)
		} else if let data = try? container.decode(CreatedEnvironment.self, forKey: .environmentCreated) {
			self = .environmentCreated(data)
		} else {
			throw SessionError.decoding
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .connected(let bulkInfo):
			try container.encode(bulkInfo, forKey: .connected)
		case .closed(let closeData):
			try container.encode(closeData, forKey: .closed)
		case .echoExecute(let execParams):
			try container.encode(execParams, forKey: .echoExecute)
		case .echoExecuteFile(let data):
			try container.encode(data, forKey: .echoExecuteFile)
		case .error(let err):
			try container.encode(err, forKey: .codedError)
		case .execComplete(let data):
			try container.encode(data, forKey: .execComplete)
		case .fileChanged(let change):
			try container.encode(change, forKey: .fileChanged)
		case .fileOperation(let data):
			try container.encode(data, forKey: .fileOperation)
		case .help(let data):
			try container.encode(data, forKey: .help)
		case .info(let data):
			try container.encode(data, forKey: .info)
		case .results(let data):
			try container.encode(data, forKey: .results)
		case .save(let data):
			try container.encode(data, forKey: .save)
		case .showOutput(let data):
			try container.encode(data, forKey: .showOutput)
		case .variables(let data):
			try container.encode(data, forKey: .variables)
		case .variableValue(let data):
			try container.encode(data, forKey: .variableValue)
		case .computeStatus(let status):
			try container.encode(status, forKey: .computeStatus)
		case .environmentCreated(let data):
			try container.encode(data, forKey: .environmentCreated)
		}
	}
	
	public enum ComputeStatus: String, Codable {
		/// normal operational state, accepting commands
		case running
		/// setting up the initial connection
		case initializing
		/// a prolonged activity has to happen before can reach the running state (such as downloading a docker image)
		case loading
		/// the connection was closed/dropped and is being reopened. Functionally the same as initializing, but distinct to the user
		case reconnecting
		/// failed to connect and not likely to happen in the next few minutes. Try again later.
		case failed
	}
	
	public struct CloseData: Codable, Hashable {
		public enum CloseReason: String, Codable, CaseIterable {
			case computeClosed
			case unknown
		}
		public let reason: CloseReason
		public let details: String?
		
		public init(reason: CloseReason, details: String? = nil) {
			self.reason = reason
			self.details = details
		}
	}
	
	public struct ExecuteData: Codable, Hashable {
		public let transactionId: String
		public let source: String
		public let environmentId: Int?
		
		public init(transactionId: String, source: String, environmentId: Int?) {
			self.transactionId = transactionId
			self.source = source
			self.environmentId = environmentId
		}
	}

	public struct ExecuteFileData: Codable, Hashable {
		public let transactionId: String
		public let fileId: Int
		public let fileVersion: Int
		
		public init(transactionId: String, fileId: Int, fileVersion: Int) {
			self.transactionId = transactionId
			self.fileId = fileId
			self.fileVersion = fileVersion
		}
	}

	public struct ExecCompleteData: Codable, Hashable {
		public let transactionId: String
		public let batchId: Int
		public let expectShowOutput: Bool
		public let images: [SessionImage]
		
		public init(transactionId: String, batchId: Int, expectShowOutput: Bool, images: [SessionImage]) {
			self.transactionId = transactionId
			self.batchId = batchId
			self.expectShowOutput = expectShowOutput
			self.images = images
		}
	}
	
	public struct FileChangedData: Codable, Hashable, CustomStringConvertible {
		public enum FileChangeType: String, Codable {
			case insert = "i"
			case update = "u"
			case delete = "d"
		}
		public let changeType: FileChangeType
		public let fileId: Int
		/// the file won't be available if it was deleted
		public let file: File?
		
		public init(type: FileChangeType, file: File?, fileId: Int) {
			self.changeType = type
			self.fileId = fileId
			self.file = file
		}
		
		public var description: String {
			return "file \(fileId) change: \(changeType)"
		}
	}
	
	public struct FileOperationData: Codable, Hashable {
		public let transactionId: String
		public let operation: FileOperation
		public let success: Bool
		public let fileId: Int
		/// file data only included when a file was duplicated
		public let file: File?
		public let error: SessionError?
		
		public var fileIdString: String {
			return String(fileId)
		}
		
		public init(transactionId: String, operation: FileOperation, success: Bool, fileId: Int, file: File?, error: SessionError?)
		{
			self.transactionId = transactionId
			self.operation = operation
			self.success = success
			self.fileId = fileId
			self.file = file
			self.error = error
		}
	}
	
	public struct HelpData: Codable, Hashable, CustomStringConvertible {
		public let topic: String
		public let items: [String: String]
		
		public init(topic: String, items: [String: String]) {
			self.topic = topic
			self.items = items
		}
		
		public var description: String {
			return "Help topic: \(topic): " + items.map { "\($0.0)=\($0.1)"}.joined(separator: ",")
		}
	}
	
	public struct InfoData: Codable, Hashable {
		public let workspace: Workspace
		public let files: [File]
		
		public init(workspace: Workspace, files: [File]) {
			self.workspace = workspace
			self.files = files
		}
	}

	public struct ResultsData: Codable, Hashable {
		public let transactionId: String
		public let output: String
		public let isStdErr: Bool
		
		public init(transactionId: String, output: String, isError: Bool) {
			self.transactionId = transactionId
			self.output = output
			self.isStdErr = isError
		}
	}
	
	public struct ErrorData: Codable, Hashable {
		public let transactionId: String?
		public let error: SessionError
		public let details: String?

		public init(transactionId: String?, error: SessionError, details: String? = nil) {
			self.transactionId = transactionId
			self.error = error
			self.details = details
		}
	}
	
	public struct SaveData: Codable, Hashable {
		public let transactionId: String
		public let success: Bool
		public let file: File?
		public let error: SessionError?
		
		public init(transactionId: String, success: Bool, file: File?, error: SessionError?) {
			self.transactionId = transactionId
			self.success = success
			self.file = file
			self.error = error
		}
	}
	
	public struct ShowOutputData: Codable, Hashable {
		public let transactionId: String
		public let file: File
		/// if nil, the client should fetch the file via REST
		public let fileData: Data?
		
		public init(transactionid: String, file: File, fileData: Data?) {
			self.transactionId = transactionid
			self.file = file
			self.fileData = fileData
		}
	}
	
	public struct VariableValueData: Codable, Hashable {
		public let value: Variable
		public let environmentId: Int?
		
		public init(value: Variable, environmentId: Int?) {
			self.value = value
			self.environmentId = environmentId
		}
	}
	
	public struct ListVariablesData: Codable, Hashable {
		public let variables: [String: Variable]
		public let removed: [String]
		public let environmentId: Int?
		public let delta: Bool
		
		public init(values: [String: Variable], removed: [String], environmentId: Int?, delta: Bool) {
			self.variables = values
			self.delta = delta
			self.removed = removed
			self.environmentId = environmentId
		}
	}
	
	public struct CreatedEnvironment: Codable, Hashable {
		public let transactionId: String
		public let environmentId: Int
		
		public init(transactionId: String, environmentId: Int) {
			self.transactionId = transactionId
			self.environmentId = environmentId
		}
	}
}

// MARK: - CustomStringConvertible
extension SessionResponse: CustomStringConvertible {
	public var description: String {
		switch self {
		case .connected(_):
			return "connected"
		case .closed(_):
			return "closed"
		case .echoExecute(_):
			return "echo execute"
		case .echoExecuteFile(let data):
			return "echo execute file \(data.fileId)"
		case .error(_):
			return "error"
		case .execComplete(_):
			return "execute complete"
		case .fileChanged(let change):
			return "file \(change.fileId) changed"
		case .fileOperation(let data):
			return "file operation \(data.operation) \(data.fileIdString)"
		case .help(let data):
			return "help on \(data.topic)"
		case .info(_):
			return "info for workspace"
		case .results(_):
			return "results"
		case .save(_):
			return "saved"
		case .showOutput(_):
			return "show output"
		case .variables(_):
			return "variables"
		case .variableValue(_):
			return "single variable"
		case .computeStatus(let status):
			return "compute status update: \(status)"
		case .environmentCreated(_):
			return "created environment"
		}
	}
}
