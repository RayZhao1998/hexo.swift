//
//  Post.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation

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
