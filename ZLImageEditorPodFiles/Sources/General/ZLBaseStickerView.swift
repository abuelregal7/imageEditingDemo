//
//  ZLBaseStickerView.swift
//  ZLImageEditor
//
//  Created by long on 2023/2/6.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import AVFoundation
import MobileCoreServices

enum GuideDirection {
    case none
    case top
    case bottom
    case left
    case right
    case centerX
    case centerY
}

protocol ZLStickerViewDelegate: NSObject {
    // Called when scale or rotate or move.
    func stickerBeginOperation(_ sticker: UIView)
    
    // Called during scale or rotate or move.
    func stickerOnOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
    
    // Called after scale or rotate or move.
    func stickerEndOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
    
    // Called when tap sticker.
    func stickerDidTap(_ sticker: UIView)
    
    func sticker(_ textSticker: ZLTextStickerView, editText text: String)
}

protocol ZLStickerViewAdditional: NSObject {
    var gesIsEnabled: Bool { get set }
    
    func resetState()
    
    func moveToAshbin()
    
    func addScale(_ scale: CGFloat)
}

enum ZLStickerLayout {
    static let borderWidth = 1 / UIScreen.main.scale
    static let edgeInset: CGFloat = 20
}

class ZLBaseStickerView<T>: UIView, UIGestureRecognizerDelegate, NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String] // Set the appropriate type identifier
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        // Implement the method to provide the data for the drag item
        // Return a Progress object if necessary, otherwise return nil
        return nil
    }
    
    private enum Direction: Int {
        case up = 0
        case right = 90
        case bottom = 180
        case left = 270
    }
    
    var firstLayout = true
    
    let originScale: CGFloat
    
    let originAngle: CGFloat
    
    var originTransform: CGAffineTransform = .identity
    
    var timer: Timer?
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var maxGesScale: CGFloat = 4
    
    var onOperation = false
    
    var gesIsEnabled = true
    
    var originFrame: CGRect
    
    lazy var tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    
    lazy var closeGes = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
    
    lazy var pinchGes: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinch.delegate = self
        return pinch
    }()
    
    lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    lazy var resizeGes: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchActionTapped(_:)))
        pinch.delegate = self
        return pinch
    }()
    
    lazy var rotateGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(rotateViewPanGesture(_:)))
        pan.delegate = self
        return pan
    }()
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var rotationGestureRecognizer: UIRotationGestureRecognizer!
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    var state: T {
        fatalError()
    }
    
    var borderView: UIView {
        return self
    }
    
    public var rotateView: UIImageView?
    public var closeView: UIButton?
    public var centerView: UIButton?
    public var resizeView: UIImageView?
    
    var lastRotation: CGFloat = 0
    
    var globalInset: CGFloat? = 19
    var anotherState = 0
    
    //var globalInset: CGFloat?
    var initialBounds: CGRect?
    var initialDistance: CGFloat?
    var beginningPoint: CGPoint?
    var beginningCenter: CGPoint?
    var touchLocation: CGPoint?
    var deltaAngle: CGFloat?
    var beginBounds: CGRect?
    var deltaAngleDiff: CGFloat?
    
//    public var border: CAShapeLayer?
//
//    public var borderColor: UIColor? {
//        didSet {
//            border?.strokeColor = borderColor?.cgColor
//        }
//    }
    
    var snapGuides = [false, false, false, false, false, false, false, false]
    var lastDirection :PanGestureDirection!
    public var enableMoveRestriction: Bool = true {
        didSet {
            
        }
    }
    
    var topGuideLine: UIView!
    var bottomGuideLine: UIView!
    var leftGuideLine: UIView!
    var rightGuideLine: UIView!
    
    let dashedBorder = CAShapeLayer()
    
    weak var delegate: ZLStickerViewDelegate?
    
    deinit {
        cleanTimer()
    }
    
    init(
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        super.init(frame: .zero)
        
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        
        borderView.layer.borderWidth = ZLStickerLayout.borderWidth
        setupBorder()
        hideBorder()
        if showBorder {
            startTimer()
        }
        
        //setupUIFrameWhenFirstLayout()
        
        addGestureRecognizer(tapGes)
        addGestureRecognizer(pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        addGestureRecognizer(rotationGes)
        
        addGestureRecognizer(panGes)
        tapGes.require(toFail: panGes)
        
        //panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        // Add gesture recognizers to UI element
        //addGestureRecognizer(panGestureRecognizer)
        //self.rotateView?.addGestureRecognizer(rotationGestureRecognizer)
        //self.resizeView?.addGestureRecognizer(pinchGestureRecognizer)
        
        rotateView?.isUserInteractionEnabled = true
        resizeView?.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(pinchGesture))
        pinchGesture.delegate = self
        resizeView?.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(rotationGesture) )
        rotationGestureRecognizer.delegate = self
        rotateView?.addGestureRecognizer(rotationGestureRecognizer)
        
