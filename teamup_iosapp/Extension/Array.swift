//
//  Array.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/22.
//

import Foundation

extension Array where Element: Hashable {
    /// 去重后的数组
    var unique: [Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}
