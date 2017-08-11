//
//  ActivityViewController.swift
//  OFOBike
//
//  Created by kingcos on 29/04/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import WebKit

class ActivityViewController: UIViewController {

    let activeURL = "http://m.ofo.so/active.html"
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

}

extension ActivityViewController {
    fileprivate func setupUI() {
        title = "热门活动"

        addWebView()
    }

    fileprivate func addWebView() {
        webView = WKWebView(frame: view.frame)

        guard let url = URL(string: activeURL) else { return }
        let request = URLRequest(url: url)

        webView.load(request)
        view.addSubview(webView)
    }
}
