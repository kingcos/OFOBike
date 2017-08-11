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

    let activityURLString = "http://m.ofo.so/active.html"
    
    var wkWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

}

// MARK: Setup
extension ActivityViewController {
    fileprivate func setupUI() {
        title = "热门活动"

        addWKWebView()
    }

    fileprivate func addWKWebView() {
        wkWebView = WKWebView(frame: view.frame)

        guard let url = URL(string: activityURLString) else { return }
        let request = URLRequest(url: url)

        wkWebView.load(request)
        view.addSubview(wkWebView)
    }
}
