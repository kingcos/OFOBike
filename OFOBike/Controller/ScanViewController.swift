//
//  ScanViewController.swift
//  OFOBike
//
//  Created by kingcos on 14/05/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import swiftScan
import FTIndicator

class ScanViewController: LBXScanViewController {

    var isFlashOn = false
    
    @IBOutlet weak var panelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.bringSubview(toFront: panelView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let result = arrayResult.first {
            let msg = result.strScanned
            
            FTIndicator.setIndicatorStyle(.dark)
            FTIndicator.showToastMessage(msg)
        }
    }
}

// MARK: Setup
extension ScanViewController {func setup() {
        title = "扫码用车"
        var style = LBXScanViewStyle()
        style.anmiationStyle = .NetGrid
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        scanStyle = style
    }
}

// MARK: Button actions
extension ScanViewController {
    @IBAction func switchFlash(_ sender: UIButton) {
        isFlashOn = !isFlashOn
        scanObj?.changeTorch()
        
        if isFlashOn {
            sender.setImage(#imageLiteral(resourceName: "btn_enableTorch_w"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "btn_unenableTorch_w"), for: .normal)
        }
    }
}
