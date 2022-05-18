//
//  fooDocTry3Document.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

extension UTType {
	static var exampleText: UTType {
		UTType(importedAs: "com.example.plain-text")
	}
}

struct fooDocTry3Document: FileDocument {
	var text: String
//	var scene: SCNSacene?

	init(text: String = "Hello, world!") {
		self.text = text
	}

	static var readableContentTypes: [UTType] { [.exampleText] }

	init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents,
			  let string = String(data: data, encoding: .utf8)
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
		text = string
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let data = text.data(using: .utf8)!
		return .init(regularFileWithContents: data)
	}
}
