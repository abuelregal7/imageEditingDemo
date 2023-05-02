//
//  BrightRoomViewController.swift
//  Templetes
//
//  Created by ahmed abu elregal on 27/04/2023.
//

import UIKit
import Brightroom

class BrightRoomViewController: UIViewController {
    
    var imgView = UIImageView()
    var editBtn = UIButton()
    var cropBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.navigationController
        else {
            print("This controller must be in a UINaviagationController !!!")
            view.backgroundColor = .red
            return
        }
        
        // replace with your image resource name
        let imgName: String = "Rectangle 8" //"samplePic"
        
        guard let image = UIImage(named: imgName)
        else {
            print("Could not load image named \"\(imgName)\"!")
            view.backgroundColor = .red
            return
        }
        
        imgView.image = image
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        imgView.layer.cornerRadius = 20
        
        editBtn.setTitle("Start Editing", for: [])
        editBtn.setTitleColor(.white, for: .normal)
        editBtn.setTitleColor(.lightGray, for: .highlighted)
        editBtn.backgroundColor = .systemBlue //editBtn
        editBtn.layer.cornerRadius = 8
        
        cropBtn.setTitle("Start Cropping", for: [])
        cropBtn.setTitleColor(.white, for: .normal)
        cropBtn.setTitleColor(.lightGray, for: .highlighted)
        cropBtn.backgroundColor = .systemYellow //cropBtn
        cropBtn.layer.cornerRadius = 8
        
        [imgView, editBtn, cropBtn].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        
        let g = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            imgView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
            imgView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
            imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor),
            imgView.centerYAnchor.constraint(equalTo: g.centerYAnchor, constant: -80),
            
            editBtn.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 20.0),
            editBtn.widthAnchor.constraint(equalToConstant: 240.0),
            editBtn.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            
            cropBtn.topAnchor.constraint(equalTo: editBtn.bottomAnchor, constant: 20.0),
            cropBtn.widthAnchor.constraint(equalToConstant: 240.0),
            cropBtn.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            
        ])
        
        editBtn.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
        cropBtn.addTarget(self, action: #selector(editCropping(_:)), for: .touchUpInside)
        
        let loader = ColorCubeLoader(bundle: .main)
        //let filters: [FilterColorCube] = try loader.load()
        
        do {
            let filters: [FilterColorCube] = try loader.load()
            ColorCubeStorage.default.filters = filters
        } catch {
            //handle error
            print(error)
        }
        
    }
    
    @objc func editCropping(_ sender: Any?) {
        
        // replace with your image resource name
        let imgName: String = "Rectangle 8" //"samplePic"
        
        guard let uiImage = UIImage(named: imgName)
        else {
            print("Could not load image named \"\(imgName)\"!")
            view.backgroundColor = .red
            return
        }
        let controller = PhotosCropViewController(imageProvider: .init(image: uiImage))
        
        controller.modalPresentationStyle = .fullScreen
        
        controller.handlers.didCancel = { controller in
            controller.dismiss(animated: true, completion: nil)
        }
        
        controller.handlers.didFinish = { [weak self] controller in
            
            controller.dismiss(animated: true, completion: nil)
            
            do {
                
                try controller.editingStack.makeRenderer().render { [weak self] image in
                    // ✅ handle the result image.
                    
                    switch image {
                    case .success(let image):
                        self?.imgView.image = image.uiImage
                    case .failure(let error):
                        print(error)
                    }
                    
                }
                
            } catch _ {
                
            }
            
        }
        
        present(controller, animated: true, completion: nil)
        
    }
    
    @objc func editTapped(_ sender: Any?) {
        
        guard let image = imgView.image
        else {
            print("Could not load image from image view!")
            return
        }
        
        let imageProvider: ImageProvider = ImageProvider(image: image)
        
        let editingStack = EditingStack(imageProvider: imageProvider)
        
        // create the "Classic" editing controller
        let controller = ClassicImageEditViewController(editingStack: editingStack)
        
        // set the closure for NavBar "Cancel" tap
        controller.handlers.didCancelEditing = { [weak self] vc in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        // set the closure for NavBar "Done" tap
        controller.handlers.didEndEditing = { [weak self] vc, editStack in
            guard let self = self else { return }
            
            var img: UIImage!
            do {
                let r = try editStack.makeRenderer().render()
                let imgData = r.makeOptimizedForSharingData(dataType: .png)
                img = UIImage(data: imgData)
            } catch {
                print("error?", error)
            }
            if let img = img {
                self.imgView.image = img
            }
            self.navigationController?.popViewController(animated: true)
            
        }
        
        // push to the editing controller
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
}
