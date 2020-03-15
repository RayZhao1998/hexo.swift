//
//  WebsiteRunner.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/12.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files
import ShellOut

struct WebsiteRunner {
    let folder: Folder
    
    func run() throws {
        let serverQueue = DispatchQueue(label: "Hexo.swift.webserver")
        let serverProcess = Process()
        
        let outputFolder = try getOutputFolder()
        
        print("""
           🌍 Starting web server at http://localhost:8888

           Press ENTER to stop the server and exit
        """)
        
        serverQueue.async {
            do {
                _ = try shellOut(
                    to: "python3 -m http.server 8080",
                    at: outputFolder.path,
                    process: serverProcess
                )
            } catch let error as ShellOutError {
                print(error)
            } catch {
                print(error)
            }
            
            serverProcess.terminate()
            exit(1)
        }
        
        _ = readLine()
        serverProcess.terminate()
    }
}

private extension WebsiteRunner {
    func getOutputFolder() throws -> Folder {
        do { return try folder.subfolder(named: "Output") }
        catch { throw CILError.notFoundOutputFolder }
    }
}

enum CILError: Error {
    case notFoundOutputFolder
}

extension CILError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notFoundOutputFolder:
            return "Not found output folder!"
        }
    }
}
