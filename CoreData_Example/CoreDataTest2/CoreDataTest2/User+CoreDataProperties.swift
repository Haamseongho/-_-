//
//  User+CoreDataProperties.swift
//  CoreDataTest2
//
//  Created by haams on 9/4/24.
//
//

import Foundation
import CoreData


extension AppUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "AppUser")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension AppUser : Identifiable {

}
