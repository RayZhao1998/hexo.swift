//
//  Tag.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/4/21.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import SQLite

struct Tag {
    var tagId: Int64?
    var name: String?
}

class TagHelper {
    static let TABLE_NAME = "Tags"
    
    static let table = Table(TABLE_NAME)
    
    static let tagId = Expression<Int64>("tag_id")
    
    static let name = Expression<String>("name")
    
    static func createTable() throws {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        do {
            let _ = try db.run(table.create(ifNotExists: true) { t in
                t.column(tagId, primaryKey: true)
                t.column(name)
            })
        } catch {
            throw error
        }
    }
    
    static func insert(_ item: Tag) throws -> Int64 {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        if (item.name != nil) {
            let insert = table.insert(name <- item.name!)
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
        let query = table.filter(tagId == id)
        let items = try db.prepare(query)
        for item in items {
            return Post(postId: item[tagId], title: item[name])
        }
        return nil
    }
    
    static func findAll() throws -> [Post] {
        guard let db = DBUtils.shared.db else { throw DBError.DB_CONNECT_ERROR }
        var retArray = [Post]()
        let items = try db.prepare(table)
        for item in items {
            retArray.append(Post(postId: item[tagId], title: item[name]))
        }
        return retArray
    }
}
