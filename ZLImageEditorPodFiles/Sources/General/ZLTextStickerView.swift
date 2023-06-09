//
//  ZLTextStickerView.swift
//  ZLImageEditor
//
//  Created by long on 2020/10/30.
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

class ZLTextStickerView: ZLBaseStickerView<ZLTextStickerState> {
    static let fontSize: CGFloat = 30
    
    override var borderView: UIView {
        return priBorderView
    }
    
    private lazy var priBorderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = ZLStickerLayout.borderWidth
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = textFont ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        label.textColor = textColor
        label.backgroundColor = bgColor
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    var text: String {
        didSet {
            label.text = text
        }
    }
    
    var textColor: UIColor {
        didSet {
            label.textColor = textColor
        }
    }

    var textFont: UIFont? {
        didSet {
            label.font = textFont
        }
    }
    
    // TODO: add text background color
    var bgColor: UIColor {
        didSet {
            label.backgroundColor = bgColor
        }
    }
    
    
    
    // Convert all states to model.
    override var state: ZLTextStickerState {
        return ZLTextStickerState(
            text: text,
            textColor: textColor,
            font: textFont,
            bgColor: bgColor,
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint
        )
    }
    
    deinit {
        zl_debugPrint("ZLTextStickerView deinit")
    }
    
    convenience init(from state: ZLTextStickerState) {
        self.init(
            text: state.text,
            textColor: state.textColor,
            font: state.textFont,
            bgColor: state.bgColor,
            originScale: state.originScale,
            originAngle: state.originAngle,
            originFrame: state.originFrame,
            gesScale: state.gesScale,
            gesRotation: state.gesRotation,
            totalTranslationPoint: state.totalTranslationPoint,
            showBorder: false
        )
    }
    
    init(
        text: String,
        textColor: UIColor,
        font: UIFont? = nil,
        bgColor: UIColor,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.text = text
        self.textColor = textColor
        self.textFont = font
        self.bgColor = bgColor
        super.init(
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint,
            showBorder: showBorder
        )
        
        addSubview(borderView)
        borderView.addSubview(label)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCloseAndRotateView() {
        closeView = UIButton(frame: CGRect(x: 10, y: 5, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6)) //UIImageView(frame: CGRect(x: 0, y: 0, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        closeView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        //closeView!.layer.borderColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        //closeView!.layer.borderWidth = 3
        closeView?.contentMode = .scaleAspectFill
        closeView?.clipsToBounds = true
        closeView?.backgroundColor = UIColor.clear
        closeView?.layer.cornerRadius = globalInset! - 10
        closeView?.setImage(UIImage(named: "cancel"), for: .normal)
        //closeView?.isUserInteractionEnabled = true
        
        self.addSubview(closeView!)
        //self.bringSubviewToFront(closeView!)

        centerView = UIButton(frame: CGRect(x: self.bounds.size.width - globalInset! * 2, y: 0, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        centerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        //closeView!.layer.borderColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        //closeView!.layer.borderWidth = 3
        centerView?.contentMode = .scaleAspectFill
        centerView?.clipsToBounds = true
        centerView?.backgroundColor = UIColor.clear
        centerView?.layer.cornerRadius = globalInset! - 10
        centerView?.setImage(UIImage(named: "centerAlignment"), for: .normal) //.image = UIImage(named: "centerAlignment")
        centerView?.isUserInteractionEnabled = true
        self.addSubview(centerView!)
        //self.bringSubviewToFront(centerView!)

        
        resizeView = UIImageView(frame: CGRect(x: self.bounds.size.width - globalInset! * 2, y: self.bounds.size.height - globalInset! * 2, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        resizeView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        resizeView?.backgroundColor = UIColor.clear
        resizeView?.layer.cornerRadius =  globalInset! - 10
        //rotateView?.layer.borderColor = UIColor.white.cgColor
        //rotateView?.layer.borderWidth = 3
        resizeView?.clipsToBounds = true
        resizeView?.image = UIImage(named: "rotate")
        resizeView?.contentMode = .scaleAspectFit
        resizeView?.isUserInteractionEnabled = true
        self.addSubview(resizeView!)
        //self.bringSubviewToFront(resizeView!)
        
        rotateView = UIImageView(frame: CGRect(x: 10, y: self.bounds.size.height - globalInset! * 2, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        rotateView?.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        rotateView?.backgroundColor = UIColor.clear
        rotateView?.layer.cornerRadius =  globalInset! - 10
        //rotateView?.layer.borderColor = UIColor.white.cgColor
        //rotateView?.layer.borderWidth = 3
        rotateView?.clipsToBounds = true
        rotateView?.image = UIImage(named: "rotate-option")
        rotateView?.contentMode = .scaleAspectFit
        rotateView?.isUserInteractionEnabled = true
        self.addSubview(rotateView!)
        //self.bringSubviewToFront(rotateView!)

    }
    
    override func setupUIFrameWhenFirstLayout() {
        borderView.frame = bounds.insetBy(dx: ZLStickerLayout.edgeInset, dy: ZLStickerLayout.edgeInset)
        label.frame = borderView.bounds.insetBy(dx: ZLStickerLayout.edgeInset, dy: ZLStickerLayout.edgeInset)
        
        setupCloseAndRotateView()
        
    }
    
    override func tapAction(_ ges: UITapGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        if let timer = timer, timer.isValid {
            delegate?.sticker(self, editText: text)
        } else {
            super.tapAction(ges)
        }
    }
    
    override func setTextAlighnment() {
        label.textAlignment = .center
    }
    
    func changeSize(to newSize: CGSize) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        transform = transform.rotated(by: -originAngle.zl.toPi)
        
        // Recalculate current frame.
        let center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        var frame = self.frame
        frame.origin.x = center.x - newSize.width / 2
        frame.origin.y = center.y - newSize.height / 2
        frame.size = newSize
        self.frame = frame
        
        let oc = CGPoint(x: originFrame.midX, y: originFrame.midY)
        var of = originFrame
        of.origin.x = oc.x - newSize.width / 2
        of.origin.y = oc.y - newSize.height / 2
        of.size = newSize
        originFrame = of
        
        borderView.frame = bounds.insetBy(dx: ZLStickerLayout.edgeInset, dy: ZLStickerLayout.edgeInset)
        label.frame = borderView.bounds.insetBy(dx: ZLStickerLayout.edgeInset, dy: ZLStickerLayout.edgeInset)
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        transform = transform.rotated(by: originAngle.zl.toPi)
    }
    
    class func calculateSize(text: String, width: CGFloat, font: UIFont? = nil) -> CGSize {
        let diff = ZLStickerLayout.edgeInset * 2
        let size = text.zl.boundingRect(font: font ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), limitSize: CGSize(width: width - diff, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width + diff * 2, height: size.height + diff * 2)
    }
}

public class ZLTextStickerState: NSObject {
    let text: String
    let textColor: UIColor
    let bgColor: UIColor
    let originScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    let textFont: UIFont?
    
    init(
        text: String,
        textColor: UIColor,
        font: UIFont?,
        bgColor: UIColor,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint
    ) {
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        textFont = font
        super.init()
    }
}
