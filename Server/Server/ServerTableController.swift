//
//  ServerTableController.swift
//  Server
//
//  Created by Kleinsche on 2017/9/14.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

class ServerTableController: UITableViewController {
    var server: GCDAsyncSocket!
    let acceptPort: UInt16 = 8888
    
    ///存放客户端
    var dataArr: [ReadModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func leftBtnAction(_ sender: UIBarButtonItem) {
        startServer()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    @IBAction func rightAction(_ sender: UIBarButtonItem) {
        sendAction(sendType: .getLocation)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath)
        let readModel = dataArr[indexPath.row]
        cell.textLabel?.text = "IMEI:\(readModel.IMEI ?? "无"), 时间:\(readModel.readTime ?? 0) 经度:\(readModel.longitude ?? 0), 纬度\(readModel.latitude ?? 0)"
        
        return cell
    }
    
}

extension ServerTableController {
    
    ///开启服务端服务
    func startServer() {
        server = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global(qos: .default))
        do {
            try server.accept(onPort: acceptPort)
            print("开启服务端")
        } catch {
            print("服务端开启失败")
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    ///给所有连接状态的飞机发送指令
    func sendAction(sendType: SendType) {
        for arr in dataArr {
            switch sendType {
            case .getLocation:
                let model = SendModel(locationType: true)
                let data = try! JSONSerialization.data(withJSONObject: model.jsonDict, options: [])
                arr.client.write(data, withTimeout: -1, tag: 0)
            case .action:
                //建设中
                break
            }
        }
    }
    
}

extension ServerTableController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("\(newSocket.connectedHost ?? "") 新客户端连接")
        
//        for arr in dataArr {
//            if arr.client == newSocket {break}
//        }
        let model = ReadModel(client: newSocket)
        dataArr.append(model)
        OperationQueue.main.addOperation {
            self.tableView.insertRows(at: [IndexPath(row: self.dataArr.count - 1, section: 0)], with: .none)
        }
        //监听
        newSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        var index = 0
        for arr in dataArr {
            if arr.client.isConnected == true {
                index += 1
                continue
            }
            //移除断开连接的客户端
            OperationQueue.main.addOperation {
                self.dataArr.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                return
            }
        }
        /*有客户端断开连接执行操作*/
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("收到客户端消息")
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            sock.readData(withTimeout: -1, tag: 0)
            return
        }
        
        let jsonDict = json as! [String: Any]
        let readModel = ReadModel(client: sock, dict: jsonDict)
        
        //根据收到消息类型执行操作
        switch readModel.type {
        case .getLocation:
            var index = 0
            for arr in dataArr {
                if arr.client != sock {
                    index += 1
                    continue}
                    dataArr[index] = readModel
                    OperationQueue.main.addOperation {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        index += 1
                    }
            }
        
        case .actionFinish:
            print("动作完成")
        default:
            sock.readData(withTimeout: -1, tag: 0)
            break
        }
        
        //监听
        sock.readData(withTimeout: -1, tag: 0)
    }
    
}
