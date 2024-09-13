//
//  PhoneBook.swift
//  RealmProj2
//
//  Created by haams on 9/12/24.
//

import Foundation
import RealmSwift

class PhoneBook: Object {
    @Persisted(primaryKey: true) var _id: Int
    @Persisted var number: String?
    // @objc dynamic var name: String?
    @Persisted var name: String? 

}
