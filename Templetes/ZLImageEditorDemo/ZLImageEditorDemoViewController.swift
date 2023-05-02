//
//  ZLImageEditorDemoViewController.swift
//  Templetes
//
//  Created by ahmed abu elregal on 30/04/2023.
//

import UIKit
import ZLImageEditor

class ZLImageEditorDemoViewController: UIViewController {
    
    let imageEditor = ZLImageEditor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageEditor.delegate = self
        
    }
    
    func editImage() {
        if let image = UIImage(named: "example-image") {
            imageEditor.present(from: self, with: image)
        }
    }
    
    
    
}

extension ZLImageEditorDemoViewController: ZLImageEditorDelegate {
    func imageEditor(_ editor: ZLImageEditor, didFinishEditing editedImage: UIImage?) {
        if let editedImage = editedImage {
            // Handle the edited image
        }
    }
}
