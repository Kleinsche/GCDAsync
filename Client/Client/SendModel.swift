//
//  SendModel.swift
//  Client
//
//  Created by Kleinsche on 2017/9/14.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

enum sendType {
    case sendLocation
    case actionFinish
}

class SendModel: NSObject {

    var jsonDict: [String: Any] = [:]
    
    ///发送位置
    init(IMEI: String, longitude: CGFloat, latitude: CGFloat, attributes: [String: Any]?) {
        jsonDict = [
            "type": "getLocation",
            "IMEI": IMEI,
            "longitude": longitude,
            "latitude": latitude,
            "attributes": attributes ?? ""
        ]
    }
    
    ///发送任务完成状态
    init(actionFinish: Bool? = true, IMEI: String) {
        jsonDict = [
            "type":"actionFinish",
            "IMEI": IMEI
        ]
    }
    
}
