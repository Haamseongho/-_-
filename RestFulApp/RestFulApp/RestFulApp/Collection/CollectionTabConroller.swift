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

class CollectionTabConroller: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var items: [CollectionModel] = [
        CollectionModel(openImage: UIImageView(image: UIImage(systemName: "arrow.up")), title: "Collection1", requestCount: 1, optionImage: UIImageView(image: UIImage(systemName: "ellipsis")), borderView: UIView(), subItems:  [
            RequestModel(type: "GET", title: "title1", optionImage: UIImageView(image: UIImage(systemName: "ellipsis"))),
            RequestModel(type: "GET", title: "title1", optionImage: UIImageView(image: UIImage(systemName: "ellipsis"))),
            RequestModel(type: "GET", title: "title1", optionImage: UIImageView(image: UIImage(systemName: "ellipsis")))
        ]
                       ),
        CollectionModel(openImage: UIImageView(image: UIImage(systemName: "arrow.up")), title: "Collection2", requestCount: 2, optionImage: UIImageView(image: UIImage(systemName: "ellipsis")), borderView: UIView(), subItems: [
            RequestModel(type: "POST", title: "title2", optionImage: UIImageView(image: UIImage(systemName: "ellipsis"))),
            RequestModel(type: "POST", title: "title3", optionImage: UIImageView(image: UIImage(systemName: "ellipsis")))
        ]),
        CollectionModel(openImage: UIImageView(image: UIImage(systemName: "arrow.up")), title: "Collection3", requestCount: 3, optionImage: UIImageView(image: UIImage(systemName: "ellipsis")), borderView: UIView(), subItems: [
            RequestModel(type: "DELETE", title: "title4", optionImage: UIImageView(image: UIImage(systemName: "ellipsis"))),
            RequestModel(type: "PUT", title: "title5", optionImage: UIImageView(image: UIImage(systemName: "ellipsis")))
        ])
    ]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc func handleOpenImage(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        guard let cell = tappedImageView.superview?.superview as? MyCollectionViewCell else { return }
        if tappedImageView.image == UIImage(systemName: "arrow.up") {
            tappedImageView.image = UIImage(systemName: "arrow.down")
        } else {
            tappedImageView.image = UIImage(systemName: "arrow.up")
        }
        
        let indexPath = collectionView.indexPath(for: cell)!
        let requestItems = items[indexPath.item].subItems
        print("Received items222: \(requestItems)") // 데이터가 잘 넘어오는지 확인
    
        cell.setRequestItems(requestItems)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentCell", for: indexPath) as! MyCollectionViewCell
        
        
        
        cell.backgroundColor = .white
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
        
        let openImage: UIImageView = items[indexPath.item].openImage
        let optionImage: UIImageView = items[indexPath.item].optionImage
        openImage.translatesAutoresizingMaskIntoConstraints = false
        optionImage.translatesAutoresizingMaskIntoConstraints = false
        
        openImage.isUserInteractionEnabled = true
        optionImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOpenImage(_:)))
        openImage.addGestureRecognizer(tapGesture)
        
        
        // 경계선
        let borderView: UIView = items[indexPath.item].borderView
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        // Clear any existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
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
            optionImage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor), // 세로 중앙 맞춤
            optionImage.widthAnchor.constraint(equalToConstant: 20),
            optionImage.heightAnchor.constraint(equalToConstant: 20),
            
            borderView.topAnchor.constraint(equalTo: requestCount.bottomAnchor, constant: 3),
            borderView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
            borderView.widthAnchor.constraint(equalToConstant: 1),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // 자식뷰 더하기
        let requestItems = items[indexPath.item].subItems // subItems는 실제 데이터 배열이어야 함
        cell.setRequestItems(requestItems)
  
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = items[indexPath.item].subItems.count
        let height = CGFloat(60 + requestItemsCount * 60) // Parent content 높이 + 자식 content 높이
        return CGSize(width: collectionView.bounds.width - 20, height: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
        
        view.addSubview(collectionView)
        
        
        NSLayoutConstraint.activate(
            [
                addImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                addImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // safeArea 레이아웃 가이드의 상단 10포인트 띄우기
                label.leadingAnchor.constraint(equalTo: addImage.trailingAnchor, constant: 20),
                borderView.heightAnchor.constraint(equalToConstant: 1),
                borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                borderView.topAnchor.constraint(equalTo: addImage.bottomAnchor, constant: 3),
                borderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                collectionView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 10),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
            ]
        )
        
        
        
    }
    
    // New Collection 선택한 상황
    @objc private func addImageTapped(){
        print("addImage Tapped")
    }
}

