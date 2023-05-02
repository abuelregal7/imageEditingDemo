//
//  BaseScreenViewController.swift
//  Templetes
//
//  Created by ahmed abu elregal on 01/05/2023.
//

import UIKit

class BaseScreenViewController: UIViewController {
    
    @IBOutlet weak var FirstDemoButtonOutlet: UIButton!
    @IBOutlet weak var SecondDemoButtonOutlet: UIButton!
    @IBOutlet weak var ThirdDemoButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirstDemoButtonOutlet.layer.cornerRadius   =  10
        SecondDemoButtonOutlet.layer.cornerRadius  =  10
        ThirdDemoButtonOutlet.layer.cornerRadius  =  10
        
    }
    
    @IBAction func FirstDemoButtonAction(_ sender: Any) {
        
        let VC = ZLImageEditorDemoVC()
        navigationController?.pushViewController(VC, animated: true)
        
    }
    
    @IBAction func SecondDemoButtonAction(_ sender: Any) {
        
        let VC = BrightRoomViewController()
        navigationController?.pushViewController(VC, animated: true)
        
    }
    
    @IBAction func ThirdDemoButtonAction(_ sender: Any) {
        
        let VC = iOSPhotoEditorDemoViewController()
        navigationController?.pushViewController(VC, animated: true)
        
    }
    
}
