//
//  MarkdownFileManager.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/14.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files

struct MarkdownFileManager {
    static let shared = MarkdownFileManager()
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.locale = Locale(identifier: DATE_FORMATTER_LOCALE_IDENTIFIER)
        dateFormatter.dateFormat = DATE_FORMATTER_DATEFORMAT
    }
    
    public func createNewPost(_ name: String) throws {
        let postFolder = try Folder(path: PROJECT_PATH + PROJECT_POST_DIR)
        if (postFolder.containsFile(named: name + ".md")) {
            print("The file has existed!")
        } else {
            let file = try postFolder.createFile(named: name + ".md")
            try file.write("""
            ---
            title: \(name)
            date: \(dateFormatter.string(from: Date()))
            ---
            """)
            print("Create success!")
        }
    }
    
    public func createNewPage(_ name: String) throws {
        let pageFolder = try Folder(path: PROJECT_PATH + PROJECT_PAGE_DIR)
        if (pageFolder.containsFile(named: name + ".md")) {
            print("The file has existed!")
        } else {
            let file = try pageFolder.createFile(named: name + ".md")
            try file.write("""
            ---
            title: \(name)
            date: \(dateFormatter.string(from: Date()))
            ---
            """)
            print("Create success!")
        }
    }
}
