import UIKit
import SwiftUI

class FirstTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    private var items: [String] = ["Collection1", "Collection2", "Collection3"]
    
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
        // CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width - 20, height: 100)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        //  collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(ParentCollectionViewCell.self, forCellWithReuseIdentifier: "ParentCell")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate(
            [
                addImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                addImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // safeArea 레이아웃 가이드의 상단 10포인트 띄우기
                label.leadingAnchor.constraint(equalTo: addImage.trailingAnchor, constant: 20),
                borderView.heightAnchor.constraint(equalToConstant: 1),
                borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                borderView.topAnchor.constraint(equalTo: addImage.bottomAnchor, constant: 15),
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count  // 셀의 개수
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentCell", for: indexPath) as! ParentCollectionViewCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    //        cell.backgroundColor = .lightGray
    //
    //        // 셀에 텍스트 레이블 추가
    //        let label = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
    //        label.text = items[indexPath.item]
    //        label.textAlignment = .center
    //        label.font = UIFont.systemFont(ofSize: 16)
    //
    //        // 셀의 기존 레이블 중복 방지를 위해 제거 후 다시 추가
    //        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    //        cell.contentView.addSubview(label)
    //
    //        return cell
    //    }
    //
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width - 20, height: 100)  // 셀 크기 설정
    }
}


class SecondTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

class ThirdTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .magenta
    }
}

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Tab Bar Item 설정
        let tab1 = FirstTabController()
        tab1.tabBarItem = UITabBarItem(title: "Tab 1", image: UIImage(systemName: "1.circle"), tag: 0)
        
        let tab2 = SecondTabController()
        tab2.tabBarItem = UITabBarItem(title: "Tab 2", image: UIImage(systemName: "2.circle"), tag: 1)
        
        let tab3 = ThirdTabController()
        tab3.tabBarItem = UITabBarItem(title: "Tab 3", image: UIImage(systemName: "3.circle"), tag: 2)
        
        viewControllers = [tab1, tab2, tab3]
        
    }
    
}

struct Collection {
    var title: String
    var requestCount: Int
    var imgMenu: UIImageView
}

class ParentCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var subCollectionView: UICollectionView!
    private var subItems: [Collection] = [Collection(title: "title1", requestCount: 1, imgMenu: UIImageView(image: UIImage(systemName: "plus"))),
                                          Collection(title: "title2", requestCount: 2, imgMenu: UIImageView(image: UIImage(systemName: "plus"))),
                                          Collection(title: "title3", requestCount: 3, imgMenu: UIImageView(image: UIImage(systemName: "plus")))]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubCollectionView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubCollectionView()
    }
    
    private func setupSubCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60) // 서브 셀 크기 설정
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
    
    func configure(with title: String) {
        // 셀의 제목 설정 등 추가 작업을 여기에 구현할 수 있습니다.
        // 이 부분에서 title을 사용하여 레이블 등을 추가할 수 있습니다.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subItems.count // 서브 셀의 개수
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath)
        cell.backgroundColor = .blue
        
        // 서브 셀에 텍스트 레이블 추가
        let label = UILabel(frame: cell.bounds)
        label.text = subItems[indexPath.item].title
        let requestCount = UILabel(frame: cell.bounds)
        requestCount.text = String(subItems[indexPath.item].requestCount)
        var subImage = UIImageView()
        subImage = subItems[indexPath.item].imgMenu
        
        label.textAlignment = .center
        label.textColor = .white
        cell.contentView.addSubview(label)
        cell.contentView.addSubview(requestCount)
        cell.contentView.addSubview(subImage)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60) // 서브 셀 크기 설정
    }
}
