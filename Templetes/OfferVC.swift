//
//  OfferVC.swift
//  Templetes
//
//  Created by ahmed abu elregal on 12/03/2023.
//

import UIKit

class OfferVC: UIViewController {
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var dismissbuttonOutlet: UIButton!
    @IBOutlet weak var limitedOfferLabelOutlet: UILabel!
    @IBOutlet weak var oneMonthOfLabelOutlet: UILabel!
    @IBOutlet weak var premiumLabelOutlet: UILabel!
    @IBOutlet weak var fiftyPercValueOutlet: UILabel!
    @IBOutlet weak var fiftyPercOFFOutlet: UILabel!
    @IBOutlet weak var createWithoutLmitsLabelOutlet: OutlinedText!
    @IBOutlet weak var oneMonthForLabelOutlet: UILabel!
    @IBOutlet weak var oneMonthForValueLabelOutlet: UILabel!
    @IBOutlet weak var thenLabelOutlet: UILabel!
    @IBOutlet weak var continuebuttonOutlet: UIButton!
    @IBOutlet weak var canceAnytimebuttonOutlet: UIButton!
    @IBOutlet weak var termsOfusebuttonOutlet: UIButton!
    @IBOutlet weak var privacyPolicybuttonOutlet: UIButton!
    @IBOutlet weak var restorebuttonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIDesign()
        //setLocalization()
        
    }
    
    func setUIDesign() {
        
        dismissbuttonOutlet.layer.cornerRadius = 20
        continuebuttonOutlet.layer.cornerRadius = 17
        slideView.layer.cornerRadius = 3
        
    }
    
    func setLocalization() {
        
        dismissbuttonOutlet.setTitle("", for: .normal)
        limitedOfferLabelOutlet.text = ""
        oneMonthOfLabelOutlet.text = ""
        premiumLabelOutlet.text = ""
        fiftyPercOFFOutlet.text = ""
        createWithoutLmitsLabelOutlet.text = ""
        oneMonthForLabelOutlet.text = ""
        thenLabelOutlet.text = ""
        continuebuttonOutlet.setTitle("", for: .normal)
        canceAnytimebuttonOutlet.setTitle("", for: .normal)
        termsOfusebuttonOutlet.setTitle("", for: .normal)
        privacyPolicybuttonOutlet.setTitle("", for: .normal)
        restorebuttonOutlet.setTitle("", for: .normal)
        
    }
    
    
}

public class OutlinedText: UILabel {
    internal var mOutlineColor:UIColor?
    internal var mOutlineWidth:CGFloat?
    
    @IBInspectable var outlineColor: UIColor{
        get { return mOutlineColor ?? UIColor.clear }
        set { mOutlineColor = newValue }
    }
    
    @IBInspectable var outlineWidth: CGFloat{
        get { return mOutlineWidth ?? 0 }
        set { mOutlineWidth = newValue }
    }
    
    override public func drawText(in rect: CGRect) {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let c = UIGraphicsGetCurrentContext()
        c?.setLineWidth(outlineWidth)
        c?.setLineJoin(.round)
        c?.setTextDrawingMode(.stroke)
        self.textColor = mOutlineColor;
        super.drawText(in:rect)
        
        c?.setTextDrawingMode(.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in:rect)
        
        self.shadowOffset = shadowOffset
    }
}

