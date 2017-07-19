//
//  SessionCommand.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public enum SessionCommand {
	case executeFile(ExecuteFileParams)
	case execute(ExecuteParams)
	case fileOperation
	case getVariable(variableName: String)
	case help(topic: String)
	case save(SaveParams)
	case watchVariables(enable: Bool)
	
	/// Parameters to execute a file
	public struct ExecuteFileParams {
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
	public struct ExecuteParams {
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
	}
	
	public struct SaveParams {
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
}
