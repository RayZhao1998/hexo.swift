//
//  Index.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/9.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation
import Files
import Plot

func buildIndexHTML() throws {
    let content = Node.div(
        .class("introduction"),
        .h1(.text("Hello.")),
        .p(.text("My name is Ziyuan Zhao"), .style("font-weight:500; font-size:2.2em")),
        .p(.text("I am a fullstack developer and a Swift lover. Now I'm an intership @meituan. Here is my blog")),
        .p(.text("I'm also an independent developer. I have two iOS app, ")),
        .p(.text("I'm one of the creators of NUAA Open Source. As a core developer, we have developed a cloud U-disk called SafeU")),
        .p(.text("Besides, I'm a fan of Marval & DC. I like playing games on PS4")),
        .p(.text("You can find me "),.a(.text("@Github"), .href("https://github.com/RayZhao1998")))
    ).render()
    let html = try buildHTML(content)
    let outputFolder = try Folder(path: PROJECT_PATH + PROJECT_OUTPUT_DIR)
    let fileName = "index.html"
    if (!outputFolder.containsFile(named: fileName)) {
        let output = try outputFolder.createFile(named: fileName)
        try output.write(html)
    }
}

public func buildHTML(_ content: String) throws -> String {
    let html = HTML(
        .head(
            .title("Welcome to Ninjiacoder's Home!"),
            .stylesheet("style.css")
        ),
        .body(
            .div(
                .class("wrapper"),
                .raw(try buildHeaderHTML()),
                .raw(try buildContentHTML(content)),
                .raw(try buildFooterHTML())
            )
        )
    ).render()
    return html
}

public func buildHeaderHTML() throws -> String {
    let html = Node.h1(
        .class("header"),
        .a(.class("author"), .href("/"), .text("Ninjiacoder")),
        .p(.text("Swift lover, Fullstack Developer"))
    ).render()
    return html
}

public func buildFooterHTML() throws -> String {
    let html = Node.div(
        .class("footer"),
        .p(.text("本网站由 hexo.swift 强力驱动")),
        .a(.text("苏ICP备17050796号"), .href("http://www.beian.miit.gov.cn"))
    ).render()
    return html
}

public func buildContentHTML(_ content: String) throws -> String {
    let html = Node.div(
        .class("content"),
        .raw(content)
    ).render()
    return html
}
