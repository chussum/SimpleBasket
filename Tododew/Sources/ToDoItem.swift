//
//  ToDoItem.swift
//  tododew
//
//  Created by  BCNX-A06 on 2016. 10. 25..
//  Copyright © 2016년 hyungdew. All rights reserved.
//

import RealmSwift

final class ToDoItem: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var price = ""
    dynamic var done = false
    dynamic var createAt = Date()
    dynamic var updateAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func nextId() -> Int{
        let realm = try! Realm()
        let maxId = realm.objects(ToDoItem.self).map{$0.id}.max() ?? 0
        return maxId + 1
    }
}
