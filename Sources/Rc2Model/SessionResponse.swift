//
//  SessionResponse.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionResponse {
	case echoQuery(EchoData)
	case error(SessionError)
	case execComplete(ExecCompleteData)
	case fileChanged(FileChangedData)
	case fileOperation(FileOperationData)
	case help(HelpData)
	case results(ResultsData)
	case save(SaveData)
	case showOutput(ShowOutputData)
	case variables
	
	public struct EchoData: Codable {
		let transactionId: String
		let fileId: Int
		let fileVersion: Int
		let source: String
	}
	
	public struct ExecCompleteData: Codable {
		let batchId: Int
		let transactionId: Int
		let expectShowOutput: Bool
		let images: [SessionImage]
	}
	
	public struct FileChangedData: Codable {
		public enum FileChangeType: String, Codable {
			case insert
			case update
			case delete
		}
		let changeType: FileChangeType
		let fileId: Int
		let file: File?
	}
	
	public struct FileOperationData: Codable {
		let transactionId: String
		let operation: FileOperation
		let success: Bool
		let file: File?
		let error: SessionError?
	}
	
	public struct HelpData: Codable {
		let topic: String
		let items: [String: String]
	}
	
	public struct ResultsData: Codable {
		let transactionId: String
		let output: String
		let isStdErr: Bool
	}
	
	public struct SaveData: Codable {
		let transactionId: String
		let success: Bool
		let file: File?
		let error: SessionError?
	}
	
	public struct ShowOutputData: Codable {
		let transactionId: String
		let file: File
		let fileData: Data
	}
}
