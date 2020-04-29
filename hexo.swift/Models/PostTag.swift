//
//  PostTag.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/4/26.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import SQLite

typealias PostTag = (
    postId: Int64?,
    tagId: Int64?
)

class PostTagHelper {
    static let TABLE_NAME = "PostTag"
    
    static let table = Table(TABLE_NAME)
    
    static let postId = Expression<Int64>("post_id")
    
    static let tagId = Expression<Int64>("tag_id")
    
    static func createTable() throws {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        do {
            let _ = try db.run(table.create(ifNotExists: true) { t in
                t.column(postId)
                t.column(tagId)
            })
        } catch {
            throw error
        }
    }
    
    static func insert(item: PostTag) throws -> Int64 {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        if (item.postId != nil && item.tagId != nil) {
            let insert = table.insert(postId <- item.postId!, tagId <- item.tagId!)
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
    
    static func findByTag(id: Int64) throws -> [PostTag] {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        var result = [PostTag]()
        let query = table.filter(tagId == id)
        let items = try db.prepare(query)
        for item in items {
            result.append(PostTag(postId: item[postId], tagId: item[tagId]))
        }
        return result
    }
    
    static func findByPost(id: Int64) throws -> [PostTag] {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        var result = [PostTag]()
        let query = table.filter(postId == id)
        let items = try db.prepare(query)
        for item in items {
            result.append(PostTag(postId: item[postId], tagId: item[tagId]))
        }
        return result
    }
}
