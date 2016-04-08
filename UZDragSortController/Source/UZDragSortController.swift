//
//  UZDragSortController.swift
//  UZDragSortController
//
//  Created by 杨弘宇 on 16/4/8.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

@objc protocol UZDragSortControllerDelegate: NSObjectProtocol {
    
    func dragSortController(controller: UZDragSortController, moveItemFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) -> Bool
    
    func dragSortController(controller: UZDragSortController, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    
    optional func dragSortController(controller: UZDragSortController, didBeginDragItemAtIndexPath indexPath: NSIndexPath)
    
    optional func dragSortController(controller: UZDragSortController, didEndDragItemAtFinalIndexPath indexPath: NSIndexPath)
    
}


class UZDragSortController: NSObject {

    var collectionView: UICollectionView? {
        set(newValue) {
            self.uninstall()
            self._collectionView = newValue
            self.install()
        }
        
        get {
            return self._collectionView
        }
    }
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer? {
        return self._longPressGestureRecognizer
    }
    
    weak var delegate: UZDragSortControllerDelegate?
    
    private var containerView: UIView {
        return (self.collectionView?.superview)!
    }
    
    // The velocity of auto scrolling.
    var scrollVelocity: CGFloat = 10
    
    // General animation duration.
    var animationDuration: NSTimeInterval = 0.2
    
    // The opacity of snapshot view while dragging.
    var snapshotOpacity: CGFloat = 0.75
    
    // The scale of snapshot view while dragging.
    var snapshotScale: CGFloat = 1.2
    
    private var _collectionView: UICollectionView?
    private var _longPressGestureRecognizer: UILongPressGestureRecognizer?
    private var snapshotView: UIImageView?
    private var currentIndexPath: NSIndexPath?
    private var currentCell: UICollectionViewCell?
    private var lastTouchLocation: CGPoint?
    
    private var needScroll: CGFloat = 0
    private var scrolling = false
    
    
    // MARK: -
    
