//
//  Helper.swift
//  OFOBike
//
//  Created by kingcos on 21/05/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import Foundation

let voiceBtnID = "voiceBtnID"

func switchVoiceBtn(_ sender: UIButton) -> Bool {
    let result = UserDefaults.standard.bool(forKey: voiceBtnID)
    if result {
        sender.setImage(#imageLiteral(resourceName: "voiceopen"), for: .normal)
    } else {
        sender.setImage(#imageLiteral(resourceName: "voiceclose"), for: .normal)
    }
    
    return result
}
