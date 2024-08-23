//
//  ViewController.swift
//  WKWebViewProject
//
//  Created by haams on 8/23/24.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func openWebView(_ sender: UIButton) {
        webView = WKWebView(frame: self.view.frame)
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

