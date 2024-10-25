//
//  MyCollectionViewCell.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit
import RealmSwift
class MyCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var subCollectionView: UICollectionView!
    private var subItems: List<RequestModel> = List<RequestModel>()
    private var imageSubOptArray: [UIImageView] = []
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubCollectionView()
       // subCollectionView.isHidden = false
        subCollectionView.reloadData()  // 데이터 리로드
    }
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        subCollectionView.delegate = self
        subCollectionView.dataSource = self

        setupSubCollectionView()
       // subCollectionView.isHidden = false
        subCollectionView.reloadData()  // 데이터 리로드
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀 상태 초기화
    }
    
    func setupSubCollectionView(){
        let layout = UICollectionViewFlowLayout()
        // layout.itemSize = CGSize(width: 60, height: 60) // 서브 셀 크기 설정
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        subCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      //  subCollectionView.backgroundColor = .lightGray
        
        print("여기되나?")
        subCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SubCell")
        subCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subCollectionView)
        
        
        NSLayoutConstraint.activate([
            subCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            subCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            subCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            subCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        subCollectionView.reloadData()
    }
    
    func setRequestItems(_ items: List<RequestModel>, isExpanded: Bool) {
        self.subItems = items  // requestModel을 리스트 형태로 우선 넘기기
        self.imageSubOptArray = Array(repeating: UIImageView(image: UIImage(systemName: "ellipsis")), count: items.count)
        print("isExpanded : \(isExpanded)")
        // isExpanded 상태에 따라 자식 CollectionView 표시/숨김 설정
        subCollectionView.isHidden = !isExpanded
        print("SubItems count in setRequestItems: \(self.subItems.count)")
        subCollectionView.reloadData() // 데이터 새로고침
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("subItemsCount: \(self.subItems.count)")
        return subItems.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 60) // 서브 셀 크기 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath)
        // 기존의 subviews를 모두 제거하고 새롭게 추가 (중복 방지)
        print("abc \(cell.contentView)")
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let requestItem = subItems[indexPath.item]
           
        // 로그 추가
        print("Configuring cell for item at index \(indexPath.item): \(requestItem)")
           
        
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
        
        let optionImage: UIImageView = imageSubOptArray[indexPath.item]
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
