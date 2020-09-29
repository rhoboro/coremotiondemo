//
//  ViewController.swift
//  coremotiondemo
//
//  Created by rhoboro on 2020/09/28.
//  Copyright © 2020 rhoboro. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    
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
                self.startAccelerometer(interval: interval)
                self.button.setTitle("Stop", for: UIControl.State.normal)
            }
        }
    }
    
    func outputAccelData(accelation: CMAcceleration) {
        self.xLabel.text = String(format: "%06f", accelation.x)
        self.yLabel.text = String(format: "%06f", accelation.y)
        self.zLabel.text = String(format: "%06f", accelation.z)
    }
    
    func startAccelerometer(interval: Double) {
        motionManager.accelerometerUpdateInterval = interval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {
            (accelData: CMAccelerometerData?, errorOC: Error?) in self.outputAccelData(accelation: accelData!.acceleration)
        })
    }
    
    func stopAccelerometer() {
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
    }
}

