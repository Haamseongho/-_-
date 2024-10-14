import UIKit
import SwiftUI

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Tab Bar Item 설정
        let tab1 = CollectionTabConroller()
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
