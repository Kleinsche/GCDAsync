//
//  ReadModel.swift
//  Client
//
//  Created by Kleinsche on 2017/9/14.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

enum ReadType {
    case none
    case getLocation
    case action
}

enum ActionType {
    case none
    case runToAction
}

class ReadModel: NSObject {
    
    ///消息接收时间
    var time: TimeInterval!
    ///收到消息的类型
    var type: ReadType = .none
    
    /*收到动作指令可用*/
    ///动作类型
    var actionType: ActionType = .none
    ///坐标集
    var coordinates: [CGPoint] = []
    
    ///传入字典
    init(dict: [String: Any]) {
        time = dict["time"] as! TimeInterval
        switch dict["type"] as! String {
        case "getLocation":
            type = .getLocation
        case "action":
            type = .action
            let actionName = dict["actionName"] as! String
            
            switch actionName {
            case "runToAction":
                actionType = .runToAction
                var cgPoint: [CGPoint] = []
                let points = dict["coordinates"] as! [[CGFloat]]
                for point in points {
                    cgPoint.append(CGPoint(x: point[0], y: point[1]))
                }
                coordinates = cgPoint
            default:
                break
            }
            
        default:
            break
        }
    }

}
