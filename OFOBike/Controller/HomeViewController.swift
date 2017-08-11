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
    var searchAPI: AMapSearchAPI!
    
    var isSearchNearby = true
    
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
        
        setupSearchAPI()
    }
    
    // MARK: View
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

    private func setupMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.zoomLevel = 15
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
    }
    
    private func setupPanelView() {
        view.bringSubview(toFront: panelView)
    }
    
    // MARK: Logic
    private func setupSearchAPI() {
        searchAPI = AMapSearchAPI()
        searchAPI.delegate = self
    }
}

// MARK: Button actions
extension HomeViewController {
    @IBAction func clickLocateButton(_ sender: UIButton) {
        searchBikesNearby()
    }
}

// MARK: MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {
    
}

// MARK: AMapSearchDelegate
extension HomeViewController: AMapSearchDelegate {
    // POI 搜索完成后回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        // 保证周边有车
        guard response.count > 0 else { return }
        
        var annotations = [MAPointAnnotation]()
        annotations = response.pois.map {
            let annotation = MAPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude),
                                                           longitude: CLLocationDegrees($0.location.longitude))
            // 根据距离区分红包车/普通车
            if $0.distance < 200 {
                annotation.title = "红包区域内开锁任意小黄车"
                annotation.subtitle = "骑行 10 分钟可获得现金红包"
            } else {
                annotation.title = "正常可用"
            }
            return annotation
        }
        
        mapView.addAnnotations(annotations)
        
        if isSearchNearby {
            mapView.showAnnotations(annotations, animated: true)
            isSearchNearby = !isSearchNearby
        }
    }
}

// MARK: POI search
extension HomeViewController {
    // 搜索附近的小黄车
    func searchBikesNearby() {
        searchCustomLocation(mapView.userLocation.coordinate)
    }
    
    // 根据坐标（中心点）搜索
    func searchCustomLocation(_ center: CLLocationCoordinate2D) {
        // 附近 POI 搜索请求
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude),
                                                 longitude: CGFloat(center.longitude))
        request.keywords = "餐馆"
        request.radius = 500
        request.requireExtension = true
        
        searchAPI.aMapPOIAroundSearch(request)
    }
}
