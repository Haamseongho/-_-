//
//  HistoryViewController.swift
//  RestFulApp
//
//  Created by haams on 10/22/24.
//

import Foundation
import UIKit
import SwiftUI
import RxSwift
import RealmSwift
import UIKit

class ParentCollectionViewCell: UICollectionViewCell {
    static let identifier = "ParentCollectionViewCell"
    var subItems : [RequestModel] = []
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
            childCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            childCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            childCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            childCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // func refreshSubItem
    func refreshSubItems(_ items: Array<RequestModel>){
        
        // items.append(reqModel)
        subItems = items
        childCollectionView.reloadData() // 변경 사항 반영
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ParentCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subItems.count // 예시로 10개의 아이템 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildCell", for: indexPath)
        cell.backgroundColor = .white // 셀 배경색 예시
        //   cell.heightAnchor.constraint(equalToConstant: 40)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let type = UILabel()
        type.text = subItems[indexPath.item].type
        type.translatesAutoresizingMaskIntoConstraints = false
        type.textColor = .black
        let title = UILabel()
        title.text = subItems[indexPath.item].title
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .black
        type.textColor = .black
        let optionImage = UIImageView(image: UIImage(systemName: "ellipsis"))
        optionImage.translatesAutoresizingMaskIntoConstraints = false
        optionImage.isUserInteractionEnabled = true
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
    
    // 레이아웃 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = subItems.count
        let baseHeight: CGFloat = 60 // Parent content 높이
        print("shouldHideCells23232323 : \(shouldHideCells)")
        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if !shouldHideCells {
            let additionalHeight = CGFloat(requestItemsCount * 60) // 각 자식 아이템당 60의 높이
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

class HistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var items: [HistoryModel] = []
    private let borderView = UIView()
    private var realmDao = RealmDao()
    private var isExpandedArray: [Bool] = [] // 화살표 누름/닫힘 구분값
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
        loadData()
     
        view.addSubview(parentCollectionView)
        
        parentCollectionView.dataSource = self
        parentCollectionView.delegate = self
        parentCollectionView.register(ParentCollectionViewCell.self, forCellWithReuseIdentifier: ParentCollectionViewCell.identifier)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            parentCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            parentCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            parentCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            parentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData(){
        let collectionResults = self.realmDao.getHistoryByOrdersInDate()
        items = Array(collectionResults)
        print("아이템: \(items)")
        isExpandedArray = Array(repeating: false, count: items.count)
        if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
            print("Realm 파일 경로: \(fileURL)")
        }
        setupViews()
        parentCollectionView.reloadData()
    }
    
    func setupViews(){
        let label = UILabel()
        label.text = "CLEAR ALL"
        label.font.withSize(16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.backgroundColor = .white
        
        let clearAll = UITapGestureRecognizer(target: self, action: #selector(clearAllHistory(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(clearAll)
        
        borderView.backgroundColor = .black
        borderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            borderView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            borderView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
        
        
    }
    
    @objc func clearAllHistory(_ sender: UITapGestureRecognizer) {
        print("drop table")
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.dismiss(animated: true)
        }
        let alertController = UIAlertController(title: "히스토리 삭제", message: "호출된 모든 정보를 삭제하시겠습니까?", preferredStyle: .alert)
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("OK Action")
            self.realmDao.dropHistoryTable()
            self.loadData()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 팝업 표시
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count // 예시로 5개의 아이템 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParentCollectionViewCell.identifier, for: indexPath) as! ParentCollectionViewCell
        // cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let arrowImage1 = UIImageView()
        let dateLabel = UILabel()
        print("에러체크 :\(items[indexPath.item].date )")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 원하는 날짜 형식 지정
        if let date = dateFormatter.date(from: dateFormatter.string(from: items[indexPath.item].date)) {
            dateLabel.text = "\(date)"
        } else {
            dateLabel.text = String(items[indexPath.item].title) // date
        }
        
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .black
        arrowImage1.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(arrowImage1)
        cell.addSubview(dateLabel)
        
        if isExpandedArray[indexPath.item] {
            arrowImage1.image = UIImage(systemName: "arrow.down")
        } else {
            arrowImage1.image = UIImage(systemName: "arrow.up")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(subCollectionOpen(_:)))
        arrowImage1.isUserInteractionEnabled = true
        arrowImage1.addGestureRecognizer(tapGesture)
        // 경계선
        let borderView: UIView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        cell.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            arrowImage1.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 24),
            arrowImage1.topAnchor.constraint(equalTo: cell.topAnchor, constant: 24),
            arrowImage1.widthAnchor.constraint(equalToConstant: 24),
            arrowImage1.heightAnchor.constraint(equalToConstant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: arrowImage1.leadingAnchor, constant: 30),
            dateLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 24),
            borderView.topAnchor.constraint(equalTo: cell.bottomAnchor, constant: 10),
            borderView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0)
        ])
        return cell
    }
    
    @objc func subCollectionOpen(_ sender: UITapGestureRecognizer){
        guard let tappedImageView = sender.view as? UIImageView else { return }
        var cellSuperview: UIView? = tappedImageView
        
        while let superview = cellSuperview?.superview {
            if let cell = superview as? ParentCollectionViewCell {
               
                guard let indexPath = parentCollectionView.indexPath(for: cell) else { return }
                // Toggle the expansion state
                isExpandedArray[indexPath.item].toggle()
                cell.shouldHideCells.toggle()
                // Perform batch updates to animate the cell reloading
                parentCollectionView.performBatchUpdates({
                    parentCollectionView.reloadItems(at: [indexPath])
                  //  parentCollectionView.deleteItems(at: [IndexPath(item: indexPath.item, section: 0)])
                  //  parentCollectionView.reloadItems(at: [indexPath])
                }, completion: { _ in
                    print("찬반 : \(self.isExpandedArray[indexPath.item])")
                    if self.isExpandedArray[indexPath.item] {
                        cell.shouldHideCells = true
                      //  cell.contentView.subviews.forEach { $0.removeFromSuperview() }  // 이 부분이 너무 어렵당... ㅠㅠ 
                    } else {
                        cell.shouldHideCells = false
                        cell.refreshSubItems(Array(self.items[indexPath.item].requestList))
                        self.parentCollectionView.reloadData()
                    }
                })
            }
            cellSuperview = superview
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = items[indexPath.item].requestList.count
        let baseHeight: CGFloat = 60
        
        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if isExpandedArray[indexPath.item] {
            let additionalHeight = CGFloat(requestItemsCount * 60) // 각 자식 아이템당 60의 높이
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight + additionalHeight)
        } else {
            // flag가 false일 경우, 기본 높이만 반환
            return CGSize(width: collectionView.bounds.width - 20, height: baseHeight)
        }
    }
    
}



