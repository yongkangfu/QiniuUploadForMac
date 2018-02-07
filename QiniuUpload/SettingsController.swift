//
//  SettingsController.swift
//  QiniuUpload
//
//  Created by 符永康 on 31/01/2018.
//  Copyright © 2018 符永康. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController {

    @IBOutlet weak var sk: NSTextFieldCell!
    @IBOutlet weak var ak: NSTextFieldCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let defaults = UserDefaults.standard
        
        if let sk = defaults.object(forKey: "sk") {
            self.sk.stringValue = sk as! String
        }
        
        if let ak = defaults.object(forKey: "ak") {
            self.ak.stringValue = ak as! String
        }
    }
 
    @IBAction func saveClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        let sk = self.sk.stringValue
        let ak = self.ak.stringValue
        
        defaults.set(sk, forKey: "sk")
        defaults.set(ak, forKey: "ak")
        defaults.synchronize()
        
        let alert = NSAlert()
        alert.messageText = "保存成功"
        alert.addButton(withTitle: "好")
        alert.alertStyle = NSAlert.Style.informational
        
        alert.runModal()
    }
}
