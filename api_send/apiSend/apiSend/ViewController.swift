//
//  ViewController.swift
//  apiSend
//
//  Created by haams on 9/25/24.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var urlText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    /*
    @IBAction func btnGet(_ sender: Any) {
        let url = "http://54.180.108.12:2721/api/get"
        let method = "GET"
        request(url, method) { (success, data) in
            if success {
                if let response = data as? Response {
                    print("성공: \(response.message)")
                }
            
            } else {
                print("실패")
                return
            }
        }
    }
    @IBAction func btnPost(_ sender: Any) {
        let url = "http://54.180.108.12:2721/api/post"
        let method = "POST"
        var param: [String:Any] = [:]
        param["name"] = "seongho"
        param["age"] = 32
        request(url, method, param) { (success , data) in
            if success {
                // @escaping 둘 때 Any로 두었기 때문에 data 응답값이 어떤 요소의 객체인지 모르므로 체크해줄것
                if let response = data as? Response {
                    print("요청값: \(response.reqMessage)")
                    print("응답값: \(response.message)")
                }
            } else {
                print("실패")
                return
            }
        }
    }
    
    */
    @IBAction func alamofireBtnGet(_ sender: Any) {
        let url = "http://54.180.108.12:2721/api/get/v2"
        AF.request(url, method: .get, encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"]).responseJSON() { response in
            switch response.result{
            case .success:
              if let data = try! response.result.get() as? [String: Any] {
                print(data)
              }
            case .failure(let error):
              print("Error: \(error)")
              return
            }
        }
    }
    
    @IBAction func alamofireBtnPost(_ sender: Any) {
        let url = "http://54.180.108.12:2721/api/post/v2"
        var param: [String:Any] = [:]
        param["name"] = "seongho"
        param["age"] = 32
        AF.request(url, method: .post, parameters: param,  encoding: JSONEncoding(options: []),
                   headers: ["Content-Type":"application/json", "Accept":"application/json"]).responseJSON() { response in
            switch response.result{
            case .success:
              if let data = try! response.result.get() as? [String: Any] {
                print(data)
              }
            case .failure(let error):
              print("Error: \(error)")
              return
            }
        }
    }
    
}

