//
//  SendModel.swift
//  Server
//
//  Created by Kleinsche on 2017/9/13.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

enum SendType {
    case getLocation
    case action
}

class SendModel: NSObject {
    ///模型转字典
    var jsonDict: [String: Any] = [:]
    
    ///发送获取飞机位置指令
    init(locationType: Bool? = true) {
        jsonDict = [
            "type": "getLocation",
            "time": Date().timeIntervalSince1970
        ]
    }
    
    ///发送指令
    init(runToCoordinates: [CGPoint]) {
        var points: [[CGFloat]] = []
        for coordinate in runToCoordinates {
            let point: [CGFloat] = [coordinate.x,coordinate.y]
            points.append(point)
        }
        jsonDict = [
            "type": "action",
            "time": Date().timeIntervalSince1970,
            "actionName": "runToAction",
            "coordinates": points
        ]
    }
    
}