//        topGuideLine = UIView()
//        topGuideLine.backgroundColor = UIColor.red
//        addSubview(topGuideLine)
//        
//        bottomGuideLine = UIView()
//        bottomGuideLine.backgroundColor = UIColor.red
//        addSubview(bottomGuideLine)
//        
//        leftGuideLine = UIView()
//        leftGuideLine.backgroundColor = UIColor.red
//        addSubview(leftGuideLine)
//        
//        rightGuideLine = UIView()
//        rightGuideLine.backgroundColor = UIColor.red
//        addSubview(rightGuideLine)
        
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard firstLayout else {
            return
        }
        
//        let guideLineLength: CGFloat = min(bounds.width, bounds.height) * 0.8
//        let guideLineThickness: CGFloat = 1.0
//
//        topGuideLine.frame = CGRect(x: bounds.midX - guideLineLength / 2, y: 0, width: guideLineLength, height: guideLineThickness)
//        bottomGuideLine.frame = CGRect(x: bounds.midX - guideLineLength / 2, y: bounds.height - guideLineThickness, width: guideLineLength, height: guideLineThickness)
//        leftGuideLine.frame = CGRect(x: 0, y: bounds.midY - guideLineLength / 2, width: guideLineThickness, height: guideLineLength)
//        rightGuideLine.frame = CGRect(x: bounds.width - guideLineThickness, y: bounds.midY - guideLineLength / 2, width: guideLineThickness, height: guideLineLength)
        
        // Rotate must be first when first layout.
        transform = transform.rotated(by: originAngle.zl.toPi)
        
        if totalTranslationPoint != .zero {
            let direction = direction(for: originAngle)
            if direction == .right {
                transform = transform.translatedBy(x: totalTranslationPoint.y, y: -totalTranslationPoint.x)
            } else if direction == .bottom {
                transform = transform.translatedBy(x: -totalTranslationPoint.x, y: -totalTranslationPoint.y)
            } else if direction == .left {
                transform = transform.translatedBy(x: -totalTranslationPoint.y, y: totalTranslationPoint.x)
            } else {
                transform = transform.translatedBy(x: totalTranslationPoint.x, y: totalTranslationPoint.y)
            }
        }
        
        transform = transform.scaledBy(x: originScale, y: originScale)
        
        originTransform = transform
        
        if gesScale != 1 {
            transform = transform.scaledBy(x: gesScale, y: gesScale)
        }
        if gesRotation != 0 {
            transform = transform.rotated(by: gesRotation)
        }
        
        firstLayout = false
        setupUIFrameWhenFirstLayout()
        setupBorder()
        self.closeView?.addTarget(self, action: #selector(closeActionButton), for: .touchUpInside)
        self.centerView?.addTarget(self, action: #selector(centerTextActionButton), for: .touchUpInside)
        //self.rotateView?.isUserInteractionEnabled = true
        //self.rotateView?.addGestureRecognizer(rotateGes)
        //self.resizeView?.isUserInteractionEnabled = true
        //self.resizeView?.addGestureRecognizer(resizeGes)
        
        //panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        // Add gesture recognizers to UI element
        //addGestureRecognizer(panGestureRecognizer)
        //self.rotateView?.addGestureRecognizer(rotationGestureRecognizer)
        //self.resizeView?.addGestureRecognizer(pinchGestureRecognizer)
        
        //self.rotateView!.addGestureRecognizer(rotateGes)
        //rotateGes.require(toFail: panGes)
        //self.resizeView!.addGestureRecognizer(resizeGes)
        //resizeGes.require(toFail: panGes)
        
        rotateView?.isUserInteractionEnabled = true
        resizeView?.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(pinchGesture))
        pinchGesture.delegate = self
        resizeView?.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(rotationGesture) )
        rotationGestureRecognizer.delegate = self
        rotateView?.addGestureRecognizer(rotationGestureRecognizer)
        
    }
    
    @objc func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
        // Rotate UI element
        transform = transform.rotated(by: gestureRecognizer.rotation)
        
        // Reset gesture recognizer's rotation to zero
        gestureRecognizer.rotation = 0
    }
    
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        // Scale UI element
        transform = transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
        
        // Reset gesture recognizer's scale to 1
        gestureRecognizer.scale = 1
    }
    
    func setupUIFrameWhenFirstLayout() {}
    
    private func direction(for angle: CGFloat) -> ZLBaseStickerView.Direction {
        // 将角度转换为0~360，并对360取余
        let angle = ((Int(angle) % 360) + 360) % 360
        return ZLBaseStickerView.Direction(rawValue: angle) ?? .up
    }
    
    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        superview?.bringSubviewToFront(self)
        delegate?.stickerDidTap(self)
        startTimer()
        
    }
    
    @objc func closeAction(_ ges: UITapGestureRecognizer) {
        
        setOperation(false)
        gesIsEnabled = false
        onOperation = false
        moveToAshbin()
        
    }
    
    @objc func closeActionButton(sender: UIButton) {
        
        setOperation(false)
        gesIsEnabled = false
        onOperation = false
        moveToAshbin()
        
    }
    
    @objc func centerTextActionButton(sender: UIButton) {
        
        setTextAlighnment()
        
    }
    
    func setTextAlighnment() {}
    
    func setupBorder() {
//        border = CAShapeLayer(layer: layer)
//        border?.strokeColor = borderColor?.cgColor
//        border?.fillColor = nil
//        border?.lineDashPattern = [5, 2]
//        border?.lineWidth = 1
//        border?.cornerRadius = globalInset! - 2
//        border?.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        
        // Add the dashed border to the view's layer
        dashedBorder.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        dashedBorder.lineDashPattern = [5, 2] //[4, 4]
        dashedBorder.frame = borderView.bounds
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(rect: borderView.bounds).cgPath
        
        borderView.layer.addSublayer(dashedBorder)
        
    }
    
    @objc func longPress(gesture: UIRotationGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            print("Long Press")
            rotationActionButton(sender: gesture)
        }
    }
    
    func rotationActionButton(sender: UIRotationGestureRecognizer) {
        rotationAction(sender)
    }
    
    @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        let scale = min(maxGesScale, gesScale * ges.scale)
        ges.scale = 1

        guard scale != gesScale else {
            return
        }

        gesScale = scale
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            setOperation(false)
        }
    }
    
    @objc func pinchActionTapped(_ ges: UIPinchGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        //pinchGes.isEnabled = false
        //panGes.isEnabled = false
        
        let scale = min(maxGesScale, gesScale * ges.scale)
        ges.scale = 1

        guard scale != gesScale else {
            return
        }

        gesScale = scale
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            setOperation(false)
        }
    }
    
    @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        gesRotation += ges.rotation
        ges.rotation = 0
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            setOperation(false)
        }
    }
    
    func magnitude(vector: CGPoint) -> CGFloat {
        return sqrt(pow(vector.x, 2) + pow(vector.y, 2))
    }
    
