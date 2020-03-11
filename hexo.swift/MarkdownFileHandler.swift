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
    
    func generateHTML(_ file: File, styleSheet: [String]? = nil, scripts: [String: String]? = nil) throws {
        let fileString = try file.readAsString()
        let markdown = markdownParser.parse(fileString)
        let metadata = markdown.metadata
        let post = Post(title: metadata["title"] ?? "",
                        description: metadata["description"] ?? "",
                        content: markdown.html,
                        createdAt: getDate(dateString: metadata["date"], fileDate: file.creationDate),
                        updatedAt: getDate(dateString: metadata["date"], fileDate: file.modificationDate))
        let titleHTML = Node.p(
            .class("blog-title"),
            .text(post.title)
        ).render()
        let dateHTML = Node.p(
            .class("blog-date"),
            .text("发布于 " + dateFormatter.string(from: post.createdAt))
        ).render()
        let postHTML = Node.div(
            .raw(titleHTML),
            .raw(dateHTML),
            .div(
                .class("blog-content"),
                .raw(post.content)
            )
        ).render()
        let html = try buildHTML(postHTML, styleSheet: styleSheet, scripts: scripts)
        let fileName = String(file.name.split(separator: ".").first ?? "undefined") + ".html"
        try exportHTMLFile(html, fileName: fileName, dir: PROJECT_OUTPUT_DIR)
    }
    
    public func exportHTMLFile(_ html: String, fileName: String, dir: String, rebuild: Bool = false) throws {
        let outputFolder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR)
        if (!outputFolder.containsSubfolder(named: dir)) {
            try outputFolder.createSubfolder(named: dir)
        }
        let folder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR + "/" + dir)
        if (!folder.containsFile(at: fileName)) {
            let outputFile = try folder.createFile(named: fileName)
            try outputFile.write(html)
        } else {
            let file = try folder.file(named: fileName)
            if (try rebuild || SHA256(string: file.readAsString()) != SHA256(string: html)) {
                try file.write(html)
            }
            try file.write(html)
        }
    }
    
    public func buildHTML(_ content: String, styleSheet: [String]? = nil, scripts: [String: String]? = nil) throws -> String {
        let html = HTML(
            .head(
                .title("Welcome to Ninjiacoder's Home!"),
                .stylesheet("style.css"),
                .unwrap(scripts, { (scriptList) -> Node<HTML.HeadContext> in
                    .forEach(scriptList.keys) {
                        .if($0 == "src", .script(.src(scriptList[$0]!)), else: .script(.raw(scriptList[$0]!)))
                    }
                }),
                .unwrap(styleSheet) {
                    .forEach($0) {
                        .stylesheet($0)
                    }
                },
                .meta(.charset(.utf8))
            ),
            .body(
                .div(
                    .class("wrapper"),
                    .raw(try buildHeaderHTML()),
                    .raw(try buildContentHTML(content)),
                    .raw(try buildFooterHTML())
                )
            )
        ).render()
        return html
    }

    public func buildHeaderHTML() throws -> String {
        let html = Node.h1(
            .class("header"),
            .a(.class("author"), .href("/"), .text("Ninjiacoder")),
            .p(.text("Swift lover, Fullstack Developer"))
        ).render()
        return html
    }

    public func buildFooterHTML() throws -> String {
        let html = Node.div(
            .class("footer"),
            .p(.text("Copyright © Ziyuan Zhao from Today Boring 2020")),
            .p(.text("本网站由 hexo.swift 强力驱动")),
            .a(.text("苏ICP备17050796号"), .href("http://www.beian.miit.gov.cn"))
        ).render()
        return html
    }

    public func buildContentHTML(_ content: String) throws -> String {
        let html = Node.div(
            .class("content"),
            .raw(content)
        ).render()
        return html
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
}
