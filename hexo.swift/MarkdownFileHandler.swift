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
    
    public func generate() throws {
        try buildIndexHTML()
        try buildBlogsIndexHTML()
        let posts = try PostGenerator.shared.transformFilesToPosts(Folder(path: PROJECT_PATH + PROJECT_POST_DIR).files)
        for post in posts {
            try generateHTML(post, styleSheet: ["../../style.css", "../../blog.css", "../../monokai-sublime.css"], scripts: ["src": ["../../highlight.pack.js"], "text": ["hljs.initHighlightingOnLoad();"]])
        }
        let pages = try PageGenerator.shared.transformFilesToPages(Folder(path: PROJECT_PATH + PROJECT_PAGE_DIR).files)
        for page in pages {
            try generateHTML(page, styleSheet: ["../style.css", "../blog.css", "../monokai-sublime.css"], scripts: ["scr": ["../highlight.pack.js"], "text": ["hljs.initHighlightingOnLoad();"]])
        }
    }
    
    func generateHTML(_ post: Post, styleSheet: [String]? = nil, scripts: [String: [String]]? = nil) throws {
        let titleHTML = Node.p(
            .class("blog-title"),
            .text(post.title)
        ).render()
        let tagsHTML = Node.div(
            .class("blog-tags"),
            .unwrap(post.tags) {
                .forEach($0) {
                    .p(.text($0))
                }
            }
        ).render()
        let dateHTML = Node.p(
            .class("blog-date"),
            .text("发布于 " + dateFormatter.string(from: post.createdAt))
        ).render()
        let postHTML = Node.div(
            .raw(titleHTML),
            .div(
                .style("display: flex"),
                .raw(tagsHTML),
                .raw(dateHTML)
            ),
            .div(
                .class("blog-content"),
                .raw(post.content)
            )
        ).render()
        let html = try buildHTML(postHTML, styleSheet: styleSheet, scripts: scripts)
        let fileName = post.title
        try exportHTMLFile(html, fileName: "index.html", dir: "blogs/" + fileName)
    }
    
    func generateHTML(_ page: Page, styleSheet: [String]? = nil, scripts: [String: [String]]? = nil) throws {
        let titleHTML = Node.p(
            .class("blog-title"),
            .text(page.title)
        ).render()
        let postHTML = Node.div(
            .raw(titleHTML),
            .div(
                .class("blog-content"),
                .raw(page.content)
            )
        ).render()
        let html = try buildHTML(postHTML, styleSheet: styleSheet, scripts: scripts)
        let fileName = page.title
        try exportHTMLFile(html, fileName: "index.html", dir: fileName)
    }
    
    public func exportHTMLFile(_ html: String, fileName: String, dir: String, rebuild: Bool = false) throws {
        let outputFolder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR)
        var safeFolder: Folder
        if (!outputFolder.containsSubfolder(named: dir)) {
            safeFolder = try outputFolder.createSubfolder(named: dir)
        } else {
            safeFolder = try outputFolder.subfolder(named: dir)
        }
        if (!safeFolder.containsFile(at: fileName)) {
            let outputFile = try safeFolder.createFile(named: fileName)
            do {
                try outputFile.write(html)
                print("Create \(fileName)")
            } catch {
                print(error)
            }
        } else {
            let file = try safeFolder.file(named: fileName)
            if (try rebuild || SHA256(string: file.readAsString()) != SHA256(string: html)) {
                do {
                    try file.write(html)
                    print("Update \(fileName)")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    public func buildHTML(_ content: String, styleSheet: [String]? = nil, scripts: [String: [String]]? = nil) throws -> String {
        let html = HTML(
            .head(
                .title("Welcome to Ninjiacoder's Home!"),
                .stylesheet("style.css"),
                .unwrap(scripts, { (scriptList) -> Node<HTML.HeadContext> in
                    .unwrap(scriptList["src"], { (srcList) -> Node<HTML.HeadContext> in
                        .forEach(srcList) {
                            .script(.src($0))
                        }
                    })
                }),
                .unwrap(scripts, { (scriptList) -> Node<HTML.HeadContext> in
                    .unwrap(scriptList["text"], { (textList) -> Node<HTML.HeadContext> in
                        .forEach(textList) {
                            .script(.text($0))
                        }
                    })
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
    
    func buildIndexHTML() throws {
        let content = Node.div(
            .class("introduction"),
            .h1(.text("Hello.")),
            .p(
                .text("My name is Ziyuan Zhao"),
                .style("font-weight:500; font-size:2.2em")
            ),
            .p(
                .text("I am a fullstack developer and a Swift lover. Now I'm an intership @meituan. Here is my "),
                .a(.text("@blog"), .href("/blogs"))
            ),
            .p(
                .text("I'm also an independent developer. I have two iOS app, "),
                .a(.text("tomatic"), .href("https://apps.apple.com/cn/app/id1472871822")),
                .text(" & "),
                .a(.text("TodayMatters"), .href("https://itunes.apple.com/cn/app//id1448675694?mt=8"))
            ),
            .p(
                .text("I'm one of the creators of NUAA Open Source. As a core developer, we have developed a cloud U-disk called "),
                .a(.text("SafeU"), .href("https://safeu.a2os.club"))
            ),
            .p(
                .text("Besides, I'm a fan of Marval & DC. I like playing games on PS4")
            ),
            .p(
                .text("You can find me "),
                .raw(try buildContactHTML())
            )
        ).render()
        let html = try MarkdownFileHandler.shared.buildHTML(content)
        let outputFolder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR)
        let fileName = "index.html"
        if (!outputFolder.containsFile(named: fileName)) {
            let output = try outputFolder.createFile(named: fileName)
            try output.write(html)
        }
    }
    
    func buildBlogsIndexHTML() throws {
        let posts = try PostGenerator.shared.transformFilesToPosts(Folder(path: PROJECT_PATH + PROJECT_POST_DIR).files)
        let html = posts.map {
            Node.div(
                .class("article"),
                .a(.text($0.title), .href("/blogs/" + $0.title)),
                .div(
                    .style("display: flex; align-items: center"),
                    .unwrap($0.tags) {
                        .div(
                            .class("article-tags"),
                            .forEach($0) {
                                .p(.text($0))
                            }
                        )
                    },
                    .p(
                        .class("article-date"),
                        .text("发布于 " + dateFormatter.string(from: $0.createdAt))
                    )
                ),
                .if($0.description != nil, .p(
                    .class("article-description"),
                    .text($0.description!))
                )
            ).render()
        }.reduce("") { $0 + $1 }
        try MarkdownFileHandler.shared.exportHTMLFile(MarkdownFileHandler.shared
            .buildHTML(html, styleSheet: ["../style.css"]), fileName: "index.html", dir: "blogs")
    }

    private func buildHeaderHTML() throws -> String {
        let html = Node.h1(
            .class("header"),
            .div(
                .class("author-div"),
                .a(.class("author"), .href("/"), .text("Ninjiacoder")),
                .p(.text("Swift lover, Fullstack Developer"))
            ),
            .div(
                .class("navbar"),
                .ul(
                    .li(.a(.text("博客"), .href("/blogs"))),
                    .li(.a(.text("关于"), .href("/about")))
                )
            )
        ).render()
        return html
    }

    private func buildFooterHTML() throws -> String {
        let html = Node.div(
            .class("footer"),
            .p(.text("Copyright © Ziyuan Zhao from Today Boring 2020")),
            .p(.text("本网站由 hexo.swift 强力驱动")),
            .a(.text("苏ICP备17050796号"), .href("http://www.beian.miit.gov.cn"))
        ).render()
        return html
    }

    private func buildContentHTML(_ content: String) throws -> String {
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
    
    private func buildContactHTML() throws -> String {
        let dict = [
            "@Github": "https://github.com/RayZhao1998",
            "@Twitter": "https://twitter.com/RayZhao98",
            "@Telegram": "https://t.me/ninjahome",
            "@Weibo": "https://weibo.com/u/6056735717",
            "@Zhihu": "http://www.zhihu.com/people/5kyn3t"
        ]
        var html = ""
        var count = 0
        for (platform, website) in dict {
            html += Node.a(.href(website), .text(platform)).render()
            if (dict.count != count + 1) {
                html += ", "
            }
            count += 1
        }
        return html
    }
}