//    func updateGuideLinesVisibility() {
////        let guideLinesHidden = !isViewTouchingEdges()
////        topGuideLine.isHidden = guideLinesHidden
////        bottomGuideLine.isHidden = guideLinesHidden
////        leftGuideLine.isHidden = guideLinesHidden
////        rightGuideLine.isHidden = guideLinesHidden
//
//        let viewCenter = center
//        let guideLineLength: CGFloat = min(bounds.width, bounds.height) * 0.8
//
//        topGuideLine.isHidden = viewCenter.y > guideLineLength / 2
//        bottomGuideLine.isHidden = viewCenter.y < bounds.height - guideLineLength / 2
//        leftGuideLine.isHidden = viewCenter.x > guideLineLength / 2
//        rightGuideLine.isHidden = viewCenter.x < bounds.width - guideLineLength / 2
//
//    }
//
//    func isViewTouchingEdges() -> Bool {
//        let viewFrame = frame
//        let viewFrameInSuperview = superview?.convert(viewFrame, to: nil)
//
//        if let superviewFrame = superview?.bounds {
//            if viewFrameInSuperview?.intersects(superviewFrame) ?? false {
//                return true
//            }
//        }
//
//        return false
//    }
    
    private var guideDirection: GuideDirection = .none
    
    func setGuideDirection(_ direction: GuideDirection) {
        guideDirection = direction
    }
    
    func resetGuideDirection() {
        guideDirection = .none
    }
    
