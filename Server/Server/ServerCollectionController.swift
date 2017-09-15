//
//  ServerCollectionController.swift
//  Server
//
//  Created by Kleinsche on 2017/9/15.
//  Copyright © 2017年 Kleinsche. All rights reserved.
//

import UIKit

class ServerCollectionController: UICollectionViewController {
    
    var dataArr: [ReadModel] = []
    
    override var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width :(self.view.frame.size.width-30)/4 , height:200)
        layout.sectionInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        return layout
    }
    


    
}
