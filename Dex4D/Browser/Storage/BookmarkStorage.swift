// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class BookmarkStorage {
    
    public static let shared = BookmarkStorage()
    
    let realm: Realm = {
        let sharedMigration = BookmarkMigrationInitializer()
        sharedMigration.perform()
        let realm = try! Realm(configuration: sharedMigration.config)
        return realm
    }()
    
    var bookmarks: Results<Bookmark> {
        return realm.objects(Bookmark.self).sorted(byKeyPath: "create", ascending: false).filter("type = %@", "bookmark")
    }
    
    var histories: Results<Bookmark> {
        return realm.objects(Bookmark.self).sorted(byKeyPath: "create", ascending: false).filter("type = %@", "history")
    }
    
    func hasBookmark(url: String) -> Bool {
        let result = realm.objects(Bookmark.self).sorted(byKeyPath: "create", ascending: false).filter("type = %@ and url = %@", "bookmark", url)
        return !result.isEmpty
    }
    
    private func checkBookmark(bookmark: Bookmark) {
        let result = realm.objects(Bookmark.self).sorted(byKeyPath: "create", ascending: false).filter("type = %@ and url = %@", bookmark.type, bookmark.url)
        if !result.isEmpty {
            realm.beginWrite()
            realm.delete(result)
            try! realm.commitWrite()
        }
    }
    
    func add(bookmarks: [Bookmark]) {
        for item in bookmarks {
            checkBookmark(bookmark: item)
        }
        realm.beginWrite()
        realm.add(bookmarks, update: true)
        try! realm.commitWrite()
        while histories.count > 100 {
            delete(bookmarks: [histories.last!])
        }
    }
    
    func delete(bookmarks: [Bookmark]) {
        realm.beginWrite()
        realm.delete(bookmarks)
        try! realm.commitWrite()
    }
    
    func deleteBookmark(url: String) {
        for item in bookmarks {
            if item.url == url {
                realm.beginWrite()
                realm.delete([item])
                try! realm.commitWrite()
            }
        }
    }
    
    func deleteAllBookmarks() {
        realm.beginWrite()
        realm.delete(bookmarks)
        try! realm.commitWrite()
    }
    
    func deleteAllHistories() {
        realm.beginWrite()
        realm.delete(histories)
        try! realm.commitWrite()
    }
    
}
