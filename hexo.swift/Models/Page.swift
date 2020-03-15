//
//  Page.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Cocoa
import Files
import Ink
import Plot

struct Page {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct PageGenerator {
    static let shared = PageGenerator()
    let markdownParser = MarkdownParser()
    
    func transformFilesToPages(_ files: Folder.ChildSequence<File>) throws -> [Page] {
        var pages = [Page]()
    
        for file in files {
            let fileString = try file.readAsString()
            let markdown = markdownParser.parse(fileString)
            let metadata = markdown.metadata
            let page = Page(title: metadata["title"] ?? "",
                            content: markdown.html,
                            createdAt: metadata["date"] != nil ? metadata["date"]!.getDate(date: file.creationDate) : Date(),
                            updatedAt: metadata["date"] != nil ? metadata["date"]!.getDate(date: file.modificationDate) : Date())
            pages.append(page)
        }
        return pages.sorted { $0.createdAt > $1.createdAt }
    }
}
