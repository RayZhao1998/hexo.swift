//
//  main.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/8.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files

try buildIndexHTML()
for file in try Folder(path: PROJECT_PATH + "Posts").files {
    try MarkdownFileHandler.shared.generateHTML(file, styleSheet: ["blog.css", "monokai-sublime.css"], scripts: ["src": "highlight.pack.js", "text": "hljs.initHighlightingOnLoad();"])
}


