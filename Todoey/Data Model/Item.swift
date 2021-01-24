//
//  Item.swift
//  Todoey
//
//  Created by Lukas Adomavicius on 1/23/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Double = Date().timeIntervalSince1970
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
