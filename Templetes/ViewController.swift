//
//  ViewController.swift
//  Templetes
//
//  Created by ahmed abu elregal on 01/03/2023.
//

import UIKit

struct ProjectProperties {
    
    let haveProjectPropertiesView: Bool?
    let projectPropertiesView: ProjectPropertiesView?
    let haveProjectPropertiesLabel: Bool?
    let projectPropertiesLabel: ProjectPropertiesLabel?
    
}

struct ProjectPropertiesView {
    
    let topView: CGFloat?
    let leadingView: CGFloat?
    let traillingView: CGFloat?
    let bottomView: CGFloat?
    let centerXPositionView: CGFloat?
    let centerYPositionView: CGFloat?
    let heightView: CGFloat?
    let widthView: CGFloat?
    let haveCornerRadiousView: Bool?
    let cornerRadiousView: CGFloat?
    let haveImageView: Bool?
    let haveBackgroundView: Bool?
    let backgroundColorView: UIColor?
    
}

enum UITextAlignment {
    case left
    case right
    case center
}

struct ProjectPropertiesLabel {
    
    let topLabel: CGFloat?
    let leadingLabel: CGFloat?
    let traillingLabel: CGFloat?
    let bottomLabel: CGFloat?
    let centerXPositionLabel: CGFloat?
    let centerYPositionLabel: CGFloat?
    let heightLabel: CGFloat?
    let widthLabel: CGFloat?
    let haveCornerRadiousLabel: Bool?
    let cornerRadiousLabel: CGFloat?
    let haveImageLabel: Bool?
    let haveBackgroundLabel: Bool?
    let backgroundColorLabel: UIColor?
    let labelFontSize: CGFloat?
    let labelFontWeight: UIFont.Weight?
    let labelFont: String?
    let labelTextColor: UIColor?
    let labelTextAlighnment: NSTextAlignment? //UITextAlignment?
    
}

class ViewController: UIViewController {
    
    lazy var backgroundImage: UIImageView = {
        let bgImage = UIImageView()
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        bgImage.image = UIImage(named: "background_shape")
        bgImage.contentMode = .scaleAspectFit
        return bgImage
    }()
    
    lazy var redView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleTextView: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Title"
        textView.numberOfLines = 0
        return textView
    }()
    
    lazy var subTitleTextView: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle SubTitle"
        textView.numberOfLines = 0
        return textView
    }()
    
    lazy var blueView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var pp: ProjectProperties?
    var ppView: ProjectPropertiesView?
    var ppLabel: ProjectPropertiesLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIElementAndProperties()
        
    }
    
    func setUIElementAndProperties() {
        
        
        
        ppView = ProjectPropertiesView(topView: 100.0, leadingView: 0.0, traillingView: 0.0, bottomView: 0.0, centerXPositionView: 0.0, centerYPositionView: 0.0, heightView: 200.0, widthView: 200.0, haveCornerRadiousView: true, cornerRadiousView: 100, haveImageView: false, haveBackgroundView: true, backgroundColorView: .red.withAlphaComponent(0.5))
        
        ppLabel = ProjectPropertiesLabel(topLabel: 25.0, leadingLabel: 10.0, traillingLabel: -10.0, bottomLabel: 0.0, centerXPositionLabel: 0.0, centerYPositionLabel: 0.0, heightLabel: 0.0, widthLabel: 0.0, haveCornerRadiousLabel: false, cornerRadiousLabel: 0.0, haveImageLabel: false, haveBackgroundLabel: false, backgroundColorLabel: .clear, labelFontSize: 18, labelFontWeight: .bold, labelFont: "", labelTextColor: .blue, labelTextAlighnment: .center)
        
        pp = ProjectProperties(haveProjectPropertiesView: true, projectPropertiesView: ppView, haveProjectPropertiesLabel: false, projectPropertiesLabel: ppLabel)
        
        view.addSubview(backgroundImage)
        backgroundImage.addSubview(redView)
        backgroundImage.addSubview(titleTextView)
        backgroundImage.addSubview(subTitleTextView)
        backgroundImage.addSubview(blueView)
        
        redView.backgroundColor = pp?.projectPropertiesView?.backgroundColorView ?? .clear
        redView.layer.cornerRadius = pp?.projectPropertiesView?.cornerRadiousView ?? 0
        
        titleTextView.textColor = pp?.projectPropertiesLabel?.labelTextColor ?? .black
        titleTextView.textAlignment = pp?.projectPropertiesLabel?.labelTextAlighnment ?? .natural
        titleTextView.font = UIFont.systemFont(ofSize: pp?.projectPropertiesLabel?.labelFontSize ?? 17, weight: pp?.projectPropertiesLabel?.labelFontWeight ?? .regular)
        
        subTitleTextView.textColor = .red
        subTitleTextView.textAlignment = .center
        subTitleTextView.font = UIFont.systemFont(ofSize:  17, weight: .regular)
        
        blueView.backgroundColor = .blue.withAlphaComponent(0.5)
        blueView.layer.cornerRadius = 12
        
        NSLayoutConstraint.activate([
            
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            
            redView.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: pp?.projectPropertiesView?.topView ?? 0.0),
            redView.centerXAnchor.constraint(equalTo: backgroundImage.centerXAnchor, constant: pp?.projectPropertiesView?.centerXPositionView ?? 0.0),
            redView.widthAnchor.constraint(equalToConstant: pp?.projectPropertiesView?.widthView ?? 0.0),
            redView.heightAnchor.constraint(equalToConstant: pp?.projectPropertiesView?.heightView ?? 0.0),
            
            titleTextView.topAnchor.constraint(equalTo: redView.bottomAnchor, constant: pp?.projectPropertiesLabel?.topLabel ?? 0.0),
            titleTextView.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: pp?.projectPropertiesLabel?.leadingLabel ?? 0.0),
            titleTextView.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: pp?.projectPropertiesLabel?.traillingLabel ?? 0.0),
            
            subTitleTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: pp?.projectPropertiesLabel?.topLabel ?? 0.0),
            subTitleTextView.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: pp?.projectPropertiesLabel?.leadingLabel ?? 0.0),
            subTitleTextView.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: pp?.projectPropertiesLabel?.traillingLabel ?? 0.0),
            
            blueView.topAnchor.constraint(equalTo: subTitleTextView.bottomAnchor, constant: pp?.projectPropertiesView?.topView ?? 0.0),
            blueView.centerXAnchor.constraint(equalTo: backgroundImage.centerXAnchor, constant: pp?.projectPropertiesView?.centerXPositionView ?? 0.0),
            blueView.widthAnchor.constraint(equalToConstant: pp?.projectPropertiesView?.widthView ?? 0.0),
            blueView.heightAnchor.constraint(equalToConstant: pp?.projectPropertiesView?.heightView ?? 0.0),
            
        ])
        
    }
    
}

