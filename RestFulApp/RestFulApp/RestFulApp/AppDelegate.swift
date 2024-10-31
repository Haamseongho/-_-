//
//  AppDelegate.swift
//  RestFulApp
//
//  Created by haams on 9/10/24.
//

import UIKit
import RealmSwift

func setupRealmMigration() {
    let config = Realm.Configuration(
        schemaVersion: 1, // 현재 스키마 버전 설정, 기존보다 높은 숫자로 설정
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // 필요한 경우 속성 변환 로직을 추가
                migration.enumerateObjects(ofType: HistoryModel.className()) { oldObject, newObject in
                    newObject!["date"] = Date()  // 기본값 설정, 필요 시 수정
                }
            }
        }
    )

    Realm.Configuration.defaultConfiguration = config
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRealmMigration()
        // 윈도우 생성
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // TabBarController 생성
        let tabBarController = CustomTabBarController()
        // rootViewController로 설정
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

