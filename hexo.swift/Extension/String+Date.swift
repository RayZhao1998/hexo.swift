//
//  String+Date.swift
//  hexo.swift
//
//  Created by Ziyuan Zhao on 2020/3/12.
//  Copyright © 2020 Ziyuan Zhao. All rights reserved.
//

import Foundation

extension String {
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: DATE_FORMATTER_LOCALE_IDENTIFIER)
        dateFormatter.dateFormat = DATE_FORMATTER_DATEFORMAT
        return dateFormatter.date(from: self) ?? Date()
    }
}
