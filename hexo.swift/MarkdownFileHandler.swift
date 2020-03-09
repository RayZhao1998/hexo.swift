//
//  MarkdownFileHandler.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import CommonCrypto
import Files
import Ink
import Plot

struct MarkdownFileHandler {
    
    static let shared = MarkdownFileHandler()
    
    let dateFormatter = DateFormatter()
    let markdownParser = MarkdownParser()
    
    init() {
        dateFormatter.locale = Locale(identifier: DATE_FORMATTER_LOCALE_IDENTIFIER)
        dateFormatter.dateFormat = DATE_FORMATTER_DATEFORMAT
    }
    
    func generateHTML(_ file: File) throws {
        let fileString = try file.readAsString()
        let markdown = markdownParser.parse(fileString)
        let metadata = markdown.metadata
        let post = Post(title: metadata["title"] ?? "",
                        description: metadata["description"] ?? "",
                        content: markdown.html,
                        createdAt: getDate(dateString: metadata["date"], fileDate: file.creationDate),
                        updatedAt: getDate(dateString: metadata["date"], fileDate: file.modificationDate))
        let titleHTML = Node.h1(
            .text(post.title)
        ).render()
        let dateHTML = Node.p(
            .text(dateFormatter.string(from: post.createdAt))
        ).render()
        let html = HTML(
            .body(
                .raw(titleHTML),
                .raw(dateHTML),
                .raw(post.content)
            )
        ).render()
        let outputFolder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR)
        let fileName = String(file.name.split(separator: ".").first ?? "undefined") + ".html"
        if (!outputFolder.containsFile(named: fileName)) {
            let output = try outputFolder.createFile(named: fileName)
            try output.write(html)
        } else {
            let output = try outputFolder.file(named: fileName)
            if (SHA256(string: try output.readAsString()) != SHA256(string: html)) {
                try output.write(html)
            }
        }
    }
    
    private func SHA256(string: String) -> Data {
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    private func getDate(dateString: String?, fileDate: Date?) -> Date {
        if let fileDate = fileDate {
            return fileDate
        }
        if let dateString = dateString {
            return dateFormatter.date(from: dateString) ?? Date()
        }
        return Date()
    }
}
