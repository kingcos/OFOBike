//
//  HomeViewController.swift
//  OFOBike
//
//  Created by kingcos on 11/08/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import SWRevealViewController

class HomeViewController: UIViewController {

    @IBOutlet weak var panelView: UIView!
    
    // Map related
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

}

// MARK: Setup
extension HomeViewController {
    fileprivate func setup() {
        setupNavigationItems()
        
        setupMapView()
        setupPanelView()
    }
    
    private func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "ofoLogo"))
        
        let leftImage = UIImage(named: "leftTopImage")?.withRenderingMode(.alwaysOriginal)
        let rightImage = UIImage(named: "rightTopImage")?.withRenderingMode(.alwaysOriginal)
        let backImage = UIImage(named: "backIndicator")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem?.image = leftImage
        navigationItem.rightBarButtonItem?.image = rightImage
        
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil, action: nil)
        
        // Setup reveal view controller
        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 340.0
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    private func setupPanelView() {
        view.bringSubview(toFront: panelView)
    }

    private func setupMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.zoomLevel = 15
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
    }
}

// MARK: Button actions
extension HomeViewController {
    @IBAction func clickLocateButton(_ sender: UIButton) {
        
    }
}

// MARK: MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {
    
}