//    override func draw(_ rect: CGRect) {
//            let context = UIGraphicsGetCurrentContext()
//
//            // Set the guideline color and width
//            context?.setStrokeColor(UIColor.red.cgColor)
//            context?.setLineWidth(1.0)
//
//            // Draw the guideline based on its orientation
//            if isVertical {
//                let xPos = rect.width / 2
//                context?.move(to: CGPoint(x: xPos, y: 0))
//                context?.addLine(to: CGPoint(x: xPos, y: rect.height))
//            } else {
//                let yPos = rect.height / 2
//                context?.move(to: CGPoint(x: 0, y: yPos))
//                context?.addLine(to: CGPoint(x: rect.width, y: yPos))
//            }
//
//            context?.strokePath()
//        }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let bounds = self.bounds
        let centerX = bounds.midX
        let centerY = bounds.midY

        // Set the line color and width
        UIColor.red.setStroke()
        context.setLineWidth(2.0)

        switch guideDirection {
        case .top:
            context.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            //context.strokePath()
        case .bottom:
            context.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            //context.strokePath()
        case .left:
            context.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            context.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            //context.strokePath()
        case .right:
            context.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            //context.strokePath()
        case .centerX:
            context.move(to: CGPoint(x: centerX, y: bounds.minY))
            context.addLine(to: CGPoint(x: centerX, y: bounds.maxY))
            //context.strokePath()
        case .centerY:
            context.move(to: CGPoint(x: bounds.minX, y: centerY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: centerY))
            //context.strokePath()
        default:
            break
        }
    }
    
    private func getGuideDirection(for translation: CGPoint) -> GuideDirection {
        let angle = atan2(translation.y, translation.x)

        if translation.y < 0 && abs(angle) < .pi / 4 {
            return .top
        } else if translation.y > 0 && abs(angle) < .pi / 4 {
            return .bottom
        } else if translation.x < 0 && abs(angle) > .pi / 4 {
            return .left
        } else if translation.x > 0 && abs(angle) > .pi / 4 {
            return .right
        } else if abs(angle) < .pi / 4 {
            return .centerX
        } else {
            return .centerY
        }
    }
    
    private func drawTopGuideLine() {
        // Draw the guide line for top direction
        
        let topPoint = CGPoint(x: (superview!.frame.width/2), y: 0.0)
        
    }
    
    
    
    private func drawBottomGuideLine() {
        // Draw the guide line for bottom direction
        
        
        
    }
    
    private func drawLeftGuideLine() {
        // Draw the guide line for left direction
        
        
        
    }
    
    private func drawRightGuideLine() {
        // Draw the guide line for right direction
        
        
        
    }
    
    private func drawCenterXGuideLine() {
        // Draw the guide line for centerX direction
        
        
        
    }
    
    private func drawCenterYGuideLine() {
        // Draw the guide line for centerY direction
        
        
        
    }
    
    @objc func panAction(_ ges: UIPanGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        let point = ges.translation(in: superview)
        gesTranslationPoint = CGPoint(x: point.x / originScale, y: point.y / originScale)
        
        //getGuideDirection(for: point)
        
        if ges.state == .began {
            getGuideDirection(for: point)
            setOperation(true)
        } else if ges.state == .changed {
            let guideDirection = getGuideDirection(for: point)
            setGuideDirection(guideDirection)
            setNeedsDisplay()
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            resetGuideDirection()
            totalTranslationPoint.x += point.x
            totalTranslationPoint.y += point.y
            setOperation(false)
            
            let direction = direction(for: originAngle)
            if direction == .right {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
            } else if direction == .bottom {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
            } else if direction == .left {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
            } else {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
            }
            
            gesTranslationPoint = .zero
        }
        
        //TODO: - add center and top and bottom GuidesDirection
        
////        let translation = ges.translation(in: superview)
////        let velocity = ges.velocity(in: superview)
////        let magVelocity = magnitude(vector: velocity)
////        let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
////        let speed = min(max(magnitude, 500), 1000)
////        let directionn = CGVector(dx: velocity.x / magnitude, dy: velocity.y / magnitude)
////        let scaledVelocity = CGVector(dx: directionn.dx * speed / 1000, dy: directionn.dy * speed / 1000)
////        let newCenter = CGPoint(x: ges.view!.center.x + translation.x + scaledVelocity.dx, y: ges.view!.center.y + translation.y + scaledVelocity.dy)
////        ges.view?.center = newCenter
////        ges.setTranslation(.zero, in: superview)
//
//        let translation = ges.translation(in: superview)
//
//        let velocity = ges.velocity(in: superview)
//        let magVelocity = magnitude(vector: velocity)
//
//        let translationS = ges.translation(in: superview)
//        var targetPoint = CGPoint(x: center.x + translationS.x, y: center.y + translationS.y)
//        var realImageRect = CGRect.zero
//        var realImageCenter = CGPoint.zero
//        if let imageView = superview as? ZLImageStickerView { // as ARBStickerImageView
//            let image = imageView.image
//            realImageRect = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
//            realImageCenter = CGPoint(x: realImageRect.width/2, y: realImageRect.height/2)
//
//            let imageTopEdgee = realImageRect.origin.y
//            let imageLeftEdgee = realImageRect.origin.x
//            let imageRightEdgee = realImageRect.origin.x + realImageRect.size.width
//            let imageBottomEdgee = realImageRect.origin.y + realImageRect.size.height
//
//            let imageCenterXe = realImageRect.origin.x + (realImageRect.size.width / 2)
//            let imageCenterYe = realImageRect.origin.y + (realImageRect.size.height / 2)
//
//            print("Image Top Edge: \(imageTopEdgee)")
//            print("Image Left Edge: \(imageLeftEdgee)")
//            print("Image Right Edge: \(imageRightEdgee)")
//            print("Image Bottom Edge: \(imageBottomEdgee)")
//            print("Image Center X: \(imageCenterXe)")
//            print("Image Center Y: \(imageCenterYe)")
//
//        }
//        let stickerWidth = frame.size.width
//        let stickerHeight = frame.size.height
//        //25 + 150
//        // 175
//        targetPoint.x = max(realImageRect.origin.x - stickerWidth * 0.3, targetPoint.x);
//        targetPoint.y = max(realImageRect.origin.y - stickerHeight * 0.3 + 10.0, targetPoint.y);
//        targetPoint.x = min(realImageRect.origin.x + realImageRect.size.width + stickerWidth * 0.3, targetPoint.x);
//        targetPoint.y = min(realImageRect.origin.y + realImageRect.size.height + stickerHeight * 0.3 - 10.0, targetPoint.y);
//
//        //print("recognizer.state = \(recognizer.state.rawValue)")
//        let direction2 = ges.direction(in: self)
//
//        if direction2.contains(.Left) {
//            //print("----------------------- Moving Left ----------------------")
//            print("----------------------- Moving Left ----------------------")
//        }
//        if direction2.contains(.Right) {
//            //print("----------------------- Moving Right ----------------------")
//            print("----------------------- Moving Right ----------------------")
//        }
//        if direction2.contains(.Up) {
//            //print("----------------------- Moving Up ----------------------")
//            print("----------------------- Moving Up ----------------------")
//        }
//        if direction2.contains(.Down) {
//            //print("----------------------- Moving Down ----------------------")
//            print("----------------------- Moving Down ----------------------")
//        }
//
//        print(" velocity magnitue = \(magVelocity)")
//
//        var changeX = (ges.view?.center.x)! - translation.x
//        var changeY = (ges.view?.center.y)! - translation.y
//
//        let labelHandlesMargin = CGFloat(15.0)
//        let tollerence = CGFloat(10.0)
//
//        let imageView = ges.view!.superview!
//
//        let labelLeftEdge = ((ges.view?.center.x)! - ((ges.view?.frame.width)! / 2))
//
//        let labelRightEdge = (imageView.frame.width) - (((ges.view?.center.x)! + CGFloat(((ges.view?.frame.width)! / 2))) )
//
//        let labelTopEdge = ((ges.view?.center.y)! - ((ges.view?.frame.height)! / 2)) + labelHandlesMargin
//
//        // print("label recognizer.view? frame = \(recognizer.view?.frame)")
//
//
//        let labelBottomEdge = (imageView.frame.height) - ((ges.view?.center.y)! + ((ges.view?.frame.height)! / 2))
//
//
//        let labelX = (ges.view!.center.y) - (imageView.frame.height/2)
//        let labelY = (ges.view!.center.x) - (imageView.frame.width/2)
//
//
//        // print("center point = \(((realImageCenter.y) - CGFloat(((realImageRect.height) / 2))))")
//
//        // print("realImageRect y = \(realImageRect.origin.y)")
//        // print("recognizer.view?.frame y = \(String(describing: recognizer.view?.frame.origin.y))")
//
//
//
//        let imageTopEdge = realImageRect.origin.y - (ges.view?.frame.origin.y)!
//
//        let imageBottomEdge = (realImageRect.origin.y + realImageRect.size.height) - ((ges.view!.center.y) + ((ges.view?.frame.height)!/2)) + labelHandlesMargin

        if ges.state == .began  { //|| ges.state == .changed
            
            drawGuidelines(sticker: ges.view!)
            
//            // print("print 1")
//
////            if magVelocity > 80 && magVelocity < 8 {
////                ges.view?.center = CGPoint(x: changeX, y: changeY)
////                ges.setTranslation(CGPoint.zero, in: ges.view)
////                return
////            }
//
//            
//            
//            
//            if imageBottomEdge <= tollerence && imageBottomEdge > 0.0 {
//                if  direction2.contains(.Down) {
//
//                    changeY = realImageRect.size.height + (((ges.view?.superview?.frame.size.height)! - realImageRect.size.height) / 2) - ((ges.view?.frame.height)! / 2) + labelHandlesMargin
//
//                    if !snapGuides[7] {
//                        drawImageBottomGuideLine((ges.view)!, imageRect: realImageRect, superViewRect: (ges.view?.superview!.frame)!)
//                        //Vibration.heavy.vibrate()
//                        lastDirection = direction2
//                    }
//                }
//            } else {
//                removeImageBottomGuideLine((ges.view)!)
//            }
//
//            if imageTopEdge <= tollerence && imageTopEdge > 0.0 {
//                if  direction2.contains(.Up) {
//                    changeY = realImageRect.origin.y + ((ges.view?.frame.height)! / 2) - labelHandlesMargin
//                    if !snapGuides[6] {
//                        drawImageTopGuideLine((ges.view)!, imageRect: realImageRect)
//                        //Vibration.heavy.vibrate()
//                        lastDirection = direction2
//                    }
//                }
//            } else {
//                removeImageTopGuideLine((ges.view)!)
//            }
//
//            //Draw Center Y Guide
//            if labelY <= tollerence && labelY > 0.0 {
//                if  direction2.contains(.Left) {
//                    changeX = imageView.frame.width/2 + 1.0
//                    if !snapGuides[5] {
//                        drawCenterYGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                        lastDirection = direction2
//                    }
//                }
//            } else {
//                removeCenterYGuideLine((ges.view)!)
//            }
//
//            //Draw Center X Guide
//            if labelX <= tollerence && labelX > 0.0 {
//                if  direction2.contains(.Up) {
//                    changeY = imageView.frame.height/2 + 1.0
//                    if !snapGuides[4] {
//                        drawCenterXGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                        lastDirection = direction2
//                    }
//                }
//            } else {
//                removeCenterXGuideLine((ges.view)!)
//            }
//
//
//            //Draw Bottom Guide
//            if labelBottomEdge <= tollerence && labelBottomEdge > 0.0 {
//                if  !direction2.contains(.Up) {
//                    changeY = (imageView.frame.height) - ((ges.view?.frame.height)! / 2) + labelHandlesMargin
//                    if !snapGuides[3] {
//                        drawBottomGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                    }
//                }
//            } else {
//                removeBottomGuideLine((ges.view)!)
//            }
//
//            //Draw Top Guide
//            if labelTopEdge <= tollerence && labelTopEdge > 0.0 {
//                if  !direction2.contains(.Down) {
//                    changeY = ((ges.view?.frame.height)! / 2) - labelHandlesMargin
//                    if !snapGuides[2] {
//                        drawTopGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                    }
//                }
//            } else {
//                removeTopGuideLine((ges.view)!)
//            }
//
//            //Draw Left Guide
//            if labelLeftEdge <= tollerence && labelLeftEdge > 0.0 {
//                if  !direction2.contains(.Right) {
//                    changeX = ((ges.view?.frame.width)! / 2) - labelHandlesMargin
//                    if !snapGuides[0] {
//                        drawLeftGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                    }
//                }
//            } else {
//                removeLeftGuideLine((ges.view)!)
//            }
//
//            //Draw Right Guide
//            if labelRightEdge <= tollerence && labelRightEdge > 0.0 {
//                if  !direction2.contains(.Left) {
//                    changeX = (imageView.frame.width) - (((ges.view?.frame.width)! / 2) - labelHandlesMargin)
//                    if !snapGuides[1] {
//                        drawRightGuideLine((ges.view)!)
//                        //Vibration.heavy.vibrate()
//                    }
//                }
//            } else {
//                removeRightGuideLine((ges.view)!)
//            }
//
//            //ges.view?.center = CGPoint(x: changeX, y: changeY)
//            //ges.setTranslation(CGPoint.zero, in: ges.view)

        }

        if ges.state == .ended {
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                if let layers = self.superview?.layer.sublayers?.filter({$0.name == "TopEdge" || $0.name == "CenterY" || $0.name == "ImageBottom" || $0.name == "ImageTop" || $0.name == "CenterX" || $0.name == "BottomEdge" ||  $0.name == "LeftEdge" ||  $0.name == "RightEdge" }) {
//                    _ = layers.map { layer in
//                        layer.removeFromSuperlayer()
//                    }
//                }
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let layers = ges.view?.layer.sublayers?.filter({$0.name == "TopEdge" || $0.name == "CenterY" || $0.name == "ImageBottom" || $0.name == "ImageTop" || $0.name == "CenterX" || $0.name == "BottomEdge" ||  $0.name == "LeftEdge" ||  $0.name == "RightEdge" }) {
                    _ = layers.map { layer in
                        layer.removeFromSuperlayer()
                    }
                }
            }
            
        }
        
        //TODO: - end
        
    }
    
    //TODO: - DrawGuidelines add center and top and bottom GuidesDirection
    
    func drawGuidelines(sticker: UIView) {
        // Remove any existing guidelines
        //sticker.layer.sublayers?.filter { $0.name == "guideline" }.forEach { $0.removeFromSuperlayer() }
        
        // Draw top guideline
        let topGuideLine = CALayer()
        topGuideLine.name = "ImageTop" //"guideline"
        topGuideLine.backgroundColor = UIColor.red.cgColor
        topGuideLine.frame = CGRect(x: 0, y: sticker.frame.minY, width: sticker.frame.width, height: 1)
        sticker.layer.addSublayer(topGuideLine)
        
        // Draw left guideline
        let leftGuideLine = CALayer()
        leftGuideLine.name = "LeftEdge" //"guideline"
        leftGuideLine.backgroundColor = UIColor.red.cgColor
        leftGuideLine.frame = CGRect(x: sticker.frame.minX, y: 0, width: 1, height: sticker.frame.height)
        sticker.layer.addSublayer(leftGuideLine)
        
        // Draw right guideline
        let rightGuideLine = CALayer()
        rightGuideLine.name = "RightEdge" //"guideline"
        rightGuideLine.backgroundColor = UIColor.red.cgColor
        rightGuideLine.frame = CGRect(x: sticker.frame.maxX, y: 0, width: 1, height: sticker.frame.height)
        sticker.layer.addSublayer(rightGuideLine)
        
        // Draw bottom guideline
        let bottomGuideLine = CALayer()
        bottomGuideLine.name = "ImageBottom" //"guideline"
        bottomGuideLine.backgroundColor = UIColor.red.cgColor
        bottomGuideLine.frame = CGRect(x: 0, y: sticker.frame.maxY, width: sticker.frame.width, height: 1)
        sticker.layer.addSublayer(bottomGuideLine)
        
        // Draw center X guideline
        let centerXGuideLine = CALayer()
        centerXGuideLine.name = "CenterX" //"guideline"
        centerXGuideLine.backgroundColor = UIColor.red.cgColor
        centerXGuideLine.frame = CGRect(x: 0, y: sticker.frame.midY, width: sticker.frame.width, height: 1)
        sticker.layer.addSublayer(centerXGuideLine)
        
        // Draw center Y guideline
        let centerYGuideLine = CALayer()
        centerYGuideLine.name = "CenterY" //"guideline"
        centerYGuideLine.backgroundColor = UIColor.red.cgColor
        centerYGuideLine.frame = CGRect(x: sticker.frame.midX, y: 0, width: 1, height: sticker.frame.height)
        sticker.layer.addSublayer(centerYGuideLine)
    }
    
    //TODO: - end
    
    @objc func panActionTapped(_ ges: UIPanGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        //panGes.isEnabled = false
        //pinchGes.isEnabled = false
        
        let point = ges.translation(in: superview)
        gesTranslationPoint = CGPoint(x: point.x / originScale, y: point.y / originScale)
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            totalTranslationPoint.x += point.x
            totalTranslationPoint.y += point.y
            setOperation(false)
            let direction = direction(for: originAngle)
            if direction == .right {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
            } else if direction == .bottom {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
            } else if direction == .left {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
            } else {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
            }
            
            
            
            gesTranslationPoint = .zero
        }
    }
    
    func setOperation(_ isOn: Bool) {
        if isOn, !onOperation {
            onOperation = true
            cleanTimer()
            borderView.layer.borderColor = UIColor.white.cgColor
            superview?.bringSubviewToFront(self)
            delegate?.stickerBeginOperation(self)
        } else if !isOn, onOperation {
            onOperation = false
            startTimer()
            delegate?.stickerEndOperation(self, panGes: panGes)
        }
    }
    
    func updateTransform() {
        var transform = originTransform
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        //resizeView?.transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Rotate must after scale.
        transform = transform.rotated(by: gesRotation)
        //rotateView?.transform = transform.rotated(by: gesRotation)
        self.transform = transform
        
        delegate?.stickerOnOperation(self, panGes: panGes)
    }
    
    @objc func updateResizeTransform(_ ges: UIPanGestureRecognizer) {
        var transform = originTransform
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        //resizeView?.transform = transform.scaledBy(x: gesScale, y: gesScale)
        
        self.transform = transform
        
        delegate?.stickerOnOperation(self, panGes: panGes)
    }
    
    @objc func updateRotateTransform(_ ges: UIPanGestureRecognizer) {
        var transform = originTransform
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        
        // Rotate must after scale.
        transform = transform.rotated(by: gesRotation)
        self.transform = transform
        
        delegate?.stickerOnOperation(self, panGes: panGes)
    }
    
    @objc func rotateViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
        touchLocation = recognizer.location(in: self.superview)
        
        //print("self.frame = \(self.bounds)")
        //print("self.frame = \(self.frame)")
        let center = CalculateFunctions.CGRectGetCenter(self.frame)
        //print("center = \(center)")

        switch recognizer.state {
        case .began:
            deltaAngle = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x) - CalculateFunctions.CGAffineTrasformGetAngle(self.transform)
            initialBounds = self.bounds
            initialDistance = CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)
            
        case .changed:
            
            let ang = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x)
            
            let angleDiff = deltaAngle! - ang
            
            deltaAngleDiff = angleDiff
            self.transform = CGAffineTransform(rotationAngle: -angleDiff)
            self .layoutIfNeeded()
           
        case .ended:
            
            
            self.refresh()
            
        default:break
            
        }
    }
    
    internal func refresh() {
        if let superView: UIView = self.superview {
            let transform: CGAffineTransform = superView.transform
            let scale = CalculateFunctions.CGAffineTransformGetScale(transform)
            let t = CGAffineTransform(scaleX: scale.width, y: scale.height)
            self.closeView?.transform = t.inverted()
            self.rotateView?.transform = t.inverted()
            self.centerView?.transform = t.inverted()
            
        }
    }
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView
                
                if textView.font!.pointSize * recognizer.scale < 90 {
                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                    textView.font = font
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                } else {
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                }
                
                
                textView.setNeedsDisplay()
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
            view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform  = previouTransform
            }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    @objc private func hideBorder() {
        borderView.layer.borderColor = UIColor.clear.cgColor
        
        // Remove the dashed border from the view's layer
        dashedBorder.removeFromSuperlayer()
        
        rotateView?.isHidden = true
        closeView?.isHidden = true
        centerView?.isHidden = true
        resizeView?.isHidden = true
    }
    
    func startTimer() {
        cleanTimer()
        borderView.layer.borderColor = UIColor.white.cgColor
        //borderView.layer.addSublayer(border!)
        
        // Add the dashed border to the view's layer
        dashedBorder.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.frame = borderView.bounds
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(rect: borderView.bounds).cgPath
        
        borderView.layer.addSublayer(dashedBorder)
        
        rotateView?.isHidden = false
        closeView?.isHidden = false
        centerView?.isHidden = false
        resizeView?.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 2, target: ZLWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ZLBaseStickerView: ZLStickerViewAdditional {
    func resetState() {
        onOperation = false
        cleanTimer()
        hideBorder()
    }
    
    func moveToAshbin() {
        cleanTimer()
        removeFromSuperview()
        let objToBeSent = "Test Message from Notification"
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: objToBeSent)
    }
    
    func addScale(_ scale: CGFloat) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        
        var origin = frame.origin
        origin.x *= scale
        origin.y *= scale
        
        let newSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        let newOrigin = CGPoint(x: frame.minX + (frame.width - newSize.width) / 2, y: frame.minY + (frame.height - newSize.height) / 2)
        let diffX: CGFloat = (origin.x - newOrigin.x)
        let diffY: CGFloat = (origin.y - newOrigin.y)
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: diffY, y: -diffX)
            originTransform = originTransform.translatedBy(x: diffY / originScale, y: -diffX / originScale)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -diffX, y: -diffY)
            originTransform = originTransform.translatedBy(x: -diffX / originScale, y: -diffY / originScale)
        } else if direction == .left {
            transform = transform.translatedBy(x: -diffY, y: diffX)
            originTransform = originTransform.translatedBy(x: -diffY / originScale, y: diffX / originScale)
        } else {
            transform = transform.translatedBy(x: diffX, y: diffY)
            originTransform = originTransform.translatedBy(x: diffX / originScale, y: diffY / originScale)
        }
        totalTranslationPoint.x += diffX
        totalTranslationPoint.y += diffY
        
        transform = transform.scaledBy(x: scale, y: scale)
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        
        gesScale *= scale
        maxGesScale *= scale
    }
}

extension ZLBaseStickerView {
    
    
}

class CalculateFunctions {
    static func CGRectGetCenter(_ rect: CGRect) -> CGPoint{
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    static func CGRectScale(_ rect: CGRect, wScale: CGFloat, hScale: CGFloat) -> CGRect {
        return CGRect(x: rect.origin.x * wScale, y: rect.origin.y * hScale, width: rect.size.width * wScale, height: rect.size.height * hScale)
    }
    
    static func CGpointGetDistance(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        let fx = point2.x - point1.x
        let fy = point2.y - point1.y
        
        return sqrt((fx * fx + fy * fy))
    }
    
    static func CGAffineTrasformGetAngle(_ t: CGAffineTransform) -> CGFloat{
        return atan2(t.b, t.a)
    }
    
    static func CGAffineTransformGetScale(_ t: CGAffineTransform) -> CGSize {
        return CGSize(width: sqrt(t.a * t.a + t.c + t.c), height: sqrt(t.b * t.b + t.d * t.d))
    }
    
}

extension ZLBaseStickerView {
    
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

