//
//  ShowPasscodeViewController.swift
//  OFOBike
//
//  Created by kingcos on 21/05/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import SwiftyTimer
import SwiftySound
import AVFoundation

class ShowPasscodeViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var bikeNumberLabel: UILabel!
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    
    @IBOutlet weak var passcodeLabel1: PreviewLabel!
    @IBOutlet weak var passcodeLabel2: PreviewLabel!
    @IBOutlet weak var passcodeLabel3: PreviewLabel!
    @IBOutlet weak var passcodeLabel4: PreviewLabel!
    
    var isTorchOn = false
    var isVoiceOn = true
    var remindTime = 121
    var bikeCode = "" {
        didSet {
            bikeNumberLabel.text = "车牌号 \(bikeCode) 的解锁码为"
        }
    }
    var bikePasscodeArray: [String] = [] {
        didSet {
            passcodeLabel1.text = bikePasscodeArray[0]
            passcodeLabel2.text = bikePasscodeArray[1]
            passcodeLabel3.text = bikePasscodeArray[2]
            passcodeLabel4.text = bikePasscodeArray[3]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: Setup
extension ShowPasscodeViewController {
    fileprivate func setup() {
        setupTimer()
        
        isVoiceOn = switchVoiceBtn(voiceButton)

        setupSounds()
    }
    
    private func setupTimer() {
        Timer.every(1) { (timer: Timer) in
            self.remindTime -= 1
            self.countDownLabel.text = self.remindTime.description
            
            if self.remindTime == 0 {
                timer.invalidate()
            }
        }
    }
    
    private func setupSounds() {
        if isVoiceOn {
            Sound.play(file: "骑行结束_LH.m4a")
        }
    }
}

// MARK: Button actions
extension ShowPasscodeViewController {
    @IBAction func reportBike(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func switchTorch(_ sender: UIButton) {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch && device.isTorchAvailable {
            try? device.lockForConfiguration()
            
            if device.torchMode == .off {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        }
        
        isTorchOn = !isTorchOn
        
        if isTorchOn {
            sender.setImage(#imageLiteral(resourceName: "btn_enableTorch"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "btn_unenableTorch"), for: .normal)
        }
    }
    
    @IBAction func switchVoice(_ sender: UIButton) {
        isVoiceOn = !isVoiceOn
        
        if isVoiceOn {
            sender.setImage(#imageLiteral(resourceName: "voiceopen"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "voiceclose"), for: .normal)
        }
        
        defaults.set(isVoiceOn, forKey: voiceBtnID)
    }
}
