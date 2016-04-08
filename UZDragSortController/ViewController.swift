//
//  ViewController.swift
//  UZDragSortController
//
//  Created by 杨弘宇 on 16/4/8.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    var sampleData: [Int] = {
        var arr = [Int]()
        for i in 0..<50 {
            arr.append(i)
        }
        return arr
    }()
    
    var dragSortController: UZDragSortController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let itemWidth = (self.collectionView?.frame.width)! / 3.0 - 10
        
        (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        self.dragSortController = UZDragSortController()
        self.dragSortController?.collectionView = self.collectionView
        self.dragSortController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sampleData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        (cell.viewWithTag(1) as! UILabel).text = "Item \(self.sampleData[indexPath.item])"
        
        return cell
    }
    
}


extension ViewController: UZDragSortControllerDelegate {
    
    func dragSortController(controller: UZDragSortController, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func dragSortController(controller: UZDragSortController, moveItemFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) -> Bool {
        let temp = self.sampleData[fromIndexPath.item]
        self.sampleData[fromIndexPath.item] = self.sampleData[toIndexPath.item]
        self.sampleData[toIndexPath.item] = temp
        return true
    }
    
}

