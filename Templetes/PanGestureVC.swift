//
//  PanGestureVC.swift
//  Templetes
//
//  Created by ahmed abu elregal on 02/04/2023.
//

import UIKit
import AVFoundation


// MARK: - Make this class to be a base to contain image and view and textView and responsable for each UIElement properties
// TODO: - Make this class to be a base to contain image and view and textView and responsable for each UIElement properties

public class PannableView: UIView {
    
    public var enableMoveRestriction: Bool = true {
        didSet {
            
        }
    }
    
    // MARK: - Properties
    
    private var initialCenter: CGPoint = .zero
    
    private var FCGP: CGPoint?
    
    var beginningPoint: CGPoint?
    var beginningCenter: CGPoint?
    var touchLocation: CGPoint?
    var deltaAngle: CGFloat?
    var beginBounds: CGRect?
    
    var snapGuides = [false,false,false,false,false,false,false,false]
    var lastDirection :PanGestureDirection!
    
    //MARK: - Functions
    
    func magnitude(vector: CGPoint) -> CGFloat {
        return sqrt(pow(vector.x, 2) + pow(vector.y, 2))
    }
    
    // MARK: - Actions
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        self.touchLocation = gesture.location(in: superview)
        
        switch gesture.state {
            
        case .began:
            
            beginningPoint = touchLocation
            beginningCenter = center
            
            center = estimatedCenter()
            beginBounds = bounds
            
            // Implement did began here
            
        case .changed:
            
            center = estimatedCenter()
            
            // Implement did changed here
            
        case .ended:
            
            // Implement did ended here
            
            break
            
        default:
            break
            
        }
        
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)
        let magVelocity = magnitude(vector: velocity)
        let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let speed = min(max(magnitude, 500), 1000)
        let directionn = CGVector(dx: velocity.x / magnitude, dy: velocity.y / magnitude)
        let scaledVelocity = CGVector(dx: directionn.dx * speed / 1000, dy: directionn.dy * speed / 1000)
        let newCenter = CGPoint(x: gesture.view!.center.x + translation.x + scaledVelocity.dx, y: gesture.view!.center.y + translation.y + scaledVelocity.dy)
        gesture.view?.center = newCenter
        gesture.setTranslation(.zero, in: superview)
        
        UserDefaults.standard.set(gesture.view?.center.x ?? 0.0 + translation.x, forKey: "imagePositionX")
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.set(gesture.view?.center.y ?? 0.0 + translation.y, forKey: "imagePositionY")
        UserDefaults.standard.synchronize()
        
        if let positionX = UserDefaults.standard.object(forKey: "imagePositionX") as? CGFloat, let positionY = UserDefaults.standard.object(forKey: "imagePositionY") as? CGFloat {
            print("imagePositionX : \(positionX) , imagePositionY : \(positionY)")
            //self.pannableView.center = CGPoint(x: positionX, y: positionY)
        }
        
        let translationS = gesture.translation(in: superview)
        var targetPoint = CGPoint(x: center.x + translationS.x, y: center.y + translationS.y)
        var realImageRect = CGRect.zero
        var realImageCenter = CGPoint.zero
        if let imageView = superview as? UIImageView { // as ARBStickerImageView
            let image = imageView.image
            realImageRect = AVMakeRect(aspectRatio: image!.size, insideRect: imageView.bounds)
            realImageCenter = CGPoint(x: realImageRect.width/2, y: realImageRect.height/2)
        }
        let stickerWidth = frame.size.width
        let stickerHeight = frame.size.height
        //25 + 150
        // 175
        targetPoint.x = max(realImageRect.origin.x - stickerWidth * 0.3, targetPoint.x);
        targetPoint.y = max(realImageRect.origin.y - stickerHeight * 0.3 + 10.0, targetPoint.y);
        targetPoint.x = min(realImageRect.origin.x + realImageRect.size.width + stickerWidth * 0.3, targetPoint.x);
        targetPoint.y = min(realImageRect.origin.y + realImageRect.size.height + stickerHeight * 0.3 - 10.0, targetPoint.y);
        
        
        //print("recognizer.state = \(recognizer.state.rawValue)")
        let direction = gesture.direction(in: self)
        
        if direction.contains(.Left) {
            //print("----------------------- Moving Left ----------------------")
        }
        if direction.contains(.Right) {
            //print("----------------------- Moving Right ----------------------")
        }
        if direction.contains(.Up) {
            //print("----------------------- Moving Up ----------------------")
        }
        if direction.contains(.Down) {
            //print("----------------------- Moving Down ----------------------")
        }
        
        //print(" velocity magnitue = \(magVelocity)")
        
        var changeX = (gesture.view?.center.x)! - translation.x
        var changeY = (gesture.view?.center.y)! - translation.y
        
        let labelHandlesMargin = CGFloat(15.0)
        let tollerence = CGFloat(10.0)
        
        let imageView = gesture.view!.superview!
        
        let labelLeftEdge = ((gesture.view?.center.x)! - ((gesture.view?.frame.width)! / 2)) + labelHandlesMargin
        
        let labelRightEdge = (imageView.frame.width) - (((gesture.view?.center.x)! + CGFloat(((gesture.view?.frame.width)! / 2))) - labelHandlesMargin)
        
        let labelTopEdge = ((gesture.view?.center.y)! - ((gesture.view?.frame.height)! / 2)) + labelHandlesMargin
        
        // print("label recognizer.view? frame = \(recognizer.view?.frame)")
        
        
        let labelBottomEdge = (imageView.frame.height) - ((gesture.view?.center.y)! + ((gesture.view?.frame.height)! / 2)) + labelHandlesMargin
        
        
        let labelX = (gesture.view!.center.y) - (imageView.frame.height/2)
        let labelY = (gesture.view!.center.x) - (imageView.frame.width/2)
        
        
        // print("center point = \(((realImageCenter.y) - CGFloat(((realImageRect.height) / 2))))")
        
        // print("realImageRect y = \(realImageRect.origin.y)")
        // print("recognizer.view?.frame y = \(String(describing: recognizer.view?.frame.origin.y))")
        
        
        let imageTopEdge = realImageRect.origin.y - (gesture.view?.frame.origin.y)!
        
        let imageBottomEdge = (realImageRect.origin.y + realImageRect.size.height) - ((gesture.view!.center.y) + ((gesture.view?.frame.height)!/2)) + labelHandlesMargin
        
        if gesture.state == .began || gesture.state == .changed {
            
            // print("print 1")
            
            beginningPoint = touchLocation
            beginningCenter = center
            
            center = estimatedCenter()
            beginBounds = bounds
            
            if magVelocity > 80 && magVelocity < 8 {
                gesture.view?.center = CGPoint(x: changeX, y: changeY)
                gesture.setTranslation(CGPoint.zero, in: gesture.view)
                return
            }
            
            if imageBottomEdge <= tollerence && imageBottomEdge > 0.0 {
                if  direction.contains(.Down) {
                    
                    changeY = realImageRect.size.height + (((gesture.view?.superview?.frame.size.height)! - realImageRect.size.height) / 2) - ((gesture.view?.frame.height)! / 2) + labelHandlesMargin
                    
                    if !snapGuides[7] {
                        drawImageBottomGuideLine((gesture.view)!, imageRect: realImageRect, superViewRect: (gesture.view?.superview!.frame)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeImageBottomGuideLine((gesture.view)!)
            }
            
            if imageTopEdge <= tollerence && imageTopEdge > 0.0 {
                if  direction.contains(.Up) {
                    changeY = realImageRect.origin.y + ((gesture.view?.frame.height)! / 2) - labelHandlesMargin
                    if !snapGuides[6] {
                        drawImageTopGuideLine((gesture.view)!, imageRect: realImageRect)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeImageTopGuideLine((gesture.view)!)
            }
            
            //Draw Center Y Guide
            if labelY <= tollerence && labelY > 0.0 {
                if  direction.contains(.Left) {
                    changeX = imageView.frame.width/2 + 1.0
                    if !snapGuides[5] {
                        drawCenterYGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeCenterYGuideLine((gesture.view)!)
            }
            
            //Draw Center X Guide
            if labelX <= tollerence && labelX > 0.0 {
                if  direction.contains(.Up) {
                    changeY = imageView.frame.height/2 + 1.0
                    if !snapGuides[4] {
                        drawCenterXGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeCenterXGuideLine((gesture.view)!)
            }
            
            
            //Draw Bottom Guide
            if labelBottomEdge <= tollerence && labelBottomEdge > 0.0 {
                if  !direction.contains(.Up) {
                    changeY = (imageView.frame.height) - ((gesture.view?.frame.height)! / 2) + labelHandlesMargin
                    if !snapGuides[3] {
                        drawBottomGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeBottomGuideLine((gesture.view)!)
            }
            
            //Draw Top Guide
            if labelTopEdge <= tollerence && labelTopEdge > 0.0 {
                if  !direction.contains(.Down) {
                    changeY = ((gesture.view?.frame.height)! / 2) - labelHandlesMargin
                    if !snapGuides[2] {
                        drawTopGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeTopGuideLine((gesture.view)!)
            }
            
            //Draw Left Guide
            if labelLeftEdge <= tollerence && labelLeftEdge > 0.0 {
                if  !direction.contains(.Right) {
                    changeX = ((gesture.view?.frame.width)! / 2) - labelHandlesMargin
                    if !snapGuides[0] {
                        drawLeftGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeLeftGuideLine((gesture.view)!)
            }
            
            //Draw Right Guide
            if labelRightEdge <= tollerence && labelRightEdge > 0.0 {
                if  !direction.contains(.Left) {
                    changeX = (imageView.frame.width) - (((gesture.view?.frame.width)! / 2) - labelHandlesMargin)
                    if !snapGuides[1] {
                        drawRightGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeRightGuideLine((gesture.view)!)
            }
            
            gesture.view?.center = CGPoint(x: changeX, y: changeY)
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
        }
        
        if gesture.state == .ended {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let layers = self.superview?.layer.sublayers?.filter({$0.name == "TopEdge" || $0.name == "CenterY" || $0.name == "ImageBottom" || $0.name == "ImageTop" || $0.name == "CenterX" || $0.name == "BottomEdge" ||  $0.name == "LeftEdge" ||  $0.name == "RightEdge" }) {
                    _ = layers.map { layer in
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
        
    }
    
}

class PanGestureVC: UIViewController {
    
    public var enableMoveRestriction: Bool = true {
        didSet {
            
        }
    }
    
    // MARK: - Properties
    
    private let pannableView: UIView = {
        // Initialize View
        let view = UIView(frame: CGRect(origin: .zero,
                                        size: CGSize(width: 200.0, height: 200.0)))
        
        // Configure View
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    // MARK: - Properties
    
    private var initialCenter: CGPoint = .zero
    
    private var FCGP: CGPoint?
    
    var beginningPoint: CGPoint?
    var beginningCenter: CGPoint?
    var touchLocation: CGPoint?
    var deltaAngle: CGFloat?
    var beginBounds: CGRect?
    
    var snapGuides = [false, false, false, false, false, false, false, false]
    var lastDirection :PanGestureDirection!
    
    //
    
    // Create undo button
    var undoButton = UIBarButtonItem()
    
    // Create redo button
    var redoButton = UIBarButtonItem()
    
    //let undoManager = UndoManager()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add to View Hierarchy
        view.addSubview(pannableView)
        
        // Initialize Swipe Gesture Recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        // Add Swipe Gesture Recognizer
        pannableView.addGestureRecognizer(panGestureRecognizer)
        
        // Create undo button
        undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undo))
        
        // Create redo button
        redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redo))
        
        // Add buttons to the navigation bar
        navigationItem.leftBarButtonItems = [undoButton, redoButton]
        
        // Enable/disable undo and redo buttons based on the state of the UndoManager
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
        
        NotificationCenter.default.addObserver(self, selector: #selector(undoManagerDidUndo), name: .NSUndoManagerDidUndoChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(undoManagerDidRedo), name: .NSUndoManagerDidRedoChange, object: nil)
        
//        UserDefaults.standard.removeObject(forKey: "imagePositionX")
//        UserDefaults.standard.removeObject(forKey: "imagePositionY")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let positionX = UserDefaults.standard.object(forKey: "imagePositionX") as? CGFloat, let positionY = UserDefaults.standard.object(forKey: "imagePositionY") as? CGFloat {
            print("imagePositionX : \(positionX) , imagePositionY : \(positionY)")
            pannableView.center = CGPoint(x: positionX, y: positionY)
        }else {
            // Center Pannable View
            pannableView.center = view.center
        }
        
    }
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        
        if let positionX = UserDefaults.standard.object(forKey: "imagePositionX") as? CGFloat, let positionY = UserDefaults.standard.object(forKey: "imagePositionY") as? CGFloat {
            print("imagePositionX : \(positionX) , imagePositionY : \(positionY)")
            pannableView.center = CGPoint(x: positionX, y: positionY)
        }else {
            // Center Pannable View
            pannableView.center = view.center
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Functions
    
    @objc func undo() {
        undoManager?.undo()
    }
    
    @objc func redo() {
        undoManager?.redo()
    }
    
    @objc func undoManagerDidUndo(_ notification: Notification) {
        // Enable/disable undo and redo buttons based on the state of the UndoManager
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
    }
    
    @objc func undoManagerDidRedo(_ notification: Notification) {
        // Enable/disable undo and redo buttons based on the state of the UndoManager
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
    }
    
    @objc func undoMoveView(_ finalCenter: CGPoint) {
        pannableView.center = finalCenter
    }
    
    func magnitude(vector: CGPoint) -> CGFloat {
        return sqrt(pow(vector.x, 2) + pow(vector.y, 2))
    }
    
    // MARK: - Actions
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        self.touchLocation = gesture.location(in: view)
        
        switch gesture.state {
            
        case .began:
            
            beginningPoint = touchLocation
            beginningCenter = view.center
            
            view.center = estimatedCenter()
            beginBounds = view.bounds
            
            // Implement did began here
            
            //undoManager?.beginUndoGrouping()
            
        case .changed:
            
            view.center = self.estimatedCenter()
            
            // Implement did changed here
            
        case .ended:
            
            // Implement did ended here
            
            let previousCenter = beginningPoint!
            undoManager?.registerUndo(withTarget: self, handler: { target in
                target.pannableView.center = previousCenter
                
                if let name = self.undoManager?.undoActionName  {
                    
                    print("name: \(name) == target.undoManager?.undoActionName: \(self.undoManager?.undoActionName)")
                    
                }
                
            })
            
            // Enable/disable undo and redo buttons based on the state of the UndoManager
            undoButton.isEnabled = undoManager?.canUndo ?? false
            redoButton.isEnabled = undoManager?.canRedo ?? false
            
            //let finalCenter = pannableView.center
            //undoManager?.registerUndo(withTarget: self, selector: #selector(undoMoveView), object: finalCenter)
            //undoManager?.endUndoGrouping()
            
            ////  Enable/disable undo and redo buttons based on the state of the UndoManager
            //undoButton.isEnabled = undoManager?.canUndo ?? false
            //redoButton.isEnabled = undoManager?.canRedo ?? false
            
            //break
            
        default:
            break
            
        }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let magVelocity = magnitude(vector: velocity)
        let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let speed = min(max(magnitude, 500), 1000)
        let directionn = CGVector(dx: velocity.x / magnitude, dy: velocity.y / magnitude)
        let scaledVelocity = CGVector(dx: directionn.dx * speed / 150, dy: directionn.dy * speed / 150) //CGVector(dx: directionn.dx * speed / 1000, dy: directionn.dy * speed / 1000)
        let newCenter = CGPoint(x: gesture.view!.center.x + translation.x + scaledVelocity.dx, y: gesture.view!.center.y + translation.y + scaledVelocity.dy)
        gesture.view?.center = newCenter
        gesture.setTranslation(.zero, in: view)
        
        UserDefaults.standard.set(gesture.view?.center.x ?? 0.0 + translation.x, forKey: "imagePositionX")
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.set(gesture.view?.center.y ?? 0.0 + translation.y, forKey: "imagePositionY")
        UserDefaults.standard.synchronize()
        
        if let positionX = UserDefaults.standard.object(forKey: "imagePositionX") as? CGFloat, let positionY = UserDefaults.standard.object(forKey: "imagePositionY") as? CGFloat {
            print("imagePositionX : \(positionX) , imagePositionY : \(positionY)")
            self.pannableView.center = CGPoint(x: positionX, y: positionY)
        }
        
        let translationS = gesture.translation(in: view.superview)
        var targetPoint = CGPoint(x: view.center.x + translationS.x, y: view.center.y + translationS.y)
        var realImageRect = CGRect.zero
        var realImageCenter = CGPoint.zero
        if let imageView = view.superview as? UIImageView { // as ARBStickerImageView
            let image = imageView.image
            realImageRect = AVMakeRect(aspectRatio: image!.size, insideRect: imageView.bounds)
            realImageCenter = CGPoint(x: realImageRect.width/2, y: realImageRect.height/2)
        }
        let stickerWidth = view.frame.size.width
        let stickerHeight = view.frame.size.height
        //25 + 150
        // 175
        targetPoint.x = max(realImageRect.origin.x - stickerWidth * 0.3, targetPoint.x);
        targetPoint.y = max(realImageRect.origin.y - stickerHeight * 0.3 + 10.0, targetPoint.y);
        targetPoint.x = min(realImageRect.origin.x + realImageRect.size.width + stickerWidth * 0.3, targetPoint.x);
        targetPoint.y = min(realImageRect.origin.y + realImageRect.size.height + stickerHeight * 0.3 - 10.0, targetPoint.y);
        
        
        //print("recognizer.state = \(recognizer.state.rawValue)")
        let direction = gesture.direction(in: gesture.view!.superview!)
        
        if direction.contains(.Left) {
            //print("----------------------- Moving Left ----------------------")
        }
        if direction.contains(.Right) {
            //print("----------------------- Moving Right ----------------------")
        }
        if direction.contains(.Up) {
            //print("----------------------- Moving Up ----------------------")
        }
        if direction.contains(.Down) {
            //print("----------------------- Moving Down ----------------------")
        }
        
        //print(" velocity magnitue = \(magVelocity)")
        
        var changeX = (gesture.view?.center.x)! - translation.x
        var changeY = (gesture.view?.center.y)! - translation.y
        
        let labelHandlesMargin = CGFloat(15.0)
        let tollerence = CGFloat(10.0)
        
        let imageView = gesture.view!.superview!
        
        let labelLeftEdge = ((gesture.view?.center.x)! - ((gesture.view?.frame.width)! / 2)) + labelHandlesMargin
        
        let labelRightEdge = (imageView.frame.width) - (((gesture.view?.center.x)! + CGFloat(((gesture.view?.frame.width)! / 2))) - labelHandlesMargin)
        
        let labelTopEdge = ((gesture.view?.center.y)! - ((gesture.view?.frame.height)! / 2)) + labelHandlesMargin
        
        // print("label recognizer.view? frame = \(recognizer.view?.frame)")
        
        
        let labelBottomEdge = (imageView.frame.height) - ((gesture.view?.center.y)! + ((gesture.view?.frame.height)! / 2)) + labelHandlesMargin
        
        
        let labelX = (gesture.view!.center.y) - (imageView.frame.height/2)
        let labelY = (gesture.view!.center.x) - (imageView.frame.width/2)
        
        
        // print("center point = \(((realImageCenter.y) - CGFloat(((realImageRect.height) / 2))))")
        
        // print("realImageRect y = \(realImageRect.origin.y)")
        // print("recognizer.view?.frame y = \(String(describing: recognizer.view?.frame.origin.y))")
        
        
        let imageTopEdge = realImageRect.origin.y - (gesture.view?.frame.origin.y)!
        
        let imageBottomEdge = (realImageRect.origin.y + realImageRect.size.height) - ((gesture.view!.center.y) + ((gesture.view?.frame.height)!/2)) + labelHandlesMargin
        
        if gesture.state == .began || gesture.state == .changed {
            
            // print("print 1")
            
            beginningPoint = touchLocation
            beginningCenter = view.center
            
            view.center = estimatedCenter()
            beginBounds = view.bounds
            
            if magVelocity > 80 && magVelocity < 8 {
                gesture.view?.center = CGPoint(x: changeX, y: changeY)
                gesture.setTranslation(CGPoint.zero, in: gesture.view)
                return
            }
            
            if imageBottomEdge <= tollerence && imageBottomEdge > 0.0 {
                if  direction.contains(.Down) {
                    
                    changeY = realImageRect.size.height + (((gesture.view?.superview?.frame.size.height)! - realImageRect.size.height) / 2) - ((gesture.view?.frame.height)! / 2) + labelHandlesMargin
                    
                    if !snapGuides[7] {
                        drawImageBottomGuideLine((gesture.view)!, imageRect: realImageRect, superViewRect: (gesture.view?.superview!.frame)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeImageBottomGuideLine((gesture.view)!)
            }
            
            if imageTopEdge <= tollerence && imageTopEdge > 0.0 {
                if  direction.contains(.Up) {
                    changeY = realImageRect.origin.y + ((gesture.view?.frame.height)! / 2) - labelHandlesMargin
                    if !snapGuides[6] {
                        drawImageTopGuideLine((gesture.view)!, imageRect: realImageRect)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeImageTopGuideLine((gesture.view)!)
            }
            
            //Draw Center Y Guide
            if labelY <= tollerence && labelY > 0.0 {
                if  direction.contains(.Left) {
                    changeX = imageView.frame.width/2 + 1.0
                    if !snapGuides[5] {
                        drawCenterYGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeCenterYGuideLine((gesture.view)!)
            }
            
            //Draw Center X Guide
            if labelX <= tollerence && labelX > 0.0 {
                if  direction.contains(.Up) {
                    changeY = imageView.frame.height/2 + 1.0
                    if !snapGuides[4] {
                        drawCenterXGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                        lastDirection = direction
                    }
                }
            } else {
                removeCenterXGuideLine((gesture.view)!)
            }
            
            
            //Draw Bottom Guide
            if labelBottomEdge <= tollerence && labelBottomEdge > 0.0 {
                if  !direction.contains(.Up) {
                    changeY = (imageView.frame.height) - ((gesture.view?.frame.height)! / 2) + labelHandlesMargin
                    if !snapGuides[3] {
                        drawBottomGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeBottomGuideLine((gesture.view)!)
            }
            
            //Draw Top Guide
            if labelTopEdge <= tollerence && labelTopEdge > 0.0 {
                if  !direction.contains(.Down) {
                    changeY = ((gesture.view?.frame.height)! / 2) - labelHandlesMargin
                    if !snapGuides[2] {
                        drawTopGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeTopGuideLine((gesture.view)!)
            }
            
            //Draw Left Guide
            if labelLeftEdge <= tollerence && labelLeftEdge > 0.0 {
                if  !direction.contains(.Right) {
                    changeX = ((gesture.view?.frame.width)! / 2) - labelHandlesMargin
                    if !snapGuides[0] {
                        drawLeftGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeLeftGuideLine((gesture.view)!)
            }
            
            //Draw Right Guide
            if labelRightEdge <= tollerence && labelRightEdge > 0.0 {
                if  !direction.contains(.Left) {
                    changeX = (imageView.frame.width) - (((gesture.view?.frame.width)! / 2) - labelHandlesMargin)
                    if !snapGuides[1] {
                        drawRightGuideLine((gesture.view)!)
                        //Vibration.heavy.vibrate()
                    }
                }
            } else {
                removeRightGuideLine((gesture.view)!)
            }
            
            gesture.view?.center = CGPoint(x: changeX, y: changeY)
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
        }
        
        if gesture.state == .ended {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let layers = self.view.superview?.layer.sublayers?.filter({$0.name == "TopEdge" || $0.name == "CenterY" || $0.name == "ImageBottom" || $0.name == "ImageTop" || $0.name == "CenterX" || $0.name == "BottomEdge" ||  $0.name == "LeftEdge" ||  $0.name == "RightEdge" }) {
                    _ = layers.map { layer in
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
        
    }
    
}


extension PanGestureVC {
    
    func removeImageBottomGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageBottom"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[7] = false
    }
    
    func drawImageBottomGuideLine(_ view:UIView, imageRect:CGRect, superViewRect:CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: imageRect.size.height + ((superViewRect.size.height - imageRect.size.height) / 2)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: imageRect.size.height + ((superViewRect.size.height - imageRect.size.height) / 2)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageBottom"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "ImageBottom"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[7] = true
    }
    
    
    func removeImageTopGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageTop"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[6] = false
    }
    
    func drawImageTopGuideLine(_ view:UIView, imageRect:CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: imageRect.origin.y))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: imageRect.origin.y))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageTop"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "ImageTop"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[6] = true
    }
    
    func removeCenterYGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterY"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[5] = false
    }
    
    func drawCenterYGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (view.superview!.frame.width/2), y: 0.0))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width/2), y: (view.superview!.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterY"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "CenterY"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[5] = true
    }
    
    func removeCenterXGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterX"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[4] = false
    }
    
    func drawCenterXGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: (view.superview!.frame.height/2)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: (view.superview!.frame.height/2)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterX"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "CenterX"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[4] = true
    }
    
    func removeBottomGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "BottomEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[3] = false
    }
    
    func drawBottomGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: (view.superview!.frame.height)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: (view.superview!.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "BottomEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "BottomEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[3] = true
    }
    
    func removeTopGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "TopEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[2] = false
    }
    
    func drawTopGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: CGFloat(0.0)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "TopEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "TopEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[2] = true
    }
    
    func removeLeftGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "LeftEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[0] = false
    }
    
    func drawLeftGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: (view.superview?.frame.height)!))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "LeftEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "LeftEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[0] = true
    }
    
    
    func removeRightGuideLine(_ view:UIView) {
        if let rightLayer = view.superview?.layer.sublayers?.filter({$0.name == "RightEdge"}).first {
            rightLayer.removeFromSuperlayer()
        }
        snapGuides[1] = false
    }
    
    func drawRightGuideLine(_ view:UIView) {
        let imageView = view.superview!
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (imageView.frame.width), y: 0))
        path.addLine(to: CGPoint(x: (imageView.frame.width), y: (imageView.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "RightEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = nil
        shapeLayer.opacity = 1.0
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "RightEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[1] = true
    }
    
    func estimatedCenter() -> CGPoint{
        let newCenter: CGPoint!
        var newCenterX = beginningCenter!.x + (touchLocation!.x - beginningPoint!.x)
        var newCenterY = beginningCenter!.y + (touchLocation!.y - beginningPoint!.y)
        // print("beginningCenter = \(beginningCenter)")
        // print("beginningPoint = \(beginningPoint)")
        // print("touchLocation = \(touchLocation)")
        
        if (enableMoveRestriction) {
            if (!(newCenterX - 0.5 * view.frame.width > 0 &&
                  newCenterX + 0.5 * view.frame.width < view.superview!.bounds.width)) {
                newCenterX = view.center.x;
            }
            if (!(newCenterY - 0.5 * view.frame.height > 0 &&
                  newCenterY + 0.5 * view.frame.height < view.superview!.bounds.height)) {
                newCenterY = view.center.y;
            }
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }else {
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }
        return newCenter
    }
    
}

extension PannableView {
    
    func removeImageBottomGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageBottom"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[7] = false
    }
    
    func drawImageBottomGuideLine(_ view:UIView, imageRect:CGRect, superViewRect:CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: imageRect.size.height + ((superViewRect.size.height - imageRect.size.height) / 2)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: imageRect.size.height + ((superViewRect.size.height - imageRect.size.height) / 2)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageBottom"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "ImageBottom"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[7] = true
    }
    
    
    func removeImageTopGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageTop"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[6] = false
    }
    
    func drawImageTopGuideLine(_ view:UIView, imageRect:CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: imageRect.origin.y))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: imageRect.origin.y))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "ImageTop"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "ImageTop"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[6] = true
    }
    
    func removeCenterYGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterY"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[5] = false
    }
    
    func drawCenterYGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (view.superview!.frame.width/2), y: 0.0))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width/2), y: (view.superview!.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterY"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "CenterY"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[5] = true
    }
    
    func removeCenterXGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterX"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[4] = false
    }
    
    func drawCenterXGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: (view.superview!.frame.height/2)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: (view.superview!.frame.height/2)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "CenterX"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "CenterX"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[4] = true
    }
    
    func removeBottomGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "BottomEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[3] = false
    }
    
    func drawBottomGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: (view.superview!.frame.height)))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: (view.superview!.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "BottomEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "BottomEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[3] = true
    }
    
    func removeTopGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "TopEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[2] = false
    }
    
    func drawTopGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (view.superview!.frame.width), y: CGFloat(0.0)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "TopEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "TopEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[2] = true
    }
    
    func removeLeftGuideLine(_ view:UIView) {
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "LeftEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        snapGuides[0] = false
    }
    
    func drawLeftGuideLine(_ view:UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: (view.superview?.frame.height)!))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "LeftEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "LeftEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[0] = true
    }
    
    
    func removeRightGuideLine(_ view:UIView) {
        if let rightLayer = view.superview?.layer.sublayers?.filter({$0.name == "RightEdge"}).first {
            rightLayer.removeFromSuperlayer()
        }
        snapGuides[1] = false
    }
    
    func drawRightGuideLine(_ view:UIView) {
        let imageView = view.superview!
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (imageView.frame.width), y: 0))
        path.addLine(to: CGPoint(x: (imageView.frame.width), y: (imageView.frame.height)))
        
        //design path in layer
        if let leftLayer = view.superview?.layer.sublayers?.filter({$0.name == "RightEdge"}).first {
            leftLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = nil
        shapeLayer.opacity = 1.0
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.name = "RightEdge"
        view.superview?.layer.addSublayer(shapeLayer)
        snapGuides[1] = true
    }
    
    func estimatedCenter() -> CGPoint{
        let newCenter: CGPoint!
        var newCenterX = beginningCenter!.x + (touchLocation!.x - beginningPoint!.x)
        var newCenterY = beginningCenter!.y + (touchLocation!.y - beginningPoint!.y)
        // print("beginningCenter = \(beginningCenter)")
        // print("beginningPoint = \(beginningPoint)")
        // print("touchLocation = \(touchLocation)")
        
        if (enableMoveRestriction) {
            if (!(newCenterX - 0.5 * frame.width > 0 &&
                  newCenterX + 0.5 * frame.width < superview!.bounds.width)) {
                newCenterX = center.x;
            }
            if (!(newCenterY - 0.5 * frame.height > 0 &&
                  newCenterY + 0.5 * frame.height < superview!.bounds.height)) {
                newCenterY = center.y
            }
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }else {
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }
        return newCenter
    }
    
}

struct PanGestureDirection: OptionSet {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let Up = PanGestureDirection(rawValue: 1 << 0)
    static let Down = PanGestureDirection(rawValue: 1 << 1)
    static let Left = PanGestureDirection(rawValue: 1 << 2)
    static let Right = PanGestureDirection(rawValue: 1 << 3)
}

public extension UIPanGestureRecognizer {
    
    
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    internal func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}
