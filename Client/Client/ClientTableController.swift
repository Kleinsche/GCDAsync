//
//  ClientTableController.swift
//  Client
//
//  Created by Kleinsche on 2017/9/14.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

var client: GCDAsyncSocket!
let host: String = "192.168.31.232"
let port: UInt16 = 8888
var isConnected: Bool = false
///飞机编码
let IMEI: String = "这是模拟器"

class ClientTableController: UITableViewController {
    
    ///UITableView数据
    var dataArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "连接", style: .plain, target: self, action: #selector(leftBtnAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "建设中", style: .plain, target: self, action: #selector(rightBtnAction(_:)))

    }

    @objc func leftBtnAction(_ sender: UIBarButtonItem) {
        if isConnected {
            client.disconnect()
        }else{
        connectToHost()
        }
    }
    
    @objc func rightBtnAction(_ sender: UIBarButtonItem) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        cell.textLabel?.text = dataArr[indexPath.row]
        return cell
    }
    
}

//MARK: - 方法
extension ClientTableController {
    ///连接服务器
    func connectToHost() {
        client = GCDAsyncSocket()
        //取消自动关闭读取流
        client.autoDisconnectOnClosedReadStream = false
        client.delegate = self
        client.delegateQueue = DispatchQueue.global(qos: .default)
        do {
            try client.connect(toHost: host, onPort: port)
        } catch {
            print("连接服务器失败")
        }
    }
    
    //发送位置信息
    func sendLocation() {
        let model = SendModel(IMEI: IMEI, longitude: 10, latitude: 10, attributes: nil)
        let data = try! JSONSerialization.data(withJSONObject: model.jsonDict, options: [])
        //3秒超时取消
        client.write(data, withTimeout: 3, tag: 1)
    }
    
    ///发送任务完成指令
    func sendActionFinish() {
        let model = SendModel(actionFinish: true, IMEI: IMEI)
        let data = try! JSONSerialization.data(withJSONObject: model.jsonDict, options: [])
        client.write(data, withTimeout: -1, tag: 100)
    }
    
    ///执行运动指令
    func runAction() {
        
    }
    
}

//MARK: - GCDAsyncSocketDelegate
extension ClientTableController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("连接 \(host):\(port) 成功")
        isConnected = true
        OperationQueue.main.addOperation {
            self.navigationItem.leftBarButtonItem?.title = "断开"
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        }
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("断开连接")
        isConnected = false
        OperationQueue.main.addOperation {
            self.navigationItem.leftBarButtonItem?.title = "连接"
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blue
        }
        /*执行返回命令*/
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("收到服务端消息")
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            sock.readData(withTimeout: -1, tag: 0)
            return
        }
        
        let jsonDict = json as! [String: Any]
        let readModel = ReadModel(dict: jsonDict)
        
        switch readModel.type {
        case .getLocation:
            sendLocation()
        case .action:
            runAction()
        default:
            sock.readData(withTimeout: -1, tag: 0)
            break
        }
        
        sock.readData(withTimeout: -1, tag: 0)
    }
    
}


