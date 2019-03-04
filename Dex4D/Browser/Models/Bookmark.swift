// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class Bookmark: Object {
    
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var create: Date = Date()

    convenience init(
        type: BookmarkType,
        url: String = "",
        title: String? = nil,
        icon: String? = nil
    ) {
        self.init()
        self.url = url
        self.type = type == .bookmark ? "bookmark" : "history"
        self.title = title == nil || title == "" ? "Unnamed title".localized : title!
        self.icon = icon == nil ? "" : icon!
        self.id = "\(url)|\(create.timeIntervalSince1970)"
    }

    var linkURL: URL? {
        return URL(string: url)
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
}
