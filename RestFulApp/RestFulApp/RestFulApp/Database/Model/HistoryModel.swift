//
//  HistoryModel.swift
//  RestFulApp
//
//  Created by haams on 10/22/24.
//

import Foundation
import UIKit
import RealmSwift

class HistoryModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: String
    @Persisted var title: String
    @Persisted var url: String
    @Persisted var date: Date
    @Persisted var params = List<ParamsObject>()
    @Persisted var headers = List<ParamsObject>()
    @Persisted var body: String
    @Persisted var requestList = List<RequestModel>()
}

class ParamsObject: Object {
    @Persisted var key: String
    @Persisted var value: String
}
