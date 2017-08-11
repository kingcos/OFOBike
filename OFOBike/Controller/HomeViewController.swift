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

    let annotationViewReuseId = "annotationViewReuseId"
    let centerAnnotationViewReuseId = "centerAnnotationViewReuseId"
    
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
        // 导航栏中间
        navigationItem.titleView = UIImageView(image: UIImage(named: "ofoLogo"))
        
        // 导航栏左右
        let leftImage = UIImage(named: "leftTopImage")?.withRenderingMode(.alwaysOriginal)
        let rightImage = UIImage(named: "rightTopImage")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem?.image = leftImage
        navigationItem.rightBarButtonItem?.image = rightImage
        
        // 全局导航后退
        let backImage = UIImage(named: "backIndicator")?.withRenderingMode(.alwaysOriginal)
        
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // 侧边栏
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
    // 设置图钉
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        // 保证非用户坐标点
        guard !(annotation is MAUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseId)
            as? MAPinAnnotationView
        
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseId)
        }
        
        // 判断是否红包车
        if annotation.title == "正常可用" {
            annotationView?.image = UIImage(named: "HomePage_nearbyBike")
        } else {
            annotationView?.image = UIImage(named: "HomePage_nearbyBikeRedPacket")
        }
        
        // 显示气泡
        annotationView?.canShowCallout = true
        // 下落动画
        annotationView?.animatesDrop = true
        
        return annotationView
    }
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
