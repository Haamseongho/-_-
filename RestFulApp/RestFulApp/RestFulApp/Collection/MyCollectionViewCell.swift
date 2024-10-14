//
//  MyCollectionViewCell.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit
import RxSwift
class MyCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var subCollectionView: UICollectionView!
    private var subItems: [RequestModel] = []
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubCollectionView()
    }
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        setupSubCollectionView()
    }
    
    func setupSubCollectionView(){
        let layout = UICollectionViewFlowLayout()
        // layout.itemSize = CGSize(width: 60, height: 60) // 서브 셀 크기 설정
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        subCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        subCollectionView.delegate = self
        subCollectionView.dataSource = self
        subCollectionView.backgroundColor = .lightGray
        
        
        subCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subCollectionView)
        NSLayoutConstraint.activate([
            subCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            subCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            subCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        subCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SubCell")
        
    }
    
    func setRequestItems(_ items: [RequestModel]) {
        self.subItems = items
        print("Received items: \(subItems)") // 데이터가 잘 넘어오는지 확인
        subCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subItems.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60) // 서브 셀 크기 설정
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath)
        cell.backgroundColor = .lightGray
        let type = UILabel(frame: cell.contentView.bounds)
        type.text = subItems[indexPath.item].type
        type.textColor = UIColor.black
        type.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        type.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃을 사용하기 위해 필수
        
        let title = UILabel(frame: cell.contentView.bounds)
        title.text = subItems[indexPath.item].title
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 14)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let optionImage: UIImageView = subItems[indexPath.item].optionImage
        optionImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOpenImage(_:)))
        optionImage.addGestureRecognizer(tapGesture)
        
        
        cell.contentView.addSubview(type)
        cell.contentView.addSubview(title)
        cell.contentView.addSubview(optionImage)
        
        // 오토레이아웃 제약 조건 추가
        NSLayoutConstraint.activate([
            type.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            type.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            
            title.leadingAnchor.constraint(equalTo: type.trailingAnchor, constant: 10),
            title.topAnchor.constraint(equalTo: type.topAnchor),
            
            optionImage.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            optionImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            optionImage.widthAnchor.constraint(equalToConstant: 30),
            optionImage.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return cell
    }
    
    @objc func handleOpenImage(_ sender: UITapGestureRecognizer){
        print("image Clicked")
    }
    
   
}
