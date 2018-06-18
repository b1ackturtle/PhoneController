//
//  MotionStream.swift
//  PhoneController
//
//  Created by 小島 一穂 on 2018/05/19.
//  Copyright © 2018年 Ichiho OJIMA. All rights reserved.
//

import UIKit
import CoreMotion

protocol MotionStreamDelegate {
    func attitudePacketSend(_ roll: Double, _ pitch: Double, _ yaw: Double)
}

class MotionStream: NSObject {

    var delegate: MotionStreamDelegate?
    
    var motionManager: CMMotionManager!
    
    override init() {
        super.init()
        
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.1
    }
    
    func motionHandler(deviceManager: CMDeviceMotion!, error: Error!) {
        let attitude = deviceManager.attitude
        
        delegate?.attitudePacketSend(attitude.roll, attitude.pitch, attitude.yaw)
    }
    
    func start() {
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: motionHandler)
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
