//
//  SessionResponse.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionResponse: Codable {
	case echoExecute(ExecuteData)
	case echoExecuteFile(ExecuteFileData)
	case error(SessionError)
	case execComplete(ExecCompleteData)
	case fileChanged(FileChangedData)
	case fileOperation(FileOperationData)
	case help(HelpData)
	case results(ResultsData)
	case save(SaveData)
	case showOutput(ShowOutputData)
	case variables([Variable])
	
	private enum CodingKeys: String, CodingKey {
		case echoExecute
		case echoExecuteFile
		case error
		case execComplete
		case fileChanged
		case fileOperation
		case help
		case results
		case save
		case showOutput
		case variables
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let data = try? container.decode(ExecuteData.self, forKey: .echoExecute) {
			self = .echoExecute(data)
		} else if let data = try? container.decode(ExecuteFileData.self, forKey: .echoExecuteFile) {
			self = .echoExecuteFile(data)
		} else if let data = try? container.decode(SessionError.self, forKey: .error) {
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
		} else if let data = try? container.decode(SaveData.self, forKey: .save) {
			self = .save(data)
		} else if let data = try? container.decode(ShowOutputData.self, forKey: .showOutput) {
			self = .showOutput(data)
		} else if let data = try? container.decode(Array<Variable>.self, forKey: .variables) {
			self = .variables(data)
		} else {
			throw SessionError.decoding
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .echoExecute(let execParams):
			try container.encode(execParams, forKey: .echoExecute)
		case .echoExecuteFile(let data):
			try container.encode(data, forKey: .echoExecuteFile)
		case .error(let err):
			try container.encode(err, forKey: .error)
		case .execComplete(let data):
			try container.encode(data, forKey: .execComplete)
		case .fileChanged(let change):
			try container.encode(change, forKey: .fileChanged)
		case .fileOperation(let data):
			try container.encode(data, forKey: .fileOperation)
		case .help(let data):
			try container.encode(data, forKey: .help)
		case .results(let data):
			try container.encode(data, forKey: .results)
		case .save(let data):
			try container.encode(data, forKey: .save)
		case .showOutput(let data):
			try container.encode(data, forKey: .showOutput)
		case .variables(let data):
			try container.encode(data, forKey: .variables)
		}
	}
	
	public struct ExecuteData: Codable, Equatable {
		public let transactionId: String
		public let source: String
		
		public init(transactionId: String, source: String) {
			self.transactionId = transactionId
			self.source = source
		}
		
		public static func == (lhs: ExecuteData, rhs: ExecuteData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.source == rhs.source
		}
	}

	public struct ExecuteFileData: Codable, Equatable {
		public let transactionId: String
		public let fileId: Int
		public let fileVersion: Int
		
		public init(transactionId: String, fileId: Int, fileVersion: Int) {
			self.transactionId = transactionId
			self.fileId = fileId
			self.fileVersion = fileVersion
		}
		
		public static func == (lhs: ExecuteFileData, rhs: ExecuteFileData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.fileId == rhs.fileId && lhs.fileVersion == rhs.fileVersion
		}
	}

	public struct ExecCompleteData: Codable, Equatable {
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
		
		public static func == (lhs: ExecCompleteData, rhs: ExecCompleteData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.batchId == rhs.batchId && lhs.expectShowOutput == rhs.expectShowOutput && lhs.images == rhs.images
		}
	}
	
	public struct FileChangedData: Codable, Equatable {
		public enum FileChangeType: String, Codable {
			case insert
			case update
			case delete
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
		
		public static func == (lhs: FileChangedData, rhs: FileChangedData) -> Bool {
			return lhs.changeType == rhs.changeType && lhs.fileId == rhs.fileId
		}
	}
	
	public struct FileOperationData: Codable, Equatable {
		public let transactionId: String
		public let operation: FileOperation
		public let success: Bool
		public let file: File?
		public let error: SessionError?
		
		public var fileIdString: String {
			guard let id = file?.id else { return "-" }
			return String(id)
		}
		
		public init(transactionId: String, operation: FileOperation, success: Bool, file: File?, error: SessionError?) {
			self.transactionId = transactionId
			self.operation = operation
			self.success = success
			self.file = file
			self.error = error
		}
		
		public static func == (lhs: FileOperationData, rhs: FileOperationData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.operation == rhs.operation && lhs.success == rhs.success && lhs.file?.id == rhs.file?.id && lhs.error == rhs.error
		}
	}
	
	public struct HelpData: Codable, Equatable {
		public let topic: String
		public let items: [String: String]
		
		public init(topic: String, items: [String: String]) {
			self.topic = topic
			self.items = items
		}
		
		public static func == (lhs: HelpData, rhs: HelpData) -> Bool {
			return lhs.topic == rhs.topic && lhs.items == rhs.items
		}
	}
	
	public struct ResultsData: Codable, Equatable {
		public let transactionId: String
		public let output: String
		public let isStdErr: Bool
		
		public init(transactionId: String, output: String, isError: Bool) {
			self.transactionId = transactionId
			self.output = output
			self.isStdErr = isError
		}
		
		public static func == (lhs: ResultsData, rhs: ResultsData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.output == rhs.output && lhs.isStdErr == rhs.isStdErr
		}
	}
	
	public struct SaveData: Codable, Equatable {
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
		
		public static func == (lhs: SaveData, rhs: SaveData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.success == rhs.success && lhs.file?.id == rhs.file?.id && lhs.error == rhs.error
		}
	}
	
	public struct ShowOutputData: Codable, Equatable {
		public let transactionId: String
		public let file: File
		/// if nil, the client should fetch the file via REST
		public let fileData: Data?
		
		public init(transactionid: String, file: File, fileData: Data?) {
			self.transactionId = transactionid
			self.file = file
			self.fileData = fileData
		}
		
		public static func == (lhs: ShowOutputData, rhs: ShowOutputData) -> Bool {
			return lhs.transactionId == rhs.transactionId && lhs.file.id == rhs.file.id && lhs.fileData == rhs.fileData
		}
	}
}

// MARK: - CustomStringConvertible
extension SessionResponse: CustomStringConvertible {
	public var description: String {
		switch self {
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
		case .results(_):
			return "results"
		case .save(_):
			return "saved"
		case .showOutput(_):
			return "show output"
		case .variables(_):
			return "variables"
		}
	}
}
