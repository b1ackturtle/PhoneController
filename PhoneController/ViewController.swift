//
//  ViewController.swift
//  PhoneController
//
//  Created by 小島 一穂 on 2018/05/19.
//  Copyright © 2018年 Ichiho OJIMA. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    @IBOutlet weak var isConnectButton: UIButton!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    var statusFlag: Bool = false
    var canStartPinging = false
    
    var controlType: Bool = false
    
    var client: UDPClient?
    var motionStream = MotionStream()
    var cl: UDPClient?
    
    let imageCircle: [UIImageView] = [UIImageView(), UIImageView()]
    var touchX: [CGFloat] = [0, 0]
    var touchY: [CGFloat] = [0, 0]
    var posX: [CGFloat] = [0, 0]
    var posY: [CGFloat] = [0, 0]
    
    let radius: CGFloat = 50
    
    var fingerNum: Int = 0
    var refRightLeft: [Int] = [0, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isMultipleTouchEnabled = true
        
        for i in 0..<2 {
            imageCircle[i].image = UIImage(named: "./circle.png")
            imageCircle[i].frame = CGRect(x: 0, y: 0, width: 128, height: 128)
        
            imageCircle[i].center = CGPoint(x: touchX[i], y: touchY[i])
        
            imageCircle[i].isUserInteractionEnabled = true
            imageCircle[i].isHidden = true
            self.view.addSubview(imageCircle[i])
        }
        
        isConnectButton.setTitle("Connect", for: .normal)
        
        motionStream.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerNum = (event?.allTouches?.count)!
        
        if fingerNum > 2 {
            for i in 0..<2 {
                imageCircle[i].center = CGPoint(x: 0, y: 0)
                touchX[i] = 0
                touchY[i] = 0
                imageCircle[i].isHidden = true
            }
            refRightLeft = [0, 1]
            return
        }
        
        if let allTouches = event?.allTouches {
            var cnt = 0
            for touch in allTouches {
                if cnt >= 2 {
                    break
                }
                
                if imageCircle[cnt].isHidden == false {
                    let x = touch.location(in: self.view).x
                    let y = touch.location(in: self.view).y
                    let r = sqrt((posX[cnt] - x) * (posX[cnt] - x) + (posY[cnt] - y) * (posY[cnt] - y))
                    cnt += 1
                    if r <= radius {
                        continue
                    }
                    refRightLeft.swapAt(0, 1)
                }
                imageCircle[cnt].isHidden = false
                touchX[cnt] = touch.location(in: self.view).x
                touchY[cnt] = touch.location(in: self.view).y
                posX[cnt] = touchX[cnt]
                posY[cnt] = touchY[cnt]
                imageCircle[cnt].center = CGPoint(x: touchX[cnt], y: touchY[cnt])
                
                cnt += 1
            }
        }
        
        /*
        if fingerNum == 1 {
            let touchEvent = event!.allTouches!.first!
        
            imageCircle[0].isHidden = false
            touchX[0] = touchEvent.location(in: self.view).x
            touchY[0] = touchEvent.location(in: self.view).y
            imageCircle[0].center = CGPoint(x: touchX[0], y: touchY[0])
        }
        else if fingerNum >= 2 {
            var cnt = 0
            if let allTouches = event?.allTouches {
                for touch in allTouches {
                    if cnt >= 2 {
                        break
                    }
                    
                    imageCircle[cnt].isHidden = false
                    touchX[cnt] = touch.location(in: self.view).x
                    touchY[cnt] = touch.location(in: self.view).y
                    imageCircle[cnt].center = CGPoint(x: touchX[cnt], y: touchY[cnt])
                    cnt += 1
                }
            }
        }
        */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fingerNum > 2 {
            return
        }
        
        if let allTouches = event?.allTouches {
            var cnt = 0
            for touch in allTouches {
                if cnt >= 2 {
                    break
                }
                var nx = touch.location(in: self.view).x
                var ny = touch.location(in: self.view).y
                
                let i = refRightLeft[cnt]
                
                posX[i] = nx
                posY[i] = ny
                
                let currentRadius = sqrt((nx - touchX[i]) * (nx - touchX[i]) + (ny - touchY[i]) * (ny - touchY[i]))
                
                if currentRadius > radius {
                    let radian = atan2((ny - touchY[i]), (nx - touchX[i]))
                    nx = touchX[i] + (radius * cos(radian))
                    ny = touchY[i] + (radius * sin(radian))
                }
                
                imageCircle[i].center = CGPoint(x: nx, y: ny)
                
                self.view.addSubview(imageCircle[i])
                
                cnt += 1
            }
        }
        /*
        if fingerNum == 1 {
            let touchEvent = touches.first!
        
            let newDx = touchEvent.location(in: self.view).x
            let newDy = touchEvent.location(in: self.view).y

            var nx = newDx
            var ny = newDy
        
            let currentRadius = sqrt((nx - touchX[0]) * (nx - touchX[0]) + (ny - touchY[0]) * (ny - touchY[0]))

            if currentRadius > radius {
                let radian = atan2((ny - touchY[0]), (nx - touchX[0]))
                nx = touchX[0] + (radius * cos(radian))
                ny = touchY[0] + (radius * sin(radian))
            }

            imageCircle[0].center = CGPoint(x: nx, y: ny)
        
            self.view.addSubview(imageCircle[0])
        }
        else if fingerNum >= 2 {
            var cnt = 0
            if let allTouches = event?.allTouches {
                for touch in allTouches {
                    if cnt >= 2 {
                        break
                    }
                    let newDx = touch.location(in: self.view).x
                    let newDy = touch.location(in: self.view).y

                    var nx = newDx
                    var ny = newDy
                    
                    let currentRadius = sqrt((nx - touchX[cnt]) * (nx - touchX[cnt]) + (ny - touchY[cnt]) * (ny - touchY[cnt]))
                    
                    if currentRadius > radius {
                        let radian = atan2((ny - touchY[cnt]), (nx - touchX[cnt]))
                        nx = touchX[cnt] + (radius * cos(radian))
                        ny = touchY[cnt] + (radius * sin(radian))
                    }
                    
                    imageCircle[cnt].center = CGPoint(x: nx, y: ny)
                    
                    self.view.addSubview(imageCircle[cnt])
                    
                    cnt += 1
                }
            }
        }
        */
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fingerNum == 2 && touches.count == 1 {
            let x = touches.first!.location(in: self.view).x
            let y = touches.first!.location(in: self.view).y
            print(posX[0], posY[0], posX[1], posY[1], x, y)
            if sqrt((posX[1] - x) * (posX[1] - x) + (posY[1] - y) * (posY[1] - y)) < sqrt((posX[0] - x) * (posX[0] - x) + (posY[0] - y) * (posY[0] - y)) {
                imageCircle[1].center = CGPoint(x: 0, y: 0)
                touchX[1] = 0
                touchY[1] = 0
                imageCircle[1].isHidden = true
            } else {
                imageCircle[0].center = imageCircle[1].center
                touchX[0] = touchX[1]
                touchY[0] = touchY[1]
                imageCircle[0].isHidden = imageCircle[1].isHidden
                imageCircle[1].center = CGPoint(x: 0, y: 0)
                touchX[1] = 0
                touchY[1] = 0
                imageCircle[1].isHidden = true
            }
            fingerNum = 1
        } else {
            for i in 0..<2 {
                imageCircle[i].center = CGPoint(x: 0, y: 0)
                touchX[i] = 0
                touchY[i] = 0
                imageCircle[i].isHidden = true
            }
        }
        refRightLeft = [0, 1]
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if isConnectButton.titleLabel?.text == "Connect" {
            guard let ipAddr = findConnectableAddress() else {
                return
            }
          
            isConnectButton.setTitle("Disconnect", for: .normal)
            
            client = UDPClient(address: ipAddr, port: 10101)
            let data: Data = "0 0 0".data(using: .utf8)!
            let _ = client?.send(data: data)
            
            motionStream.start()
        } else {
            let data: Data = "0 0 0".data(using: .utf8)!
            let _ = client?.send(data: data)
            
            isConnectButton.setTitle("Connect", for: .normal)
            
            client?.close()
            
            motionStream.stop()
        }
    }
    
    @IBAction func typeChanged(_ sender: Any) {
        if typeSegmentedControl.selectedSegmentIndex == 0 {
            print("sensor")
            controlType = false
        } else {
            print("joystick")
            controlType = true
        }
    }
    
    func findConnectableAddress() -> String? {
        var address : String?
        
        guard let myAddr = getWiFiAddress() else { return nil }
        
        let array = myAddr.split(separator: ".")
        let baseAddr = array[0] + "." + array[1] + "." + array[2]
        
        for i in 1..<256 {
            let addr = baseAddr + ".\(i)"

            cl = UDPClient(address: addr, port: 10101)
            let data: Data = myAddr.data(using: .utf8)!
            let _ = cl?.send(data: data)
            cl?.close()
            let srv = UDPServer(address: myAddr, port: 10101)
            let ret = srv.recv(1024)
            srv.close()
            if ret.1 != "0.0.0.0" {
                let str = Data(bytes: ret.0!)
                if String(data: str, encoding: .utf8) == "HELLO" {
                    print(ret)
                    address = ret.1
                    break
                }
            }
        }
        
        return address
    }

    func getWiFiAddress() -> String? {
        var address : String?
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                let name = String(cString: interface.ifa_name)
                if  name == "bridge100" || name == "en0" {
                    print(name)
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                    if address != nil {
                        break
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }

}

extension ViewController: MotionStreamDelegate {
    
    func attitudePacketSend(_ roll: Double, _ pitch: Double, _ yaw: Double) {
        var str = ""
        if !controlType {
            print(roll, pitch, yaw)
            str = String(roll) + " " + String(pitch) + " " + String(yaw)
        }
        else if fingerNum == 1 {
            print(-(imageCircle[0].center.y - touchY[0]) / radius, (imageCircle[0].center.x - touchX[0]) / radius)
            str = String(Double(-(imageCircle[0].center.y - touchY[0]) / radius)) + " " +
                String(Double((imageCircle[0].center.x - touchX[0]) / radius)) + " 0"
        }
        else if fingerNum == 2 {
            print(-(imageCircle[0].center.y - touchY[0]) / radius, (imageCircle[1].center.x - touchX[1]) / radius)
            str = String(Double(-(imageCircle[0].center.y - touchY[0]) / radius)) + " " + String(Double((imageCircle[1].center.x - touchX[1]) / radius)) + " 0"
        }
        else {
            print("0 0 0")
            str = "0 0 0"
        }
        let data: Data = str.data(using: .utf8)!
        let _ = client?.send(data: data)
    }
    
}
