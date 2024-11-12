//
//  CollectionTabConroller.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit
import SwiftUI
import RxSwift
import RealmSwift
import ObjectiveC

private var objectIdKey: UInt8 = 0 // 키를 위한 고유한 변수
private var indexKey: UInt8 = 0 // 연관된 키
extension UITapGestureRecognizer {
    var objectId: ObjectId? {
        get {
            return objc_getAssociatedObject(self, &objectIdKey) as? ObjectId
        }
        set {
            objc_setAssociatedObject(self, &objectIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var index: Int? {
        get {
            return objc_getAssociatedObject(self, &indexKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &indexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class MyCollectionViewCell: UICollectionViewCell {
    static let identifier = "ParentCell"
    var subItems : [RequestModel] = []
    var isExpanded = false
    private var realmDao = RealmDao()
    
    
    var shouldHideCells: Bool = true // 셀 숨김 여부를 결정하는 변수
    // Child CollectionView 생성
    let childCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Child CollectionView 등록 및 설정
        childCollectionView.dataSource = self
        childCollectionView.delegate = self
        childCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ChildCell")
        
        contentView.addSubview(childCollectionView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            childCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            childCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            childCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            childCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // func refreshSubItem
    func refreshSubItems(_ items: Array<RequestModel>, shouldHide: Bool){
        
        print("shouldHide: \(shouldHide)")
        if shouldHide {
            self.childCollectionView.isHidden = true
          //  self.childCollectionView.reloadData()
        } else {
            self.childCollectionView.isHidden = false
            print("items ::::: \(items)")
            self.subItems = items
            self.childCollectionView.reloadData()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 확장 상태 초기화
        isExpanded = false
       // childCollectionView.isHidden = true // 숨김 상태로 초기화
      //  subItems = [] // 데이터 초기화
      //  childCollectionView.reloadData() // 서브 컬렉션 뷰 데이터 리로드
    }
    
    func configure(with items: [RequestModel], expanded: Bool) {
        self.subItems = items
        self.isExpanded = expanded
        childCollectionView.isHidden = !expanded
        childCollectionView.reloadData()
    }
}

extension MyCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("subItems Count : \(subItems.count)")
        return subItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildCell", for: indexPath)
        cell.backgroundColor = .white
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let type = UILabel()
        type.text = subItems[indexPath.item].type
        type.translatesAutoresizingMaskIntoConstraints = false
        
        let title = UILabel()
        title.text = subItems[indexPath.item].title
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .black
        type.textColor = .black
        let optionImage = UIImageView(image: UIImage(systemName: "ellipsis"))
        optionImage.translatesAutoresizingMaskIntoConstraints = false
        optionImage.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(childDataClicked(_:)))
        optionImage.addGestureRecognizer(tapGesture) // 이름변경, 삭제 기능 추가 > Request DB에서도 삭제하고 Collection에서도 리스트 삭제
        
        let objectId = subItems[indexPath.item].id
        tapGesture.objectId = objectId
        optionImage.tag = indexPath.item // delete 할 때 사용할 예정
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        cell.contentView.addSubview(type)
        cell.contentView.addSubview(title)
        cell.contentView.addSubview(optionImage)
        cell.contentView.addSubview(borderView)
        NSLayoutConstraint.activate([
            type.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 30),
            type.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 30),
            type.heightAnchor.constraint(equalToConstant: 20),
            title.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 30),
            title.leadingAnchor.constraint(equalTo: type.trailingAnchor, constant: 20),
            title.heightAnchor.constraint(equalToConstant: 20),
            optionImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 30),
            optionImage.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -30),
            borderView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            borderView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        
        cell.isHidden = shouldHideCells
        
        return cell
    }
    
    @objc func childDataClicked(_ sender: UITapGestureRecognizer){
        print("clicked!! \(sender.description)")
        
        guard let objectId = sender.objectId else {
            print("ObjectID not found")
            return
        }
        
        guard let optionImageTag = sender.view?.tag else {
            print("No TAG Item")
            return
        }
        
        print("optionImageTAG: \(optionImageTag)")
        print("objectId : \(objectId)")
        childDataModified(title: "REQUEST 변경", message: "", objectID: objectId, index: optionImageTag)
    }
    
    func childDataModified(title: String?, message: String?, objectID: ObjectId?, index: Int?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let renameLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        renameLabel2.translatesAutoresizingMaskIntoConstraints = false
        renameLabel2.isUserInteractionEnabled = true
        renameLabel2.text = "RENAME"
        let deleteLabel2 = UILabel(frame: CGRect(x: 35, y: 0, width: 250, height: 30))
        deleteLabel2.translatesAutoresizingMaskIntoConstraints = false
        deleteLabel2.isUserInteractionEnabled = true
        deleteLabel2.text = "DELETE"
        alertController.view.addSubview(renameLabel2)
        alertController.view.addSubview(deleteLabel2)
        
        let renameTapped2 = UITapGestureRecognizer(target: self, action: #selector(handleTap4(_ :)))
        let deleteTapped2 = UITapGestureRecognizer(target: self, action: #selector(handleTap5(_ :)))
        renameTapped2.objectId = objectID // Request Primary Key send
        deleteTapped2.objectId = objectID // Request Primary Key send
        deleteTapped2.index = index // 현재 인덱스를 같이 넘겨서 UI상에서 제거하기 위함
        renameLabel2.addGestureRecognizer(renameTapped2)
        deleteLabel2.addGestureRecognizer(deleteTapped2)
        
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        let heightConstraint = NSLayoutConstraint(item: alertController.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        
        alertController.view.addConstraint(heightConstraint)
        alertController.view.addSubview(renameLabel2)
        alertController.view.addSubview(borderView)
        alertController.view.addSubview(deleteLabel2)
        
        NSLayoutConstraint.activate([
            renameLabel2.heightAnchor.constraint(equalToConstant: 30),
            renameLabel2.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            renameLabel2.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 60),
            renameLabel2.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            
            borderView.heightAnchor.constraint(equalToConstant: 1),
            borderView.topAnchor.constraint(equalTo: renameLabel2.bottomAnchor, constant: 10),
            borderView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            borderView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            
            deleteLabel2.heightAnchor.constraint(equalToConstant: 30),
            deleteLabel2.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 20),
            deleteLabel2.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            deleteLabel2.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            
        ])
        
        
       
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel)
        alertController.addAction(cancelAction)
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    // textField 1개
    func showInputDialog(title: String?, message: String?, inputPlaceholder: String?, subTitle: String?, actionHandler: @escaping (String?) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = .default
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {_ in print("Cancel")})
        alertController.addAction(cancelAction)
        let action = UIAlertAction(title: subTitle, style: .default) { _ in
            let textField = alertController.textFields?.first
            actionHandler(textField?.text)
        }
        alertController.addAction(action)
        
        // 대화상자 화면에 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // Collection 이름 변경
    @objc func handleTap4(_ sender: UITapGestureRecognizer){
        print("rename clicked")
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        print("realm 위치: ", Realm.Configuration.defaultConfiguration.fileURL!)
        
        guard let objectId = sender.objectId else {
            print("ObjectID not found")
            return
        }
        
        // objectId를 기준으로 Request에 내용 변경
        showInputDialog(title: "Rename Collection", message: "변경할 이름 입력", inputPlaceholder: "rename collection", subTitle: "Confirm", actionHandler: { inputText in
            let id = objectId
            if let unwrappedInputText = inputText {
                print("변경 아이디 : \(id) 변경 이름: \(unwrappedInputText)")
                self.realmDao.renameRequestInCollection(rId: id, newTitle: unwrappedInputText)
            } else {
                print("inputText is nil")
            }
            
            self.childCollectionView.reloadData()
        })
    }
    
    // Collection 삭제
    @objc func handleTap5(_ sender: UITapGestureRecognizer){
        print("delete clicked")
        guard let objectId = sender.objectId else {
            print("ObjectID not found")
            return
        }
        // Request Table에서 지우고, Collection에서도 지우기
        self.realmDao.deleteRequest(rId:  objectId)
        self.realmDao.deleteRequesetFromCollection(rId: objectId)
        // 데이터 모델에서 해당 아이템 제거
        guard let index = sender.index else {
            print("no index")
            return
        }
        
        self.subItems.remove(at: index)
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        self.childCollectionView.reloadData()
        
        // NotificationCenter에 알림 게시
        NotificationCenter.default.post(name: Notification.Name("ChildDataUpdated"), object: nil)
    }
    
    func showWarningPopup() {
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        let alertController = UIAlertController(title: "경고", message: "필수정보를 입력해주세요", preferredStyle: .alert)
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 팝업 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // 레이아웃 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = subItems.count
        let baseHeight: CGFloat = 20 // Parent content 높이
        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if !shouldHideCells {
            let additionalHeight = CGFloat(requestItemsCount * 20) // 각 자식 아이템당 60의 높이
            print("높이: \(baseHeight + additionalHeight)")
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight + additionalHeight)
        } else {
            // flag가 false일 경우, 기본 높이만 반환
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight)
        }
        //     return CGSize(width: collectionView.bounds.width, height: 150) // 예시 사이즈
    }
    
    // 컬렉션 뷰 가장자리 여백 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 30, bottom: 10, right: 10) // 상하좌우 여백
    }
    
}

class CollectionTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var flag = false
    private var realmDao = RealmDao()
    
