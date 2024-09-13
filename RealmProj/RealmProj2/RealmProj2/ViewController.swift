//
//  ViewController.swift
//  RealmProj2
//
//  Created by haams on 9/12/24.
//

import UIKit
import Realm
import RealmSwift
class ViewController: UIViewController {

    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var nameTxtField2: UITextField!
    
    
    @IBOutlet weak var changeNameField: UITextField!
    @IBOutlet weak var changeNumberField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTxtField.placeholder = "이름을 적어주세요"
        phoneNumberTxtField.placeholder = "010-XXXX-XXXX"
        nameTxtField2.placeholder = "전화번호를 알기위해 이름을 적어주세요"
        changeNameField.placeholder = "번호를 변경하려 합니다.  이름을 적어주세요."
        changeNumberField.placeholder = "변경할 번호를 적어주세요"
        // Realm 파일을 저장할 경로 설정 (macOS 앱의 경우)
        
        let config = Realm.Configuration(schemaVersion: 4)
        Realm.Configuration.defaultConfiguration = config
        print("fileUrl: \(Realm.Configuration.defaultConfiguration.fileURL)")
    }
    // 이름 입력된 것에 대해 번호 지우기
    @IBAction func removeData(_ sender: UIButton) {
        let realm = try! Realm()
        let result = realm.objects(PhoneBook.self).filter(NSPredicate(format: "name = %@", nameTxtField2.text ?? ""))
        // let result = realm.objects(PhoneBook.self).filter("name = %@", nameTxtField2.text ?? "")
//        let result = realm.objects(PhoneBook.self).where {
//            $0.name == nameTxtField2.text ?? ""
//        }
        try! realm.write {
            realm.delete(result)
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
        // let realm = PhoneBook().realm
        let phoneBook = PhoneBook()
        phoneBook.name = nameTxtField.text
        phoneBook.number = phoneNumberTxtField.text
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(phoneBook)
        }
    }
    
    
    @IBAction func loadBtnClicked(_ sender: UIButton) {
        let realm = try! Realm()
        let phoneBook = realm.objects(PhoneBook.self)
        let predicateQuery = NSPredicate(format: "name = %@", nameTxtField2.text ?? "")
        let result = phoneBook.filter(predicateQuery)
        print("result : \(result)")
        
        // result[0]
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "찾는 분의 번호입니다.", message: result.first?.number, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                self.dismiss(animated: true)
            }
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func changeNumberButtonClicked(_ sender: UIButton) {
        let realm = try! Realm()
        let result = realm.objects(PhoneBook.self).filter(NSPredicate(format: "name = %@", changeNameField.text ?? ""))
        try! realm.write {
            result.first?.number = changeNumberField.text ?? ""
        }
        
        try! realm.write {
            realm.add(result, update: .modified)
        }
    }
}

