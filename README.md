# UZDragSortController

**UZDragSortController** is a very easy-to-use tool that make your `UICollectionView` support drag sort behavior on iOS 8 or earlier. You just need to set a property and all things are ready to go!

## Screenshot
![](https://raw.githubusercontent.com/unixzii/UZDragSortController/master/screenshot.gif)

## Installation

This is a one-file library, just add the `UZDragSortController.swift` file to your project.

## Usage

First, declare an `ivar` in your view controller:

```swift
var dragSortController: UZDragSortController?
```

Second, in your `viewDidLoad()` function, put these codes:

```swift
self.dragSortController = UZDragSortController()
self.dragSortController?.collectionView = self.collectionView
self.dragSortController?.delegate = self
```

And next, you need to implement the `UZDragSortControllerDelegate` protocol, there are four function:

* `func dragSortController(controller: UZDragSortController, moveItemFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) -> Bool`: move your data in model, if this action cannot be performed, return `false`, otherwise, return true.

* `func dragSortController(controller: UZDragSortController, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool`: return whether specific item can be moved.

* `optional func dragSortController(controller: UZDragSortController, didBeginDragItemAtIndexPath indexPath: NSIndexPath)`: notify the delegate that controller did begin dragging.

* `optional func dragSortController(controller: UZDragSortController, didEndDragItemAtFinalIndexPath indexPath: NSIndexPath)`: notify the delegate that controller did end dragging.

For detail usage, please refer to the sample project.

## Customize

There are four properties can be changed:

* `scrollVelocity: CGFloat`: the velocity of auto scrolling.

* `animationDuration: NSTimeInterval`: general animation duration.

* `snapshotOpacity: CGFloat`: the opacity of snapshot view while dragging.

* `snapshotScale: CGFloat`: the scale of snapshot view while dragging.
