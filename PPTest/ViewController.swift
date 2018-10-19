//
//  ViewController.swift
//  PPTest
//
//  Created by r leseberg on 10/17/18.
//  Copyright © 2018 starion. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var clickMeButton: UIButton?
    var webView: WKWebView?
    
    let bgQueue = DispatchQueue(label: "bgQueue", qos: .userInitiated)
    
    @objc func clickMeClicked(_ sender: Any) {
        print(#function)
        
        clickMeButton?.isEnabled = false
        if let url = URL(string: "https://www.google.com/search?q=paypal") {
//        if let url = URL(string: "http://www.notAnAddress.com/popcorn.html") {

            let fetch = URLFetch()
            let blankHTML = getBlankHTML()
            bgQueue.async {
                fetch.updateHTML(blankHTML: blankHTML, url: url,
                            success: {htmlString in
                                DispatchQueue.main.async {
                                    self.webView?.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
                                    self.clickMeButton?.isHidden = true
                                }
                },
                            failure: {error in
                                print("clickMeClicked error: \(error.localizedDescription))")
                                DispatchQueue.main.async {
                                    self.displayAlert(title: error.localizedDescription)
                                }
                } )
            }
        }
        clickMeButton?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = Bundle.main.path(forResource: "ppTest", ofType: "html") {
            let frame = UIScreen.main.bounds
            let aWebView = WKWebView(frame: frame)
            aWebView.navigationDelegate = self

            let url = URL(fileURLWithPath: path)
            let request = URLRequest(url: url)
            aWebView.load(request)
            self.view.addSubview(aWebView)
            self.webView = aWebView
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
            button.center = aWebView.center
            button.backgroundColor = .black
            button.setTitle("Click Me", for: .normal)
            button.addTarget(self, action:#selector(self.clickMeClicked), for: .touchUpInside)
            self.view.addSubview(button)
            self.clickMeButton = button
        }
    }
    
    private func getBlankHTML() -> String {
        if let path = Bundle.main.path(forResource: "ppTest", ofType: "html") {
            let url = URL(fileURLWithPath: path)
            do {
                let str = try String(contentsOf: url, encoding: .utf8)
                return str
            }
            catch {
                print("Problem reading file")
                
            }
        }
        return ""
    }
}

extension ViewController {
    private func displayAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate{
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        completionHandler(.performDefaultHandling,nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
        decisionHandler(.allow)
    }
}

