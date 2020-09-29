//
//  ViewController.swift
//  coremotiondemo
//
//  Created by rhoboro on 2020/09/28.
//  Copyright © 2020 rhoboro. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation


class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    var data: [AccelData] = []
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var intervalField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func tapped(_ sender: Any) {
        let interval = Double(self.intervalField.text!)
        if self.motionManager.isAccelerometerAvailable, let interval = interval {
            if (self.motionManager.isAccelerometerActive) {
                self.stopAccelerometer()
                self.button.setTitle("Start", for: UIControl.State.normal)
            } else {
                self.data = []
                self.startAccelerometer(interval: interval)
                self.button.setTitle("Stop", for: UIControl.State.normal)
            }
        }
    }
    
    func outputAccelData(accelationData: CMAccelerometerData?) {
        if let accelationData = accelationData {
            let acceleration = accelationData.acceleration
            self.xLabel.text = String(format: "%06f", acceleration.x)
            self.yLabel.text = String(format: "%06f", acceleration.y)
            self.zLabel.text = String(format: "%06f", acceleration.z)
            // timestampはデバイス起動時からの秒数
            self.data.append(AccelData(timestamp: accelationData.timestamp, x: acceleration.x, y: acceleration.y, z: acceleration.z))
        }
    }
    
    func startAccelerometer(interval: Double) {
        motionManager.accelerometerUpdateInterval = interval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {
            (accelData: CMAccelerometerData?, errorOC: Error?) in self.outputAccelData(accelationData: accelData)
        })
    }
    
    func stopAccelerometer() {
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
            self.saveToCSV()
        }
    }
    
    func saveToCSV() {
        let unixtime: Int = Int(Date().timeIntervalSince1970)
        let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let filename = "\(unixtime).csv"
        do {
            try "timestamp_from_booted,acceleration_x,acceleration_y,acceleration_z".appendLineToURL(fileURL: dir.appendingPathComponent(filename))
            for rowData in self.data {
                let row = String(format: "\(rowData.timestamp),%06f,%06f,%06f", rowData.x, rowData.y, rowData.z)
                try row.appendLineToURL(fileURL: dir.appendingPathComponent(filename))
            }
        } catch {
            
        }
        self.showAlert(filename: filename)
    }
    
    func showAlert(filename: String) {
        let alert = UIAlertController(title: title, message: "下記に保存しました\r\n\(filename)", preferredStyle: UIAlertController.Style.alert)
        let okayButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okayButton)
        present(alert, animated: true, completion: nil)
    }
}

struct AccelData {
    var timestamp: TimeInterval
    var x: Double
    var y: Double
    var z: Double
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
