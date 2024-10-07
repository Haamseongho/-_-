//
//  request.swift
//  apiSend
//
//  Created by haams on 9/25/24.
//

import Foundation
import UIKit

/*
// Body없는 요청
func requestGet(url: String, completionHandler: @escaping(Bool, Any) -> Void){
    guard let url = URL(string: url) else {
        print("Error: URL 확인불가")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: GET 메소드 호출 이슈")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: 데이터 받기 실패")
            return
        }
        print(data)
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: Http request failed")
            return
        }
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Error: JSON Data 파싱 오류")
            return
        }
        
        completionHandler(true, output)
    }.resume()
}

func requestPost(url: String, method: String, param: [String: Any], completionHandler: @escaping(Bool, Any) -> Void){
    let sendData = try! JSONSerialization.data(withJSONObject: param, options: [])
    guard let url = URL(string: url) else {
        print("Error: URL 만들기 실패")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = sendData
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print("Error: POST 호출 실패")
            return
        }
        
        guard let data = data else {
            print("Error: 데이터 전달 실패")
            return
        }
        
        guard let response = response else {
            print("Error: 응답오류")
            return
        }
        
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Error: JSON 파싱오류")
            return
        }
        
        completionHandler(true, output)
    }.resume()
}

// 메서드별 동작 분리
func request(_ url: String, _ method: String, _ param: [String: Any]? = nil, completionHandler: @escaping(Bool, Any) -> Void){
    if method == "GET" {
        requestGet(url: url) {
            (success, data) in
            completionHandler(success, data)
        }
    }
    else {
        requestPost(url: url, method: method, param: param!) {
            (success, data) in
            completionHandler(success, data)
        }
    }
 
}

*/
