//
//  HomeViewController.swift
//  OFOBike
//
//  Created by kingcos on 11/08/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import SWRevealViewController
import FTIndicator

class HomeViewController: UIViewController {

    let annotationViewReuseId = "annotationViewReuseId"
    let centerAnnotationViewReuseId = "centerAnnotationViewReuseId"
    
    @IBOutlet weak var panelView: UIView!
    
    // Map related
    var mapView: MAMapView!
    var searchAPI: AMapSearchAPI!
    var centerPinAnnotation: CenterPinAnnotation!
    var pinView: MAAnnotationView!
    var walkManager: AMapNaviWalkManager!
    var startCoordinate, endCoordinate: CLLocationCoordinate2D!
    
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
        setupWalkManager()
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
    
    private func setupWalkManager() {
        walkManager = AMapNaviWalkManager()
        walkManager.delegate = self
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
    // 地图初始化完成
    func mapInitComplete(_ mapView: MAMapView!) {
        centerPinAnnotation = CenterPinAnnotation()
        centerPinAnnotation.coordinate = mapView.centerCoordinate
        centerPinAnnotation.lockedScreenPoint = CGPoint(x: view.bounds.width / 2.0,
                                                        y: view.bounds.height / 2.0)
        centerPinAnnotation.isLockedToScreen = true
        
        mapView.addAnnotation(centerPinAnnotation)
        mapView.showAnnotations([centerPinAnnotation], animated: true)
        
        searchBikesNearby()
    }
    
    // 设置图钉视图
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        // 保证非用户坐标点
        guard !(annotation is MAUserLocation) else { return nil }
        
        if annotation is CenterPinAnnotation {
            var centerAnnotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: centerAnnotationViewReuseId)
            if centerAnnotationView == nil {
                centerAnnotationView = MAPinAnnotationView(annotation: annotation,
                                                           reuseIdentifier: centerAnnotationViewReuseId)
            }
            centerAnnotationView?.image = UIImage(named: "homePage_wholeAnchor")
            centerAnnotationView?.canShowCallout = true
            
            pinView = centerAnnotationView
            return centerAnnotationView
        }
        
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
    
    // 用户移动地图后回调
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            centerPinAnnotation.isLockedToScreen = true
            centerPinAnimation()
            searchCustomLocation(mapView.centerCoordinate)
        }
    }
    
    // 添加标注视图完成后回调
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        guard let annotationViews = views as? [MAAnnotationView] else { return }
        
        for view in annotationViews {
            guard view.annotation is MAPointAnnotation else { continue }
            
            view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.3,
                           initialSpringVelocity: 0.0,
                           options: [],
                           animations: {
                            view.transform = .identity
            },
                           completion: nil)
        }
    }
    
    // 选中标注视图后回调
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        startCoordinate = centerPinAnnotation.coordinate
        endCoordinate = view.annotation.coordinate
        
        guard let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(startCoordinate.latitude),
                                                      longitude: CGFloat(startCoordinate.longitude)),
            let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(endCoordinate.latitude),
                                                  longitude: CGFloat(endCoordinate.longitude)) else {
                                                    return
        }
        
        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
}

// MARK: AMapNaviWalkManagerDelegate
extension HomeViewController: AMapNaviWalkManagerDelegate {
    // 计算路径
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = walkManager.naviRoute!.routeCoordinates!.map {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude),
                                          longitude: CLLocationDegrees($0.longitude))
        }
        
        let polyline = MAPolyline(coordinates: &coordinates,
                                  count: UInt(coordinates.count))
        mapView.add(polyline)
        
        let walkMinute = walkManager.naviRoute!.routeTime / 60
        
        var timeDesc = "1 分钟以内"
        if walkMinute > 0 {
            timeDesc = "\(walkMinute) 分钟"
        }
        
        let hintTitle = "步行 \(timeDesc)"
        let hintSubtitle = "距离 \(walkManager.naviRoute!.routeLength) 米"
        
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(with: #imageLiteral(resourceName: "clock"), title: hintTitle, message: hintSubtitle)
    }
    
    // 计算路径出现差错
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        print("onCalculateRouteFailure - \(error)")
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

// MARK: Other settings
extension HomeViewController {
    // 中心图钉动画
    func centerPinAnimation() {
        let endFrame = pinView.frame
        pinView.frame = endFrame.offsetBy(dx: 0, dy: -15)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        self.pinView.frame = endFrame
        },
                       completion: nil)
    }
}
