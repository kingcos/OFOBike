//
//  HomeViewController.swift
//  OFOBike
//
//  Created by kingcos on 11/08/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

}

// MARK: Setup
extension HomeViewController {
    fileprivate func setup() {
        setupNavigationItems()
    }
    
    private func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "ofoLogo"))
        
        let leftImage = UIImage(named: "leftTopImage")?.withRenderingMode(.alwaysOriginal)
        let rightImage = UIImage(named: "rightTopImage")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem?.image = leftImage
        navigationItem.rightBarButtonItem?.image = rightImage
//        }
    }
}
