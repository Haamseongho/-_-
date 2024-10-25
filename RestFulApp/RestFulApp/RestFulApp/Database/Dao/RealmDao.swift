//
//  RealmDao.swift
//  RestFulApp
//
//  Created by haams on 10/23/24.
//

import Foundation
import Realm
import RealmSwift

class RealmDao {
    private let realm = try! Realm()
    // Collection - insert
    func insertCollection(_ collection: CollectionModel){
        try! realm.write {
            realm.add(collection)
        }
    }
    
    // getAllCollection
    func getAllCollection() -> Results<CollectionModel>{
        let getCollectionModel = realm.objects(CollectionModel.self)
        return getCollectionModel
    }
    
    // Collection - delete
    func removeCollection(_ collection: CollectionModel){
        try! realm.write {
            realm.delete(collection)
        }
    }
    
    // getCollection
    func getCollection(byId id: ObjectId) -> CollectionModel? {
        return realm.object(ofType: CollectionModel.self, forPrimaryKey: id)
    }
    
    // Collection - rename
    func renameCollection(id: ObjectId, newTitle: String){
        if let collection = getCollection(byId: id) {
            try! realm.write {
                collection.title = newTitle
            }
        }
    }
    // request --> collection
    func insertReqToCollection(id: ObjectId, requestData: RequestModel){
        if let collection = getCollection(byId: id) {
            try! realm.write {
                collection.requestList.append(requestData)
            }
        }
    }
    // insertRequest
    func insertRequest(requestData: RequestModel){
        try! realm.write {
            realm.add(requestData)
        }
    }
    
    // update requestCount
    func updateRequestCount(id: ObjectId) {
        if let collection = getCollection(byId: id){
            try! realm.write {
                collection.requestCount = collection.requestList.count
            }
        }
    }
}
