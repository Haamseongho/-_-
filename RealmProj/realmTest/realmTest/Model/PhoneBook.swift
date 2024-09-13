//
//  PhoneBook.swift
//  realmTest
//
//  Created by haams on 9/13/24.
//

import Foundation
import RealmSwift

class PhoneBook: Object {
    @Persisted(primaryKey: true) var phoneNumber:String?
    @Persisted var name: String?
}
