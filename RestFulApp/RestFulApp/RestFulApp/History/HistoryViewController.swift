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

class HistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewFlowLayout {
   
    private var collectionView: UICollectionView
    private var items: [HistoryModel] = [
        HistoryModel(type: "GET", date: "2024-10-23", title: "https://www.google.com", subItem: [
            SubHistoryItem(type: "GET", title: "https://www.google.com", plusImage: UIImageView(image: UIImage(systemName: "plus"))),
            SubHistoryItem(type: "POST", title: "https://www.google.com", plusImage: UIImageView(image: UIImage(systemName: "plus"))),
            SubHistoryItem(type: "PUT", title: "https://www.google.com", plusImage: UIImageView(image: UIImage(systemName: "plus")))
        ], isExpanded: false),
        HistoryModel(type: "POST", date: "2024-10-24", title: "https://www.naver.com", subItem: [
            SubHistoryItem(type: "GET", title: "https://www.naver.com", plusImage: UIImageView(image: UIImage(systemName: "plus"))),
            SubHistoryItem(type: "POST", title: "https://www.naver.com", plusImage: UIImageView(image: UIImage(systemName: "plus"))),
            SubHistoryItem(type: "PUT", title: "https://www.naver.com", plusImage: UIImageView(image: UIImage(systemName: "plus")))
        ], isExpanded: true)
    ]
    
    
    let borderView = UIView()
    
    override func viewDidLoad() {
        setupViews()
        setupCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
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
    }
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HistoryCollectionCell.self, forCellWithReuseIdentifier: "ParentCell2")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentCell2", for: indexPath)
        cell.backgroundColor = .white
    }
    
    
}
