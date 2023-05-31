//
//  ZLInputTextViewController.swift
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

class ZLInputTextViewController: UIViewController {
    
    static let collectionViewHeight: CGFloat = 0 //50
    
    let image: UIImage?
    
    var text: String
    
    var font: UIFont?
    
    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var colorsBtn = UIButton(type: .custom)
    
    var textView: UITextView!
    
    var collectionView: UICollectionView!
    
    var currentTextColor: UIColor
    
    var colorPickerView  =  EFRGBView()
    var cancelColorBtn   =  UIButton(type: .custom)
    var titleTextLabel   =  UILabel()
    var doneColorBtn     =  UIButton(type: .custom)
    var dividerView      =  UIView()
    var alphaLabel  =  UILabel()
    var alphaSlider = UISlider()
    lazy var colorPlate : ColorPickerView =  {
        return ColorPickerView()
    }()
    
    var colorToChange = "text"
    var currentTextAlpha: Float = 1.0 // 0.0
    var strokeAlpha: Float = 5.5 // 0.0
    var strokeColor: UIColor = .clear
    
    /// text, textColor, bgColor
    var endInput: ((String, UIFont, UIColor, UIColor) -> Void)?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(image: UIImage?, text: String? = nil, font: UIFont? = nil, textColor: UIColor? = nil, bgColor: UIColor? = nil) {
        self.image = image
        self.text = text ?? ""
        self.font = font
        if let textColor = textColor {
            currentTextColor = textColor
        } else {
            if !ZLImageEditorConfiguration.default().textStickerTextColors.contains(ZLImageEditorConfiguration.default().textStickerDefaultTextColor) {
                currentTextColor = ZLImageEditorConfiguration.default().textStickerTextColors.first!
            } else {
                currentTextColor = ZLImageEditorConfiguration.default().textStickerDefaultTextColor
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnY = insets.top + 20
        let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLImageEditorLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLImageEditorLayout.bottomToolBtnH)).width + 20
        cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLImageEditorLayout.bottomToolBtnH)
        
