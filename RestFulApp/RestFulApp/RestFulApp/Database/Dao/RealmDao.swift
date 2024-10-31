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
                realm.add(requestData) // RequestModel에 추가
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
    // Request 아이디 값으로 반환
    func getRequestById(id: ObjectId) -> RequestModel?{
        return realm.object(ofType: RequestModel.self, forPrimaryKey: id)
    }
    // renameRequest
    func renameRequest(id: ObjectId, title: String){
        if let requestItem = getRequestById(id: id) {
            try! realm.write {
                requestItem.title = title
            }
        }
    }
    // remove Request
    func removeRequest(id: ObjectId){
        if let requestItem = getRequestById(id: id) {
            try! realm.write {
                realm.delete(requestItem)
            }
        }
    }
    
    // 바로 apiController로 이동해서 REST api 조회한 경우 여기로 히스토리 관리
    func insertHistoryBySend(history: HistoryModel){
        try! realm.write {
            realm.add(history)
        }
    }
    // Request를 통해 조회한 경우
    // 히스토리 화면에서 SAVE REQUEST로 진행할 경우, 위에 apiController를 통해 바로 들어온 경우 히스토리DB에만 있을거니까
    // 먼저 Collection 테이블에서 이름으로 먼저 컬렉션 찾고 넣어주기 + Request에도 추가해주기
    // 없다면 새로 생성하고 넣어주기
    func insertOrUpdateHistory(byId: ObjectId, history: HistoryModel) {
        if let collection = getCollection(byId: byId){
            // 기존재하면 교체
            // 이런 경우에는 컬렉션에 이미 히스토리가 있고 한 번 조회한 경험이 있는 경우임
            if let prevHistory = collection.historyList.first(where: {$0.id == history.id}) {
                prevHistory.type = history.type
                prevHistory.title = history.title
                prevHistory.url = history.url
                prevHistory.date = history.date
                prevHistory.params = history.params
                prevHistory.headers = history.headers
                prevHistory.body = history.body
            } 
            // 그게 아니면 추가 (히스토리 DB에도 추가하고 Collection에도 히스토리 추가하기)
            // 이런 경우에는 컬렉션에 히스토리가 없는 상태이며, Request를 통해 api탭으로 이동한 상태입니다.
            // 조회를 할 경우 Collection ID를 받아갈 것이며, 이로 히스토리에 넣고(이건 앞서 Collection ID와 별개), 히스토리 DB에도 넣는다.
            else {
                collection.historyList.append(history)
                try! realm.write {
                    realm.add(history)
                }
            }
        }
    }
    // 히스토리에서 리퀘스트 추가하는거
    /*
     1) 리퀘스트로 입력할 이름넣고 세이브 누르면 우선 그 이름이 컬렉션에 있는지 확인한다.
     2) 컬렉션에 해당 이름이 없으면 추가하고 Request도 추가한다. (requestList에도 append하기)
     3) 있으면 해당 컬렉션의 requestList에만 append하기! RequestModel에는 이미 있을 것이라 여김
     */
    // RequestModel, CollectionModel.requestList 에 추가할 것
    func fetchCollectionByName(name: String) -> CollectionModel? {
        return realm.objects(CollectionModel.self).filter("name == %@", name).first
    }
    // 현재 히스토리와 리퀘스트 모두해서 컬렉션에 넣어주기
    // 만약 컬렉션이 없다면 컬렉션까지 새로 만들어서 다 넣어주기
    func insertHistoryToCollection(history: HistoryModel, request: RequestModel, name: String){
        if let collection = fetchCollectionByName(name: name) {
            collection.historyList.append(history)
            collection.requestList.append(request)
        }
        else {
            // collection 추가하기
            let collection2 = CollectionModel()
            collection2.title = name
            collection2.requestCount = 0
            collection2.requestList.append(request)
            collection2.historyList.append(history)
            self.insertCollection(collection2)
            
        }
    }
    
    /*
     History 가져오기
     -> 보여주는건 다 가져오기 단, 날짜를 기준으로
     */
    func getHistoryByOrdersInDate() -> Results<HistoryModel> {
        let sortedHistoryItem = realm.objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: false) // 내림차순 구현
        return sortedHistoryItem
    }
    
    // remove History
    func dropHistoryTable() {
        try! realm.write {
            let historyTB = realm.objects(HistoryModel.self)
            realm.delete(historyTB)
        }
    }
}