    private var items: [CollectionModel] = [] // ParentCell로 들어가는 아이템
    private var isExpandedArray: [Bool] = [] // 화살표 누름/닫힘 구분값
    private var imageArrowArray: [UIImageView] = []
    private var imageOptArray: [UIImageView] = []
    private var borderViewArray: [UIView] = []
    private let parentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        
        return collectionView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(parentCollectionView)
        parentCollectionView.dataSource = self
        parentCollectionView.delegate = self
        parentCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            parentCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            parentCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            parentCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            parentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        getDataFromDB()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateParentCollectionView), name: Notification.Name("ChildDataUpdated"), object: nil)
    }
    
    @objc func updateParentCollectionView() {
        print("deleteData and reloadData")
        parentCollectionView.reloadData()
        self.realmDao.modifyReqCountInCollection()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ChildDataUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("뷰가 나타나기 직전입니다.")
        //    getDataFromDB()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("뷰가 나타난 직후입니다.")
        //     getDataFromDB()
    }
  
    // db에서 먼저 가져와서 보여주기
    func getDataFromDB(){
        let collectionResults = self.realmDao.getAllCollection()
        
        items = Array(collectionResults)
        isExpandedArray = Array(repeating: false, count: items.count)
        imageArrowArray = Array(repeating: UIImageView(image: UIImage(systemName: "arrow.up")), count: items.count)
        imageOptArray = Array(repeating: UIImageView(image: UIImage(systemName: "ellipsis")), count: items.count)
        borderViewArray = Array(repeating: UIView(), count: items.count)
        parentCollectionView.reloadData()
        self.realmDao.modifyReqCountInCollection()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.backgroundColor = .white
        cell.tag = indexPath.row
        
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 20))
        label.text = items[indexPath.item].title
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 설정
        
        
        let requestCount = UILabel(frame: CGRect(x: 10, y: 30, width: 50, height: 20))
        requestCount.text = String(items[indexPath.item].requestCount)  + " request"
        requestCount.textColor = .black
        requestCount.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 설정
        requestCount.font = UIFont.systemFont(ofSize: 10)
        
        //  let openImage: UIImageView = UIImageView(image: UIImage(systemName: "arrow.up"))
        //  let optionImage: UIImageView = UIImageView(image: UIImage(systemName: "ellipsis"))
        
        let openImage = UIImageView()
        let optionImage = UIImageView(image: UIImage(systemName: "ellipsis"))
        openImage.translatesAutoresizingMaskIntoConstraints = false
        optionImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // 이미지가 셀에서 재사용될 때 올바르게 설정되도록 다시 지정
        if isExpandedArray[indexPath.item] {
            openImage.image = UIImage(systemName: "arrow.down")
        } else {
            openImage.image = UIImage(systemName: "arrow.up")
        }
        
        openImage.isUserInteractionEnabled = true
        optionImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOpenImage(_:)))
        openImage.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleOptionImage(_: )))
        tapGesture2.view?.tag = indexPath.item // 인덱스 넘기기
        
        optionImage.tag = indexPath.row
        
        optionImage.addGestureRecognizer(tapGesture2)
        
        
        // 경계선
        let borderView: UIView = UIView()
        
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        
        cell.contentView.addSubview(label)
        cell.contentView.addSubview(requestCount)
        cell.contentView.addSubview(openImage)
        cell.contentView.addSubview(optionImage)
        cell.contentView.addSubview(borderView)
        
        
        // Add Auto Layout constraints
        NSLayoutConstraint.activate([
            // Open image constraints
            openImage.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5),
            openImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            openImage.widthAnchor.constraint(equalToConstant: 20),
            openImage.heightAnchor.constraint(equalToConstant: 20),
            
            // Label constraints
            label.leadingAnchor.constraint(equalTo: openImage.trailingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            
            // Request count constraints
            requestCount.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            requestCount.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            
            // Option image constraints
            optionImage.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10), // 오른쪽에 맞추기
            optionImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            // optionImage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor), // 세로 중앙 맞춤
            optionImage.widthAnchor.constraint(equalToConstant: 20),
            optionImage.heightAnchor.constraint(equalToConstant: 20),
            
            borderView.topAnchor.constraint(equalTo: requestCount.bottomAnchor, constant: 3),
            borderView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
            borderView.widthAnchor.constraint(equalToConstant: 1),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = items[indexPath.item].requestList.count
        let baseHeight: CGFloat = 60 // Parent content 높이
        
        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if isExpandedArray[indexPath.item] {
            let additionalHeight = CGFloat(requestItemsCount * 60) // 각 자식 아이템당 60의 높이
            print("TEST")
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight + additionalHeight)
        } else {
            // flag가 false일 경우, 기본 높이만 반환
            print("TEST2")
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight)
        }
    }
    
    
    @objc func handleOpenImage(_ sender: UITapGestureRecognizer) {
        print("click")
        guard let tappedImageView = sender.view as? UIImageView else { return }
        var cellSuperview: UIView? = tappedImageView
        print("superview : \(cellSuperview) /// \(cellSuperview?.superview)")
        while let superview = cellSuperview?.superview {
            if let cell = superview as? MyCollectionViewCell {
                
                guard let indexPath = parentCollectionView.indexPath(for: cell) else { return }
                // Toggle the expansion state
                isExpandedArray[indexPath.item].toggle()
                cell.shouldHideCells.toggle()
                // Perform batch updates to animate the cell reloading
                parentCollectionView.performBatchUpdates({
                    parentCollectionView.reloadItems(at: [indexPath])
                }, completion: { _ in
                    print("Updated expansion state: \(self.isExpandedArray[indexPath.item]) \(cell.shouldHideCells)")
                    // Refresh the sub items based on the expansion state
                    cell.refreshSubItems(Array(self.items[indexPath.item].requestList), shouldHide: cell.shouldHideCells)
                    //cell.configure(with: Array(self.items[indexPath.item].requestList), expanded: self.isExpandedArray[indexPath.item])
                    // Update arrow image based on expanded state
                    tappedImageView.image = UIImage(systemName: self.isExpandedArray[indexPath.item] ? "arrow.up" : "arrow.down")
                })
                break
            }
            cellSuperview = superview
        }
        //guard let tappedImageView = sender.view as? UIImageView else { return }
        //guard let cell = tappedImageView.superview?.superview as? MyCollectionViewCell else { return }
        //guard let indexPath = parentCollectionView.indexPath(for: cell) else { return }
        //        let requestItems = items[indexPath.item].requestList
        //        // 해당 셀의 상태(isExpanded)를 전환
        //        print("indexPath: \(indexPath.item) + clicked")
        //        isExpandedArray[indexPath.item].toggle()
        //        if isExpandedArray[indexPath.item] {
        //            tappedImageView.image = UIImage(systemName: "arrow.down")
        //            cell.shouldHideCells = false
        //            cell.refreshSubItems(Array(requestItems))
        //        } else {
        //            tappedImageView.image = UIImage(systemName: "arrow.up")
        //            cell.shouldHideCells = false
        //            cell.refreshSubItems(Array(requestItems))
        //        }
        
        // 해당 셀만 다시 로드
        //  parentCollectionView.reloadItems(at: [indexPath])
        
        // 레이아웃을 강제로 다시 계산
        //parentCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    @objc func handleOptionImage(_ sender: UITapGestureRecognizer){
        print("option Image tapped")
        if let tappedView = sender.view {
            let indexPath = tappedView.tag
            print("indexPath : \(indexPath)")
            showSelectDialog(title: "REQUEST 관리", message: "", index: indexPath)
        }
        
    }
    
    //    @objc func moveToTabApi(_ sender: UITapGestureRecognizer){
    //        guard let tappedImageView = sender.view as? UIImageView else { return }
    //        guard let cell = tappedImageView.superview?.superview as? MyCollectionViewCell else { return }
    //        guard let indexPath = collectionView.indexPath(for: cell) else { return }
    //        // 우선 예시로 여기서 관리해봄
    //        let type: String? = items[indexPath.item].subItems.first?.type
    //        let title: String? = items[indexPath.item].subItems.first?.title
    //
    //
    //        if let tabBarController = tabBarController,
    //           let apiTab = tabBarController.viewControllers?[1] as? ApiTabController {
    //            apiTab.receivedData = ApiModel(type: type ?? "", title: title ?? "")
    //
    //            tabBarController.selectedIndex = 1
    //        }
    //    }
    
    
    func setupViews(){
        // 라벨
        let label = UILabel()
        label.text = "New Collection"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃을 사용하기 위해 필수
        // 더하기 이미지
        let addImage = UIImageView()
        addImage.image = UIImage(systemName: "plus")
        addImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(addImage)
        // 경계선
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        view.addSubview(borderView)
        
        
        // addImage 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImageTapped))
        addImage.isUserInteractionEnabled = true
        addImage.addGestureRecognizer(tapGesture)
        
        
        NSLayoutConstraint.activate(
            [
                addImage.heightAnchor.constraint(equalToConstant: 20),
                addImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                addImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // safeArea 레이아웃 가이드의 상단 10포인트 띄우기
                label.leadingAnchor.constraint(equalTo: addImage.trailingAnchor, constant: 20),
                borderView.heightAnchor.constraint(equalToConstant: 1),
                borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                borderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
                borderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
            ]
        )
    }
    // New Collection 선택한 상황 -> 컬랙션추가
    @objc private func addImageTapped(){
        print("addImage Tapped")
        showInputDialog(title: "CREATE A NEW COLLECTION", message: "Collection Name", inputPlaceholder: "Create a new Collection", subTitle: "CREATE", actionHandler: { inputText in
            print("User Input Collection : \(inputText)")
            let newCollection = CollectionModel()
            newCollection.title = String(inputText!)
            newCollection.requestCount = 0
            self.realmDao.insertCollection(newCollection)
            
            self.items.append(newCollection)
            self.isExpandedArray.append(false)
            self.imageArrowArray.append(UIImageView(image: UIImage(systemName: "arrow.up")))
            self.imageOptArray.append(UIImageView(image: UIImage(systemName: "ellipsis")))
            self.borderViewArray.append(UIView())
            DispatchQueue.main.async {
                self.parentCollectionView.reloadData()
            
            }
        })
    }
    
    
    func showSelectDialog(title: String?, message: String?, index: Int?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let renameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 20))
        renameLabel.text = "Rename"
        renameLabel.textAlignment = .center
        renameLabel.textColor = .black
        renameLabel.font = UIFont.systemFont(ofSize: 14)
        renameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let addRequestLabel = UILabel(frame: CGRect(x: 35, y: 0, width: 250, height: 20))
        addRequestLabel.text = "Add Request"
        addRequestLabel.textAlignment = .center
        addRequestLabel.textColor = .black
        addRequestLabel.font = UIFont.systemFont(ofSize: 14)
        addRequestLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let deleteLabel = UILabel(frame: CGRect(x: 70, y: 0, width: 250, height: 20))
        deleteLabel.text = "Delete"
        deleteLabel.textAlignment = .center
        deleteLabel.textColor = .black
        deleteLabel.font = UIFont.systemFont(ofSize: 14)
        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        alertController.view.addSubview(renameLabel)
        alertController.view.addSubview(addRequestLabel)
        alertController.view.addSubview(deleteLabel)
        
        let borderView1 = UIView()
        let borderView2 = UIView()
        let borderView3 = UIView()
        
        borderView1.translatesAutoresizingMaskIntoConstraints = false
        borderView2.translatesAutoresizingMaskIntoConstraints = false
        borderView3.translatesAutoresizingMaskIntoConstraints = false
        
        borderView1.backgroundColor = .lightGray
        borderView2.backgroundColor = .lightGray
        borderView3.backgroundColor = .lightGray
        alertController.view.addSubview(borderView1)
        alertController.view.addSubview(borderView2)
        alertController.view.addSubview(borderView3)
        // UIAlertController의 뷰에 라벨들의 제약 조건 설정
        NSLayoutConstraint.activate([
            // label1 제약조건
            renameLabel.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 60),
            renameLabel.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            renameLabel.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView1.topAnchor.constraint(equalTo: renameLabel.bottomAnchor, constant: 10),
            borderView1.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            borderView1.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView1.heightAnchor.constraint(equalToConstant: 1),
            // label2 제약조건
            addRequestLabel.topAnchor.constraint(equalTo: borderView1.bottomAnchor, constant: 10),
            addRequestLabel.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            addRequestLabel.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView2.topAnchor.constraint(equalTo: addRequestLabel.bottomAnchor, constant: 10),
            borderView2.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            borderView2.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView2.heightAnchor.constraint(equalToConstant: 1),
            // label3 제약조건
            deleteLabel.topAnchor.constraint(equalTo: borderView2.bottomAnchor, constant: 10),
            deleteLabel.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            deleteLabel.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView3.topAnchor.constraint(equalTo: deleteLabel.bottomAnchor, constant: 10),
            borderView3.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            borderView3.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            borderView3.heightAnchor.constraint(equalToConstant: 1)
        ])
        let heightConstraint = NSLayoutConstraint(item: alertController.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        
        alertController.view.addConstraint(heightConstraint)
        
        let renameTapped = UITapGestureRecognizer(target: self, action: #selector(handleTap1(_ :)))
        let addReqTapped = UITapGestureRecognizer(target: self, action: #selector(handleTap2(_ :)))
        let deleteTapped = UITapGestureRecognizer(target: self, action: #selector(handleTap3(_ :)))
        
        print("index: \(index)")
        
        renameLabel.isUserInteractionEnabled = true
        addRequestLabel.isUserInteractionEnabled = true
        deleteLabel.isUserInteractionEnabled = true
        
        renameLabel.addGestureRecognizer(renameTapped)
        renameLabel.tag = index!
        addRequestLabel.addGestureRecognizer(addReqTapped)
        addRequestLabel.tag = index!
        deleteLabel.addGestureRecognizer(deleteTapped)
        deleteLabel.tag = index!
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel)
        alertController.addAction(cancelAction)
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
  
    
    // textField 1개
    func showInputDialog(title: String?, message: String?, inputPlaceholder: String?, subTitle: String?, actionHandler: @escaping (String?) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = .default
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {_ in print("Cancel")})
        alertController.addAction(cancelAction)
        let action = UIAlertAction(title: subTitle, style: .default) { _ in
            let textField = alertController.textFields?.first
            actionHandler(textField?.text)
        }
        alertController.addAction(action)
        
        // 대화상자 화면에 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // textField 2개인 다이얼로그
    func showInputDoubleDialog(title: String?, message: String?, inputPlaceholder: String?, inputPlaceholder2: String?, subTitle: String?, actionHandler: @escaping(String, String) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { title in
            title.placeholder = inputPlaceholder
            title.keyboardType = .default
        }
        
        alertController.addTextField { type in
            type.placeholder = inputPlaceholder2
            type.keyboardType = .default
        }
        
        let okAction = UIAlertAction(title: subTitle, style: .default) { _ in
            let titleField = alertController.textFields?.first
            let typeField = alertController.textFields?.last
            actionHandler(titleField?.text ?? "", typeField?.text ?? "")
        }
        alertController.addAction(okAction)
        // 대화상자 화면에 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Collection 이름 변경
    @objc func handleTap1(_ sender: UITapGestureRecognizer){
        print("rename clicked")
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        print("realm 위치: ", Realm.Configuration.defaultConfiguration.fileURL!)
        if let tappedView = sender.view {
            let index = tappedView.tag
            showInputDialog(title: "Rename Collection", message: "변경할 이름 입력", inputPlaceholder: "rename collection", subTitle: "Confirm", actionHandler: { inputText in
                let id = self.items[index].id
                if let unwrappedInputText = inputText {
                    self.realmDao.renameCollection(id: id, newTitle: unwrappedInputText)
                } else {
                    print("inputText is nil")
                }
                
                self.parentCollectionView.reloadData()
            })
        }
        
    }
    
    // Request -> Collection에 추가
    @objc func handleTap2(_ sender: UITapGestureRecognizer){
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        if let tappedView = sender.view {
            print("add request clicked")
            let index = tappedView.tag
            showInputDoubleDialog(title: "요청값추가", message: "타입/제목 입력해주세요", inputPlaceholder: "제목입력", inputPlaceholder2: "타입입력", subTitle: "Add Request", actionHandler: { inputText1, inputText2 in
                print("inputText: \(inputText1) / \(inputText2)")
                if(inputText1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && inputText2.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
                    self.appendRequest(title: inputText1, type: inputText2, index: index)
                    
                }
                else {
                    self.showWarningPopup()
                }
            })
        }
    }
    
    // Collection 삭제
    @objc func handleTap3(_ sender: UITapGestureRecognizer){
        print("delete clicked")
        if let tappedView = sender.view {
            let index = tappedView.tag
            
            // 선택된 CollectionModel의 ID를 통해 해당 객체 가져오기
            let id = self.items[index].id
            if let collection = self.realmDao.getCollection(byId: id) {
                // Realm에서 해당 CollectionModel 삭제
                self.realmDao.removeCollection(collection)
                
                // 데이터 모델에서 해당 아이템 제거
                self.items.remove(at: index)
                self.isExpandedArray.remove(at: index)
                
                // UICollectionView를 갱신하여 UI 업데이트
                self.collectionView.reloadData()
            }
            
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.dismiss(animated: true)
            }
        }
    }
    // add Request
    /*
     @Persisted(primaryKey: true) var id: ObjectId
     @Persisted var type: String
     @Persisted var title: String
     @Persisted var url: String
     */
    @objc func appendRequest(title: String, type: String, index: Int){
        let id = self.items[index].id
        let requestData = RequestModel()
        requestData.title = title
        requestData.type = type
        requestData.url = ""
        self.realmDao.insertRequest(requestData: requestData)
        print("id: \(requestData.id)")
        self.realmDao.insertReqToCollection(id: id, requestData:  requestData)
        
        // testO
        // id로 갯수 뽑아와서 requestCount 수정하기
        self.realmDao.updateRequestCount(id: id)
        // 리스트 추가
        /*
         id 값으로 현재 리스트를 찾은 다음에 거기에 리스트로 추가하기
         */
        // 화면 재조회
        print("self Items Check : \(self.items)")
        self.parentCollectionView.reloadData()
    }
    
    func showWarningPopup() {
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        let alertController = UIAlertController(title: "경고", message: "필수정보를 입력해주세요", preferredStyle: .alert)
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 팝업 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
}