        let doneBtnW = localLanguageTextValue(.done).zl.boundingRect(font: ZLImageEditorLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLImageEditorLayout.bottomToolBtnH)).width + 20
        doneBtn.frame = CGRect(x: view.bounds.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLImageEditorLayout.bottomToolBtnH)
        
        textView.frame = CGRect(x: 20, y: cancelBtn.frame.maxY + 20, width: view.bounds.width - 40, height: 150)
        
        if let index = ZLImageEditorConfiguration.default().textStickerTextColors.firstIndex(where: { $0 == self.currentTextColor }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func setupUI() {
        
        view.backgroundColor = .black
        
        let bgImageView = UIImageView(image: image?.zl.blurImage(level: 4))
        bgImageView.frame = view.bounds
        bgImageView.contentMode = .scaleAspectFit
        view.addSubview(bgImageView)
        
        let coverView = UIView(frame: bgImageView.bounds)
        coverView.backgroundColor = .black
        coverView.alpha = 0.4
        bgImageView.addSubview(coverView)
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        cancelBtn.titleLabel?.font = ZLImageEditorLayout.bottomToolTitleFont
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        doneBtn = UIButton(type: .custom)
        doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
        doneBtn.titleLabel?.font = ZLImageEditorLayout.bottomToolTitleFont
        doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        view.addSubview(doneBtn)
        
        textView = UITextView(frame: .zero)
        textView.keyboardAppearance = .dark
        textView.returnKeyType = ZLImageEditorConfiguration.default().textStickerCanLineBreak ? .default : .done
        textView.indicatorStyle = .white
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .zl.editDoneBtnBgColor
        textView.textColor = currentTextColor
        textView.text = text
        textView.font = font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        view.addSubview(textView)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: view.frame.height - ZLInputTextViewController.collectionViewHeight, width: view.frame.width, height: ZLInputTextViewController.collectionViewHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        ZLDrawColorCell.zl.register(collectionView)
        
        //colorPickerView.frame.size = CGSize(width: self.view.frame.width, height: 210)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorPickerView)
        colorPickerView.delegate = self
        colorPickerView.isHidden = true
        colorPickerView.color = .white
        
        colorsBtn.setTitle("Colors", for: .normal)
        colorsBtn.addTarget(self, action: #selector(colorsBtnClick), for: .touchUpInside)
        colorsBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorsBtn)
        
        cancelColorBtn.setTitle("Cancel", for: .normal)
        cancelColorBtn.setTitleColor(.black, for: .normal)
        cancelColorBtn.addTarget(self, action: #selector(cancelColorBtnClick), for: .touchUpInside)
        
        doneColorBtn.setTitle("Done", for: .normal)
        doneColorBtn.setTitleColor(.black, for: .normal)
        doneColorBtn.addTarget(self, action: #selector(doneColorBtnClick), for: .touchUpInside)
        
        titleTextLabel.text = "Colors"
        titleTextLabel.textColor = .black
        titleTextLabel.textAlignment = .center
        
        alphaLabel.textAlignment = .right
        alphaLabel.textAlignment = .right
        alphaLabel.text = "opacity"//.Localised()   //"Alpha"
        alphaLabel.adjustsFontSizeToFitWidth = true
        
        cancelColorBtn.translatesAutoresizingMaskIntoConstraints = false
        doneColorBtn.translatesAutoresizingMaskIntoConstraints = false
        titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        alphaSlider.translatesAutoresizingMaskIntoConstraints = false
        alphaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorPickerView.addSubview(cancelColorBtn)
        colorPickerView.addSubview(titleTextLabel)
        colorPickerView.addSubview(doneColorBtn)
        colorPickerView.addSubview(dividerView)
        colorPickerView.addSubview(alphaSlider)
        colorPickerView.addSubview(alphaLabel)
        
        NSLayoutConstraint.activate([
            
            colorPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            colorPickerView.heightAnchor.constraint(equalToConstant: 275), //260
            
            colorsBtn.topAnchor.constraint(equalTo: doneBtn.bottomAnchor, constant: 2.5),
            colorsBtn.centerXAnchor.constraint(equalTo: doneBtn.centerXAnchor, constant: 0),
            colorsBtn.widthAnchor.constraint(equalToConstant: 60),
            colorsBtn.heightAnchor.constraint(equalToConstant: 34),
            
            titleTextLabel.topAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 8),
            titleTextLabel.centerXAnchor.constraint(equalTo: colorPickerView.centerXAnchor, constant: 0),
            titleTextLabel.widthAnchor.constraint(equalToConstant: 600),
            titleTextLabel.heightAnchor.constraint(equalToConstant: 30),
            
            cancelColorBtn.topAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 8),
            cancelColorBtn.leadingAnchor.constraint(equalTo: colorPickerView.leadingAnchor, constant: 20),
            cancelColorBtn.widthAnchor.constraint(equalToConstant: 60),
            cancelColorBtn.heightAnchor.constraint(equalToConstant: 30),
            
            doneColorBtn.topAnchor.constraint(equalTo: colorPickerView.topAnchor, constant: 8),
            doneColorBtn.trailingAnchor.constraint(equalTo: colorPickerView.trailingAnchor, constant: -20),
            doneColorBtn.widthAnchor.constraint(equalToConstant: 60),
            doneColorBtn.heightAnchor.constraint(equalToConstant: 30),
            
            alphaSlider.bottomAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: -10),
            alphaSlider.trailingAnchor.constraint(equalTo: colorPickerView.trailingAnchor, constant: -25),
            alphaSlider.widthAnchor.constraint(equalToConstant: 190),
            alphaSlider.heightAnchor.constraint(equalToConstant: 40),
            
            alphaLabel.centerYAnchor.constraint(equalTo: alphaSlider.centerYAnchor, constant: 0),
            alphaLabel.trailingAnchor.constraint(equalTo: alphaSlider.leadingAnchor, constant: -5),
            alphaLabel.widthAnchor.constraint(equalToConstant: 60),
            alphaLabel.heightAnchor.constraint(equalToConstant: 21),
            
        ])
        
        createAlphaSlider()
        
    }
    
    @objc func colorsBtnClick() {
        colorPickerView.isHidden = false
        view.endEditing(true)
    }
    
    @objc func cancelColorBtnClick() {
        colorPickerView.isHidden = true
    }
    
    @objc func doneColorBtnClick() {
        colorPickerView.isHidden = false
        let content = textView.text.trimmingCharacters(in: .newlines)
        endInput?(content, textView.font ?? UIFont.systemFont(ofSize: ZLTextStickerView.fontSize), currentTextColor, .clear)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnClick() {
        let content = textView.text.trimmingCharacters(in: .newlines)
        endInput?(content, textView.font ?? UIFont.systemFont(ofSize: ZLTextStickerView.fontSize), currentTextColor, .clear)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.collectionView.frame = CGRect(x: 0, y: self.view.frame.height - keyboardH - ZLInputTextViewController.collectionViewHeight, width: self.view.frame.width, height: ZLInputTextViewController.collectionViewHeight)
        }
    }
    
    func createSegment() {
        
        colorPickerView.layer.masksToBounds = true
        colorPickerView.layer.cornerRadius = 10
        
        
        let text        =  "text"//.Localised()
        let outline     =  "outline"//.Localised()
        let background  =  "background"//.Localised()
        
        //let items = [text, outline, background]         //[ "Text", "Stroke", "Background"]\
        
        let isIpad =  (UIDevice.current.userInterfaceIdiom == .pad)
        
        let font = UIFont.systemFont(ofSize: 17) //font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = UIColor.gray
        appearance.segmentOffSelectionColour = UIColor.white
        appearance.titleOnSelectionFont = font
        appearance.titleOffSelectionFont = font
        appearance.contentVerticalMargin = 5.0
        let segmentView = SMSegmentView(frame: CGRect(x: 10, y: 100, width: isIpad ? 190 : 90, height: 100), dividerColour: UIColor(white: 0.95, alpha: 0.3), dividerWidth: 1.0, segmentAppearance: appearance)
        
        
        segmentView.addSegmentWithTitle(text, onSelectionImage: nil, offSelectionImage: nil)
        segmentView.addSegmentWithTitle(outline, onSelectionImage: nil, offSelectionImage: nil)
        segmentView.addSegmentWithTitle(background, onSelectionImage: nil, offSelectionImage: nil)
        
        segmentView.layer.cornerRadius = 5.0
        
        segmentView.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
        segmentView.selectedSegmentIndex = 0
        segmentView.organiseMode = .vertical
        
        colorPickerView.addSubview(segmentView)
        
        
        colorPlate.frame = CGRect(x: 0, y: 53, width: self.view.frame.width, height: 30) //CGRect(x: 0, y: 35, width: self.view.frame.width, height: 30)
        colorPlate.delegate = self
        colorPlate.style = .circle
        colorPlate.backgroundColor = .clear
        colorPickerView.addSubview(colorPlate)
    }
    
    func createAlphaSlider() {
        
        createSegment()
        
        alphaSlider.minimumValue = 0
        alphaSlider.maximumValue = 1
        alphaSlider.isContinuous = true
        alphaSlider.value = 1
        alphaSlider.addTarget(self, action: #selector(alphaValueChanged(_:)), for: .valueChanged)
        
        let leftTrackImage = #imageLiteral(resourceName: "blackTrack.png")
        alphaSlider.setMinimumTrackImage(leftTrackImage, for: .normal)
        
    }
    
    @objc func indexChanged(_ sender: SMSegmentView) {
        
        switch sender.selectedSegmentIndex {
            
        case 2:
            alphaLabel.text = "opacity"//.Localised()   //"Alpha"
            //alphaLabel?.applyLocalisedFont(type: "normal")
            //alphaSlider.value = pp.backAlpha
            //colorPickerView.color = currentTextColor//pp.backColor
            alphaSlider.minimumValue = 0
            alphaSlider.maximumValue = 1
            colorToChange = "back"
            
        case 0:
            alphaLabel.text = "opacity"//.Localised()   //"Alpha"
            //alphaLabel?.applyLocalisedFont(type: "normal")
            //alphaSlider.value = currentTextColor
            //colorPickerView.color = currentTextColor
            alphaSlider.minimumValue = 0
            alphaSlider.maximumValue = 1
            colorToChange = "text"
            
        case 1:
            alphaSlider.minimumValue = 0
            alphaSlider.maximumValue = 10
            alphaLabel.text = "outline size"//.Localised()    //"Width"
            //alphaLabel?.applyLocalisedFont(type: "normal")
            alphaSlider.value = 0 - strokeAlpha //pp.strokeAlpha          //0 - strokeWidth
            //colorPickerView.color = strokeColor //pp.strokeColor
            //myStrokeColor = pp.strokeColor
            colorToChange = "stroke"
            
        default:
            break
        }
        
    }
    
    @objc func alphaValueChanged(_ sender:UISlider!){
        print(sender.value)
        
        
        switch colorToChange {
            
        case "back":
            //let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(sender.value))
            //textView.backgroundColor = textColorWithAlpha
            break
            
        case "text":
            
            //// Set the desired alpha value using the withAlphaComponent method
            let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(sender.value))
            currentTextAlpha = sender.value
            //textView.textColor = textColorWithAlpha
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the text color attribute for the entire string
            attributedString.addAttribute(.foregroundColor, value: textColorWithAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor.withAlphaComponent(CGFloat(sender.value)), range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: -strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
        case "stroke":
            
            strokeAlpha = sender.value
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the text color attribute for the entire string
            attributedString.addAttribute(.foregroundColor, value: currentTextColor.withAlphaComponent(CGFloat(sender.value)), range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor.withAlphaComponent(CGFloat(sender.value)), range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: -sender.value, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
            break
            
        default:
            break
            
        }
        
    }
    
}

extension ZLInputTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ZLImageEditorConfiguration.default().textStickerTextColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl.identifier, for: indexPath) as? ZLDrawColorCell else { return UICollectionViewCell() }
        
        let c = ZLImageEditorConfiguration.default().textStickerTextColors[indexPath.row]
        cell.color = c
        if c == currentTextColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentTextColor = ZLImageEditorConfiguration.default().textStickerTextColors[indexPath.row]
        textView.textColor = currentTextColor
        //textView.textColor = currentTextColor
        
        // Set the desired alpha value using the withAlphaComponent method
        let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(currentTextAlpha))
        //textView.textColor = textColorWithAlpha
        
        // Create a NSMutableAttributedString with the desired text and attributes
        let attributedString = NSMutableAttributedString(string: textView.text)
        
        // Set the text color attribute for the entire string
        attributedString.addAttribute(.foregroundColor, value: textColorWithAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke color attribute for the entire string
        attributedString.addAttribute(.strokeColor, value: strokeColor.withAlphaComponent(CGFloat(strokeAlpha)), range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke width attribute for the entire string (optional)
        attributedString.addAttribute(.strokeWidth, value: -strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the font size attribute for the entire string
        attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
        
        // Assign the attributed string to the UITextView
        textView.attributedText = attributedString
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
}

extension ZLInputTextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !ZLImageEditorConfiguration.default().textStickerCanLineBreak && text == "\n" {
            doneBtnClick()
            return false
        }
        return true
    }
    
    // Implement the textViewDidBeginEditing delegate method
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.textColor = currentTextColor
        
        // Call a method to update the text attributes when editing begins
        
        // Set the desired alpha value using the withAlphaComponent method
        let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(currentTextAlpha))
        //textView.textColor = textColorWithAlpha
        
        // Create a NSMutableAttributedString with the desired text and attributes
        let attributedString = NSMutableAttributedString(string: textView.text)
        
        // Set the text color attribute for the entire string
        attributedString.addAttribute(.foregroundColor, value: textColorWithAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke color attribute for the entire string
        attributedString.addAttribute(.strokeColor, value: strokeColor.withAlphaComponent(CGFloat(strokeAlpha)), range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke width attribute for the entire string (optional)
        attributedString.addAttribute(.strokeWidth, value: -strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the font size attribute for the entire string
        attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
        
        // Assign the attributed string to the UITextView
        textView.attributedText = attributedString
        
    }
    
    // Implement the textViewDidEndEditing delegate method
    func textViewDidEndEditing(_ textView: UITextView) {
        // Call a method to update the text attributes when editing ends
        
        // Set the desired alpha value using the withAlphaComponent method
        let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(currentTextAlpha))
        //textView.textColor = textColorWithAlpha
        
        // Create a NSMutableAttributedString with the desired text and attributes
        let attributedString = NSMutableAttributedString(string: textView.text)
        
        // Set the text color attribute for the entire string
        attributedString.addAttribute(.foregroundColor, value: textColorWithAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke color attribute for the entire string
        attributedString.addAttribute(.strokeColor, value: strokeColor.withAlphaComponent(CGFloat(strokeAlpha)), range: NSRange(location: 0, length: attributedString.length))
        
        // Set the stroke width attribute for the entire string (optional)
        attributedString.addAttribute(.strokeWidth, value: -strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the font size attribute for the entire string
        attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
        
        // Assign the attributed string to the UITextView
        textView.attributedText = attributedString
        
    }
    
}

//MARK: - EFColorViewDelegate, ColorPickerViewDelegate

extension ZLInputTextViewController: EFColorViewDelegate, ColorPickerViewDelegate {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        
        print(colorPlate.colors[indexPath.row])
        
        switch colorToChange {
            
        case "back":
            
            break
            
        case "text":
            
            print(colorPlate.colors[indexPath.row])
            currentTextColor = colorPlate.colors[indexPath.row]
            //textView.textColor = currentTextColor
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the text color attribute for the entire string
            attributedString.addAttribute(.foregroundColor, value: currentTextColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: 0 - strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
            
        case "stroke":
            
            print(colorPlate.colors[indexPath.row])
            strokeColor = colorPlate.colors[indexPath.row]
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: 0 - strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
        default:
            break
        }
    }
    
    func colorView(colorView: EFColorView, didChangeColor color: UIColor) {
        print(color)
        //        currentTextColor = color
        //        textView.textColor = currentTextColor
        
        print(color)
        
        switch colorToChange {
            
        case "back":
            
            break
            
        case "text":
            
            print(color)
            currentTextColor = color
            //textView.textColor = currentTextColor
            
            //let textColorWithAlpha = currentTextColor.withAlphaComponent(CGFloat(sender.value))
            //textView.textColor = textColorWithAlpha
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the text color attribute for the entire string
            attributedString.addAttribute(.foregroundColor, value: currentTextColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: 0 - strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
        case "stroke":
            
            print(color)
            strokeColor = color
            
            // Create a NSMutableAttributedString with the desired text and attributes
            let attributedString = NSMutableAttributedString(string: textView.text)
            
            // Set the text color attribute for the entire string
            attributedString.addAttribute(.foregroundColor, value: currentTextColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke color attribute for the entire string
            attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the stroke width attribute for the entire string (optional)
            attributedString.addAttribute(.strokeWidth, value: 0 - strokeAlpha, range: NSRange(location: 0, length: attributedString.length))
            
            // Set the font size attribute for the entire string
            attributedString.addAttribute(.font, value: font?.withSize(ZLTextStickerView.fontSize) ?? UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the attributed string to the UITextView
            textView.attributedText = attributedString
            
        default:
            break
        }
        
    }
    
}
