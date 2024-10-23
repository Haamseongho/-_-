//
//  RequestModel.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit
import RealmSwift

class RequestModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: String
    @Persisted var title: String
    @Persisted var url: String
}
//
//struct RequestModel {
//    let type: String
//    let title: String
//    let optionImage: UIImageView
//}
//
//struct ApiModel {
//    let type: String
//    let title: String
//    let url: String? = ""
//}
