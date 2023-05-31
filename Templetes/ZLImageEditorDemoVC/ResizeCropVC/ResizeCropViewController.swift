//
//  ResizeCropViewController.swift
//  Templetes
//
//  Created by ahmed abu elregal on 28/05/2023.
//

import UIKit

class ResizeCropViewController: UIViewController {
    
    @IBOutlet weak var resizeImageOutlet: UIImageView!
    @IBOutlet weak var ratiosCollectionViewOutlet: UICollectionView!{
        didSet {
            
            ratiosCollectionViewOutlet.delegate = self
            ratiosCollectionViewOutlet.dataSource = self
            
            ratiosCollectionViewOutlet.register(UINib(nibName: "RatiosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RatiosCollectionViewCell")
            
        }
    }
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    var originalImage: UIImage?
    var finalImage: UIImage?
    
    var ratioData = ["1:1", "3:4", "4:3", "2:3", "3:2", "9:16", "16:9"]
    
    var backData: ((_ image: UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // Example usage
        //if let originalImage = originalImage { //UIImage(named: //"your_original_image")
        //    let resizedImage = resizeImageWithAspectRatio(image: //originalImage, targetRatio: 1.0) // Change //targetRatio as needed
        //    // Use the resizedImage as desired
        //    resizeImageOutlet.image = resizedImage
        //    finalImage = resizeImageOutlet.image
        //}
        
        resizeImageOutlet.image = originalImage
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func resizeImageWithAspectRatio(image: UIImage, targetRatio: CGFloat) -> UIImage? {
        let size = image.size
        let originalAspectRatio = size.width / size.height
        
        var newSize: CGSize
        if originalAspectRatio > targetRatio {
            newSize = CGSize(width: size.height * targetRatio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / targetRatio)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }

    //// Example usage
    //if let originalImage = UIImage(named: "your_original_image") {
    //    let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 1.0) // Change targetRatio as needed
    //    // Use the resizedImage as desired
    //}
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.backData?(self.finalImage)
        }
        
    }
    
}

extension ResizeCropViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratioData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = ratiosCollectionViewOutlet.dequeueReusableCell(withReuseIdentifier: "RatiosCollectionViewCell", for: indexPath) as? RatiosCollectionViewCell else { return UICollectionViewCell() }
        
        cell.containerView.layer.cornerRadius = 10
        cell.containerView.layer.masksToBounds = true
        cell.containerView.backgroundColor = .gray.withAlphaComponent(0.7)
        
        cell.ratiosLabelOutlet.text = ratioData[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let initImage = originalImage
        
        if indexPath.item == 0 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 1.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else if indexPath.item == 1 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 3.0/4.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else if indexPath.item == 2 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 4.0/3.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else if indexPath.item == 3 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 2.0/3.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else if indexPath.item == 4 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 3.0/2.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else if indexPath.item == 5 {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 9.0/16.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }else {
            
            if let originalImage = initImage { //UIImage(named: "your_original_image")
                let resizedImage = resizeImageWithAspectRatio(image: originalImage, targetRatio: 16.0/9.0) // Change targetRatio as needed
                // Use the resizedImage as desired
                resizeImageOutlet.image = resizedImage
                finalImage = resizeImageOutlet.image
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ratiosCollectionViewOutlet.frame.size.width - 10) / 5, height: 30.0)
    }
    
}
