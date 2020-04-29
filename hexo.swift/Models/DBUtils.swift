//
//  DBUtils.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/4/26.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import SQLite

enum DBError: Error {
    case DB_CONNECT_ERROR
    case INSERT_ERROR
    case NIL_DATA
}

struct DBUtils {
    static let shared = DBUtils()
    
    var db: Connection? {
        get {
            do {
                return try Connection("/Users/ziyuanzhao/Documents/products/hexo.swift/hexo.swift/Output/hexo.sqlite3")
            } catch {
                print(error)
            }
            return nil
        }
    }
}
