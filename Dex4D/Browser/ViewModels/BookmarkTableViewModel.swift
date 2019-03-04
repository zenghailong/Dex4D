//
//  BookmarkTableViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/7.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import RealmSwift

class BookmarkTableViewModel {
    
    let type: BookmarkType
    
    let bookmarkStorage = BookmarkStorage.shared
    
    init (type: BookmarkType) {
        self.type = type
    }
    
    var dataSource: Results<Bookmark> {
        switch type {
        case .bookmark:
            return bookmarkStorage.bookmarks
        case .history:
            return bookmarkStorage.histories
        }
    }
    
    func deleteAll() {
        switch type {
        case .bookmark:
            bookmarkStorage.deleteAllBookmarks()
        case .history:
            bookmarkStorage.deleteAllHistories()
        }
    }
    
}
