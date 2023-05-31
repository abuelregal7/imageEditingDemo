//
//  ZLImageStickerView.swift
//  ZLImageEditor
//
//  Created by long on 2020/11/20.
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

class ZLImageStickerView: ZLBaseStickerView<ZLImageStickerState> {
    let image: UIImage
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    // Convert all states to model.
    override var state: ZLImageStickerState {
        return ZLImageStickerState(
            image: image,
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint
        )
    }
    
    deinit {
        zl_debugPrint("ZLImageStickerView deinit")
    }
    
    convenience init(from state: ZLImageStickerState) {
        self.init(
            image: state.image,
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
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.image = image
        super.init(
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint,
            showBorder: showBorder
        )
        
        addSubview(imageView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCloseAndRotateView() {
        closeView = UIButton(frame: CGRect(x: -15, y: -15, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6)) //UIImageView(frame: CGRect(x: 0, y: 0, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        closeView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        //closeView!.layer.borderColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        //closeView!.layer.borderWidth = 3
        closeView?.contentMode = .scaleAspectFill
        closeView?.clipsToBounds = true
        closeView?.backgroundColor = UIColor.clear
        closeView?.layer.cornerRadius = globalInset! - 10
        closeView?.setImage(UIImage(named: "cancel"), for: .normal)
        //closeView?.isUserInteractionEnabled = true
        
        addSubview(closeView!)
        //self.bringSubviewToFront(closeView!)
        
        resizeView = UIImageView(frame: CGRect(x: self.bounds.size.width - globalInset! * 2 + 20, y: self.bounds.size.height - globalInset! * 2 + 20, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        resizeView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        resizeView?.backgroundColor = UIColor.clear
        resizeView?.layer.cornerRadius =  globalInset! - 10
        //rotateView?.layer.borderColor = UIColor.white.cgColor
        //rotateView?.layer.borderWidth = 3
        resizeView?.clipsToBounds = true
        resizeView?.image = UIImage(named: "rotate")
        resizeView?.contentMode = .scaleAspectFit
        resizeView?.isUserInteractionEnabled = true
        addSubview(resizeView!)
        //self.bringSubviewToFront(resizeView!)
        
        rotateView = UIImageView(frame: CGRect(x: -15, y: self.bounds.size.height - globalInset! * 2 + 15, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        rotateView?.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        rotateView?.backgroundColor = UIColor.clear
        rotateView?.layer.cornerRadius =  globalInset! - 10
        //rotateView?.layer.borderColor = UIColor.white.cgColor
        //rotateView?.layer.borderWidth = 3
        rotateView?.clipsToBounds = true
        rotateView?.image = UIImage(named: "rotate-option")
        rotateView?.contentMode = .scaleAspectFit
        rotateView?.isUserInteractionEnabled = true
        addSubview(rotateView!)
        //self.bringSubviewToFront(rotateView!)

    }
    
    override func setupUIFrameWhenFirstLayout() {
        imageView.frame = bounds.insetBy(dx: ZLStickerLayout.edgeInset, dy: ZLStickerLayout.edgeInset)
        
        setupCloseAndRotateView()
        
    }
    
    class func calculateSize(image: UIImage, width: CGFloat) -> CGSize {
        let maxSide = width / 2
        let minSide: CGFloat = 100
        let whRatio = image.size.width / image.size.height
        var size: CGSize = .zero
        if whRatio >= 1 {
            let w = min(maxSide, max(minSide, image.size.width))
            let h = w / whRatio
            size = CGSize(width: w, height: h)
        } else {
            let h = min(maxSide, max(minSide, image.size.width))
            let w = h * whRatio
            size = CGSize(width: w, height: h)
        }
        
        size.width += ZLStickerLayout.edgeInset * 2
        size.height += ZLStickerLayout.edgeInset * 2
        return size
    }
}

public class ZLImageStickerState: NSObject {
    let image: UIImage
    let originScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    
    init(
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint
    ) {
        self.image = image
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        super.init()
    }
}
