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

class CollectionTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var flag = false
    private var dataPassDelegate: DataPassingDelegate?
    
    
    private var items: [CollectionModel]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
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
        let requestItems = items[indexPath.item].subItems // subItems는 실제 데이터 배열이어야 함
        let isExpanded = items[indexPath.item].isExpanded
 
        cell.setRequestItems(requestItems, isExpanded: isExpanded)
  
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let requestItemsCount = items[indexPath.item].subItems.count
        let baseHeight: CGFloat = 60 // Parent content 높이

        // flag가 true일 경우, 자식 아이템의 높이를 포함한 크기
        if items[indexPath.item].isExpanded {
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
        let requestItems = items[indexPath.item].subItems
        // 해당 셀의 상태(isExpanded)를 전환
        items[indexPath.item].isExpanded.toggle()
        if items[indexPath.item].isExpanded {
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
        
        cell.setRequestItems(requestItems, isExpanded: items[indexPath.item].isExpanded)
        
       
    }
    
    @objc func moveToTabApi(_ sender: UITapGestureRecognizer){
        guard let tappedImageView = sender.view as? UIImageView else { return }
        guard let cell = tappedImageView.superview?.superview as? MyCollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        // 우선 예시로 여기서 관리해봄
        let type: String? = items[indexPath.item].subItems.first?.type
        let title: String? = items[indexPath.item].subItems.first?.title
        
      
        if let tabBarController = tabBarController,
           let apiTab = tabBarController.viewControllers?[1] as? ApiTabController {
            apiTab.receivedData = ApiModel(type: type ?? "", title: title ?? "")
            
            tabBarController.selectedIndex = 1
        }
    }
    
   
   

    
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
        showInputDialog(title: "CREATE A NEW COLLECTION", message: "Collection Name", inputPlaceholder: "Create a new Collection", subTitle: "CREATE", actionHandler: { inputText in
            print("User Input Collection : \(inputText)")
        })
    }
    
    func showInputDialog(title: String?, message: String?, inputPlaceholder: String?, subTitle: String?, actionHandler: ((_ text: String?) -> Void)){
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
}
