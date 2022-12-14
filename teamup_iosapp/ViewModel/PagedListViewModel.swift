//
//  PagedListViewModel.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/10/18.
//

import UIKit

class PagedListViewModel: ObservableObject {
    var currentPage = 0
    @Published var hasNextPage = true
    @Published var loading = false
}
