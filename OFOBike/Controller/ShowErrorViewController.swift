//
//  ShowErrorViewController.swift
//  OFOBike
//
//  Created by kingcos on 13/08/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import MIBlurPopup

class ShowErrorViewController: UIViewController {
    
    @IBOutlet weak var panelView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButtonClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func tapGestureTriggered(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}

// MARK: MIBlurPopupDelegate
extension ShowErrorViewController: MIBlurPopupDelegate {
    var popupView: UIView {
        return panelView
    }
    
    var blurEffectStyle: UIBlurEffectStyle {
        return .dark
    }
    
    var initialScaleAmmount: CGFloat {
        return 0.2
    }
    
    var animationDuration: TimeInterval {
        return 0.2
    }
}
