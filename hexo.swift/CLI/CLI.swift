//
//  CLI.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/11.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files

public struct CLI {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run(in folder: Folder) throws  {
        guard arguments.count > 1 else {
            return helpText()
        }
        
        switch arguments[1] {
        case "new":
            if (arguments.count < 3) {
                print("No new type!")
                return
            } else if (arguments.count < 4) {
                if (arguments[2] != "post" || arguments[2] != "page") {
                    print("Must select a type: post or page")
                    return
                } else if (arguments[2] == "post") {
                    try MarkdownFileManager.shared.createNewPost(arguments[3])
                } else if (arguments[2] == "page") {
                    try MarkdownFileManager.shared.createNewPage(arguments[3])
                }
            }
            
        case "build":
            try MarkdownFileHandler.shared.generate()
        case "run":
            let runner = WebsiteRunner(folder: folder)
            try runner.run()
        default:
            return helpText()
        }
    }
}

extension CLI {
    func helpText() {
        print("""
        This is a help!
        """)
    }
}
