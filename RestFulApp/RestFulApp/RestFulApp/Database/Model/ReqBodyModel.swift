//
//  ReqBodyModel.swift
//  RestFulApp
//
//  Created by haams on 11/19/24.
//

import Foundation
import UIKit
import RealmSwift
class ReqBodyModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var body: String
    @Persisted var type: String
    @Persisted var title: String
    @Persisted var url: String
}
