//
//  Post.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files
import Ink

struct Post {
    var title: String
    var description: String?
    var tags: [String]?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String = "",
         description: String? = nil,
         content: String = "",
         tags: [String]? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.title = title
        self.description = description
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct PostGenerator {
    static let shared = PostGenerator()
    let markdownParser = MarkdownParser()
    
    func transformFilesToPosts(_ files: Folder.ChildSequence<File>) throws -> [Post] {
        var posts = [Post]()
    
        for file in files {
            let fileString = try file.readAsString()
            let markdown = markdownParser.parse(fileString)
            let metadata = markdown.metadata
            let post = Post(title: metadata["title"] ?? "",
                            description: metadata["description"] ?? "",
                            content: markdown.html,
                            tags: metadata["tags"] != nil ? metadata["tags"]!.split(separator: ",").map(String.init) : nil,
                            createdAt: metadata["date"] != nil ? metadata["date"]!.getDate() : Date(),
                            updatedAt: file.modificationDate ?? Date())
            posts.append(post)
        }
        return posts.sorted { $0.createdAt > $1.createdAt }
    }
}
