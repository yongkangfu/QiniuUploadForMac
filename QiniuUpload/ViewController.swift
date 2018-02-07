//
//  ViewController.swift
//  QiniuUpload
//
//  Created by 符永康 on 31/01/2018.
//  Copyright © 2018 符永康. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var statusLable: NSTextField!
    @IBOutlet weak var selectBtn: NSPopUpButton!
    @IBOutlet weak var prefixTextField: NSTextFieldCell!
    @IBOutlet weak var resultField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    
    let path = Bundle.main.path(forResource: "qshell-darwin-x64", ofType: nil)!
    
    var pipe: Pipe!
    var task: Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prefixTextField.isSelectable = true
        
        let defaults = UserDefaults.standard
        let sk = defaults.object(forKey: "sk")
        let ak = defaults.object(forKey: "ak")
        
        if sk as! String != "" && ak as! String != "" {
            let arguments = ["-m", "account", ak as! String, sk as! String]
            // 注册
            let s = runCommand2(launchPath: path, arguments: arguments)
            if s == "" {
                self.statusLable.stringValue = "已连接"
            } else {
                self.statusLable.stringValue = s
            }
        } else {
            self.statusLable.stringValue = "设置签名参数"
        }
        
        // 获取所有的存储空间
        let result = runCommand2(launchPath: path, arguments: ["-m", "buckets"])
        let storageSpaces = result.split(separator: "\n")
        
        for ss in storageSpaces {
            self.selectBtn.addItem(withTitle: ss.description)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func browseClick(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canCreateDirectories = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: self.view.window!) { (result) in
            if result == NSApplication.ModalResponse.OK {
                let path = openPanel.url!.path
                var fileName = ""
                if self.prefixTextField.stringValue != "" {
                    fileName = self.prefixTextField.stringValue + (openPanel.url?.lastPathComponent)!
                } else {
                    fileName = (openPanel.url?.lastPathComponent)!
                }
                let ss = self.selectBtn.selectedItem!.title
                let arguments = ["-m", "rput", ss, fileName, path]
                DispatchQueue.global().async {
                    // 上传文件
                    self.runCommand(launchPath: self.path, arguments: arguments)
                }
            }
        }
    }
    
    /// 执行命令行
    /// - parameter launchPath: 命令行启动路径
    /// - parameter arguments: 命令行参数
    /// returns: 命令行执行结果
    func runCommand(launchPath: String, arguments: [String]) {
        
        self.task = Process()
        self.task.launchPath = launchPath
        self.task.arguments = arguments
    
        self.captureStandardOutput(self.task)
        
        self.task.launch()
        self.task.waitUntilExit()
    }
    
    func runCommand2(launchPath: String, arguments: [String]) -> String {
        let pice = Pipe()
        let file = pice.fileHandleForReading
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = pice
        task.launch()
    
        let data = file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8)!
    }
    
    func captureStandardOutput(_ task: Process) {

        self.pipe = Pipe()
        task.standardOutput = self.pipe
        self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: self.pipe.fileHandleForReading, queue: nil) {
            notification in
            
            let output = self.pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            if outputString != "" {
                DispatchQueue.main.async {
                    self.resultField.stringValue = outputString
                }
            }
            self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
}

