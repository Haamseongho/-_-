//
//  ViewController.swift
//  WKWebViewProject
//
//  Created by haams on 8/23/24.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, WKNavigationDelegate, CLLocationManagerDelegate {
    var webView: WKWebView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // 위치 권한 요청
        locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }
    // 위치 업데이트 시 호출되는 메서드
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location = locations.first {
             fetchAddress(from: location)
         }
     }
    // 위치 업데이트 실패 시 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }

    // 주소 정보를 가져오는 메서드
    func fetchAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "en_US")
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                let address = """
                \(placemark.name ?? ""), \(placemark.locality ?? ""), \
                \(placemark.administrativeArea ?? ""), \(placemark.country ?? "") , \(placemark.isoCountryCode ?? "")
                """
                print("Address: \(address)")
            }
        }
    }
    
    @IBAction func openWebView(_ sender: UIButton) {
        let width = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        let xPosition = self.view.frame.size.width / 4
        let yPosition = self.view.frame.size.height / 4
        
        // webView = WKWebView(frame: self.view.frame)
        webView = WKWebView(frame: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        // 로드할 URL 설정
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            
            self.webView.load(request)
        }
    }
    
    
    // Block
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if url.contains("naver.com") {
                decisionHandler(.cancel) // 해당 URL의 로드를 취소합니다.
                return
            }
        }
        decisionHandler(.allow) // 요청을 허용합니다.
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("웹 페이지 로드 시작")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("웹 페이지 콘텐츠 수신 시작")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로드 완료")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("웹 페이지 로드 실패: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("초기 탐색 실패: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("서버에서 리디렉션 받음")
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(user: "username", password: "password", persistence: .forSession)
        completionHandler(.useCredential, credential)
    }
    
}

