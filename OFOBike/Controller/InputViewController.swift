//
//  InputViewController.swift
//  OFOBike
//
//  Created by kingcos on 16/05/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import APNumberPad
import AVFoundation

class InputViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    var isTorchOn = false
    var isVoiceOn = true
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var pannelView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var voiceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isVoiceOn = switchVoiceBtn(voiceButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPasscode" {
            let controller = segue.destination as? ShowPasscodeViewController
            
            NetworkUtil.getPasscodeWith(inputTextField.text ?? "") { passcode in
                controller?.bikeCode = self.inputTextField.text ?? ""
                controller?.bikePasscodeArray = passcode.characters.map { $0.description }
            }
        }
    }
}

// MARK: Setup UI
extension InputViewController {
    fileprivate func setupUI() {
        setupOthers()
        setupPannelView()
        setupInputTextField()
        setupDescLabel()
    }
    
    fileprivate func setupOthers() {
        title = "车辆解锁"
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫码用车",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(backToScan))
        let numberPad = APNumberPad(delegate: self)
        numberPad.leftFunctionButton.setTitle("确定", for: .normal)
        inputTextField.inputView = numberPad
        submitButton.isEnabled = false
    }
    
    private func setupPannelView() {
        pannelView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        pannelView.layer.shadowRadius = 3.0
        pannelView.layer.shadowOpacity = 0.5
    }
    
    private func setupInputTextField() {
        inputTextField.layer.borderColor = UIColor.ofoYellow.cgColor
        inputTextField.layer.borderWidth = 2.0
    }
    
    private func setupDescLabel() {
        descLabel.layer.cornerRadius = 2.0
        descLabel.layer.masksToBounds = true
    }
    
    @objc private func backToScan() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Button actions
extension InputViewController {
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

// APNumberPadDelegate & UITextFieldDelegate
extension InputViewController: APNumberPadDelegate, UITextFieldDelegate {
    func numberPad(_ numberPad: APNumberPad,
                   functionButtonAction functionButton: UIButton,
                   textInput: UIResponder) {
        guard let text = inputTextField.text else { return }
        if !text.isEmpty {
            performSegue(withIdentifier: "showPasscode", sender: self)
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        if newLength > 0 {
            submitButton.setImage(#imageLiteral(resourceName: "nextArrow_enable"), for: .normal)
            submitButton.backgroundColor = UIColor.ofoYellow
            submitButton.isEnabled = true
        } else {
            submitButton.setImage(#imageLiteral(resourceName: "nextArrow_unenable"), for: .normal)
            submitButton.backgroundColor = UIColor.groupTableViewBackground
            submitButton.isEnabled = false
        }
        
        return newLength <= 8
    }
}