    private func install() {
        self._longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UZDragSortController.handleLongPress(_: )))
        self.collectionView?.addGestureRecognizer(self.longPressGestureRecognizer!)
    }
    
    private func uninstall() {
        if self.collectionView != nil && self.longPressGestureRecognizer != nil {
            if let index = self.collectionView!.gestureRecognizers?.indexOf(self.longPressGestureRecognizer!) {
                collectionView!.gestureRecognizers?.removeAtIndex(index)
            }
        }
        
        self._longPressGestureRecognizer = nil
    }
    
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            self.draggingDidBegin()
            break
        case .Changed:
            self.draggingStateDidChange()
            break
        case .Ended, .Cancelled:
            self.draggingDidEnd()
            break
        default:
            break
        }
    }
    
    
    // MARK: - Main Handlers
    
    private func draggingDidBegin() {
        if self.currentCell != nil {
            return
        }
        
        guard let location = self.longPressGestureRecognizer?.locationInView(self.collectionView) else {
            return
        }
        
        guard let indexPath = self.collectionView?.indexPathForItemAtPoint(location) else {
            return
        }
        
        if (self.delegate?.dragSortController(self, canMoveItemAtIndexPath: indexPath) == false) {
            return
        }
        
        guard let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) else {
            return
        }
        
        // Create a snapshot view and hide original cell view
        self.snapshotView = UIImageView(image: UZDragSortController.grabSnapshotOfView(cell))
        self.snapshotView?.frame = self.containerView.convertRect(cell.frame, fromView: self.collectionView!)
        self.containerView.addSubview(self.snapshotView!)
        
        cell.hidden = true
        
        UIView.animateWithDuration(self.animationDuration) {
            self.snapshotView?.alpha = self.snapshotOpacity
            self.snapshotView?.transform = CGAffineTransformMakeScale(self.snapshotScale, self.snapshotScale)
        }
        
        self.collectionView?.scrollEnabled = false
        
        // Save states
        self.currentCell = cell
        self.currentIndexPath = indexPath
        self.lastTouchLocation = location
        
        self.delegate?.dragSortController?(self, didBeginDragItemAtIndexPath: indexPath)
    }
    
    private func draggingStateDidChange() {
        self.scrollCollectionViewIfNecessary()
        
        guard let location = self.longPressGestureRecognizer?.locationInView(self.collectionView) else {
            return
        }
        
        guard let indexPath = self.collectionView?.indexPathForItemAtPoint(location) else {
            return
        }
        
        if (self.delegate?.dragSortController(self, moveItemFromIndexPath: self.currentIndexPath!, toIndexPath: indexPath) == false) {
            return
        }
        
        self.snapshotView?.frame.origin = UZDragSortController.movedPoint(self.snapshotView!.frame.origin, byDifferenceOfPoint: self.lastTouchLocation!, andPoint: location)
        
        self.collectionView?.moveItemAtIndexPath(self.currentIndexPath!, toIndexPath: indexPath)
        self.currentCell?.hidden = true
        
        // Modify states
        self.currentIndexPath = indexPath
        self.lastTouchLocation = location
    }
    
    private func draggingDidEnd() {
        self.needScroll = 0
        
        UIView.animateWithDuration(self.animationDuration, animations: {
            self.snapshotView?.transform = CGAffineTransformIdentity
            self.snapshotView?.frame = self.containerView.convertRect(self.currentCell!.frame, fromView: self.collectionView)
            self.snapshotView?.alpha = 1
        }) { (completed: Bool) in
            if !completed {
                return
            }
            
            self.currentCell?.hidden = false
            
            UIView.animateWithDuration(self.animationDuration, animations: {
                self.snapshotView?.alpha = 0
            }, completion: { (completed: Bool) in
                if completed {
                    self.delegate?.dragSortController?(self, didEndDragItemAtFinalIndexPath: self.currentIndexPath!)
                    
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
                    
                    self.collectionView?.scrollEnabled = true
                    
                    self.currentCell = nil
                    self.currentIndexPath = nil
                    self.lastTouchLocation = nil
                }
            })
        }
    }
    
    
    // MARK: - Scrolling
    
    func scrollCollectionViewIfNecessary() {
        let minY = self.collectionView!.frame.minY + self.collectionView!.contentInset.top
        let maxY = self.collectionView!.frame.maxY - self.collectionView!.contentInset.bottom
        
        guard let location = self.longPressGestureRecognizer?.locationInView(self.containerView) else {
            return
        }
        
        if location.y < minY + 50 {
            self.needScroll = -self.scrollVelocity
            self.scrollTick()
        } else if location.y > maxY - 80 {
            self.needScroll = self.scrollVelocity
            self.scrollTick()
        } else {
            self.needScroll = 0
        }
    }
    
    func scrollTick() {
        if self.scrolling {
            return
        }
        
        self.scrolling = true
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 16))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.scrolling = false
            if self.needScroll != 0 {
                let finalOffset = self.collectionView!.contentOffset.y + self.needScroll
                
                // FIXME: There may be some problems
                //        but I did't found it at this very moment.
                if finalOffset < -self.collectionView!.contentInset.top || finalOffset > self.collectionView!.contentSize.height - self.collectionView!.contentInset.bottom - self.collectionView!.frame.height {
                    return
                }
                
                self.collectionView?.contentOffset.y = finalOffset
                self.lastTouchLocation = self.longPressGestureRecognizer!.locationInView(self.collectionView!)
                self.draggingStateDidChange()
                self.scrollTick()
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    private class func grabSnapshotOfView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private class func movedPoint(point: CGPoint, byDifferenceOfPoint point1: CGPoint, andPoint point2: CGPoint) -> CGPoint {
        var result = point
        
        let diffX = point1.x - point2.x
        let diffY = point1.y - point2.y
        
        result.x -= diffX
        result.y -= diffY
        
        return result
    }
    
}
