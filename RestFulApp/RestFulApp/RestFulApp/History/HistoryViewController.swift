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
import Realm
import RealmSwift

class HistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // private var collectionView: UICollectionView?
    private var items: [CollectionModel] = []
    // private var items: [HistoryModel] = []
    private let borderView = UIView()
    private var collectionView: UICollectionView! = nil
    private var realmDao = RealmDao()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentCell", for: indexPath) as! ParentCollectionViewCell
        let dateLabel = UILabel()
        dateLabel.text = String(items[indexPath.item].title)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.isUserInteractionEnabled = true
        cell.contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 20)
        ])
        
        cell.setRequestItems(items[indexPath.row].requestList)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.size.width - 20, height: 100)  // 셀 크기 설정
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
    }
    
    func setupViews(){
        let label = UILabel()
        label.text = "CLEAR ALL"
        label.font.withSize(16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.backgroundColor = .white
        
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
        
        self.getHistoryData()
    }
    
    func getHistoryData(){
        let collectionResults = self.realmDao.getAllCollection()
        items = Array(collectionResults)
        collectionView.reloadData()
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        
        collectionView.register(ParentCollectionViewCell.self, forCellWithReuseIdentifier: "ParentCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
}


class ParentCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var subCollectionView: UICollectionView!
    private var subItems = List<RequestModel>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubCollectionView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubCollectionView()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subItems.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }

    func setRequestItems(_ items: List<RequestModel>) {
        self.subItems = items
        print("SubItems count in setRequestItems: \(self.subItems.count)")
        subCollectionView.reloadData()
    }

    func setupSubCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10

        subCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        subCollectionView.delegate = self
        subCollectionView.dataSource = self
        subCollectionView.backgroundColor = .lightGray

        subCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SubCell")
        subCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subCollectionView)

        NSLayoutConstraint.activate([
            subCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            subCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            subCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath)
        
        // 셀의 이전 내용 제거
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let typeLabel = UILabel()
        let titleLabel = UILabel()
        typeLabel.text = subItems[indexPath.item].type
        titleLabel.text = subItems[indexPath.item].title
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(typeLabel)
        cell.contentView.addSubview(titleLabel)

        // 레이아웃 제약조건 추가
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            typeLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor)
        ])
        
        return cell
    }
}
