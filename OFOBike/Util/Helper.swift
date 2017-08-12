//
//  Helper.swift
//  OFOBike
//
//  Created by kingcos on 21/05/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import Foundation
import AVOSCloud

// MARK: Constants
let voiceBtnID = "voiceBtnID"

// MARK: Functions
func switchVoiceBtn(_ sender: UIButton) -> Bool {
    let result = UserDefaults.standard.bool(forKey: voiceBtnID)
    if result {
        sender.setImage(#imageLiteral(resourceName: "voiceopen"), for: .normal)
    } else {
        sender.setImage(#imageLiteral(resourceName: "voiceclose"), for: .normal)
    }
    
    return result
}
// MARK: Network utilities
struct NetworkUtil {
    
}

extension NetworkUtil {
    static func getPasscodeWith(_ code: String, completion: @escaping (String?) -> ()) {
        let query = AVQuery(className: "Code")
        
        query.whereKey("code", equalTo: code)
        query.getFirstObjectInBackground { code, error in
            if let error = error {
                print("getPasscodeWith - \(error)")
                completion(nil)
            }
            
            guard let code = code, let passcode = code["pass"] as? String else { return }
            completion(passcode)
        }
    }
}
