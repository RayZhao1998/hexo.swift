//
//  Post.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files

struct Post {
    var title: String
    var description: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String = "",
         description: String? = nil,
         content: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.title = title
        self.description = description
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct PostGenerator {
    static let shared = PostGenerator()
    
    func transformFilesToPosts(_ files: Folder.ChildSequence<File>) throws -> [Post] {
        var posts = [Post]()
    
        for file in files {
            let fileString = try file.readAsString()
            let markdown = markdownParser.parse(fileString)
            let metadata = markdown.metadata
            let post = Post(title: metadata["title"] ?? "",
                            description: metadata["description"] ?? "",
                            content: markdown.html,
                            createdAt: metadata["date"] != nil ? metadata["date"]!.getDate(date: file.creationDate) : Date(),
                            updatedAt: metadata["date"] != nil ? metadata["date"]!.getDate(date: file.modificationDate) : Date())
            posts.append(post)
        }
        return posts
    }
    
    func generatePosts() {
        do {
            for file in try Folder(path: PROJECT_PATH + "Posts").files {
                try MarkdownFileHandler.shared.generateHTML(file, styleSheet: ["blog.css", "monokai-sublime.css"], scripts: ["src": ["highlight.pack.js"], "text": ["hljs.initHighlightingOnLoad();"]])
            }
            print("构建成功！")
        } catch {
            print(error)
        }
    }
}
