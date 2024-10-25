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
import Realm
import RealmSwift

class CollectionTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var flag = false
    private var realmDao = RealmDao()
    
    
    private var items: [CollectionModel] = [] // ParentCell로 들어가는 아이템
    private var isExpandedArray: [Bool] = [] // 화살표 누름/닫힘 구분값
    private var imageArrowArray: [UIImageView] = []
    private var imageOptArray: [UIImageView] = []
    private var borderViewArray: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getDataFromDB()
        setupViews()
        
    }
    
    // db에서 먼저 가져와서 보여주기
    func getDataFromDB(){
        let collectionResults = self.realmDao.getAllCollection()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "ParentCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        items = Array(collectionResults)
        isExpandedArray = Array(repeating: false, count: items.count)
        imageArrowArray = Array(repeating: UIImageView(image: UIImage(systemName: "arrow.up")), count: items.count)
        imageOptArray = Array(repeating: UIImageView(image: UIImage(systemName: "ellipsis")), count: items.count)
        borderViewArray = Array(repeating: UIView(), count: items.count)
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentCell", for: indexPath) as! MyCollectionViewCell
        cell.backgroundColor = .white
        
        // 기존에 설정된 서브뷰 삭제
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
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
        
        // 자식뷰 더하기
        let requestItems = items[indexPath.item].requestList // subItems는 실제 데이터 배열이어야 함
        let isExpanded = isExpandedArray[indexPath.item]
        
        cell.setRequestItems(requestItems, isExpanded: isExpanded)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = items[indexPath.item].requestList.count
        let baseHeight: CGFloat = 60 // Parent content 높이
        
        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if isExpandedArray[indexPath.item] {
            let additionalHeight = CGFloat(requestItemsCount * 60) // 각 자식 아이템당 60의 높이
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight + additionalHeight)
        } else {
            // flag가 false일 경우, 기본 높이만 반환
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight)
        }
    }
    
    
    @objc func handleOpenImage(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        guard let cell = tappedImageView.superview?.superview as? MyCollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let requestItems = items[indexPath.item].requestList
        // 해당 셀의 상태(isExpanded)를 전환
        print("indexPath: \(indexPath.item) + clicked")
        isExpandedArray[indexPath.item].toggle()
        if isExpandedArray[indexPath.item] {
            tappedImageView.image = UIImage(systemName: "arrow.down")
            flag = true
        } else {
            tappedImageView.image = UIImage(systemName: "arrow.up")
            flag = false
        }
        
        // 해당 셀만 다시 로드
        collectionView.reloadItems(at: [indexPath])
        
        // 레이아웃을 강제로 다시 계산
        collectionView.collectionViewLayout.invalidateLayout()
        print("requestItems: \(requestItems)")
        cell.setRequestItems(requestItems, isExpanded: isExpandedArray[indexPath.item])
        
        
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
        
        
        view.addSubview(collectionView)
        
        
        
        NSLayoutConstraint.activate(
            [
                addImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                addImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // safeArea 레이아웃 가이드의 상단 10포인트 띄우기
                label.leadingAnchor.constraint(equalTo: addImage.trailingAnchor, constant: 20),
                borderView.heightAnchor.constraint(equalToConstant: 1),
                borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                borderView.topAnchor.constraint(equalTo: addImage.bottomAnchor, constant: 20),
                borderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                collectionView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 10),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
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
            self.collectionView.reloadData()
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
                
                self.collectionView.reloadData()
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
        
        // id로 갯수 뽑아와서 requestCount 수정하기
        self.realmDao.updateRequestCount(id: id)
        // 화면 재조회
        self.collectionView.reloadData()
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
