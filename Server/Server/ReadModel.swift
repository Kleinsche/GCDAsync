//
//  ReadModel.swift
//  Server
//
//  Created by Kleinsche on 2017/9/13.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

enum ReadType {
    case none
    ///获取坐标
    case getLocation
    ///动作结束
    case actionFinish
}

class ReadModel: NSObject {
    
    init(client: GCDAsyncSocket) {
        self.client = client
    }

    ///解析字典
    init(client:GCDAsyncSocket, dict: [String: Any]) {
        self.client = client
        readTime = Date().timeIntervalSince1970
        switch dict["type"] as! String {
        case "getLocation":
            type = .getLocation
            IMEI = dict["IMEI"] as? String
            longitude = dict["longitude"] as? CGFloat
            latitude = dict["latitude"] as? CGFloat
            attributes = dict["attributes"] as? [String: Any]
        case "actionFinish":
            type = .actionFinish
            IMEI = dict["IMEI"] as? String
        default:
            break
        }
        
    }
    
    ///客户端socket
    var client: GCDAsyncSocket!
    
    ///消息类型
    var type: ReadType = .none
    ///接收时间
    var readTime: TimeInterval?
    ///机型编码
    var IMEI: String?
    
    /*以下接收位置消息使用*/
    ///经度
    var longitude: CGFloat?
    ///纬度
    var latitude: CGFloat?
    ///附加属性
    var attributes: [String: Any]?
    
}
