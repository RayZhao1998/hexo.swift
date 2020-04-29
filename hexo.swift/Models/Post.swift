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
import SQLite

struct Post {
    var postId: Int64?
    var title: String?
    var description: String?
    var content: String?
    var tags: [String]?
    var createdAt: Date?
    var updatedAt: Date?
}

class PostHelper {
    static let TABLE_NAME = "Posts"
    
    static let table = Table(TABLE_NAME)
    
    static let postId = Expression<Int64>("post_id")
    
    static let title = Expression<String>("title")
    
    typealias T = Post
    
    static func createTable() throws {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        do {
            let _ = try db.run(table.create(ifNotExists: true) { t in
                t.column(postId, primaryKey: true)
                t.column(title)
            })
        } catch {
            throw error
        }
    }
    
    static func insert(_ item: Post) throws -> Int64 {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        if (item.title != nil) {
            let insert = table.insert(title <- item.title!)
            do {
                let rowId = try db.run(insert)
                guard rowId > 0 else {
                    throw DBError.INSERT_ERROR
                }
                return rowId
            } catch {
                throw DBError.INSERT_ERROR
            }
        }
        throw DBError.NIL_DATA
    }
    
    static func find(_ id: Int64) throws -> Post? {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        let query = table.filter(postId == id)
        let items = try db.prepare(query)
        for item in items {
            return Post(postId: item[postId], title: item[title])
        }
        return nil
    }
    
    static func findAll() throws -> [Post] {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        var retArray = [Post]()
        let items = try db.prepare(table)
        for item in items {
            retArray.append(Post(postId: item[postId], title: item[title]))
        }
        return retArray
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
        return posts.sorted { $0.createdAt! > $1.createdAt! }
    }
}
