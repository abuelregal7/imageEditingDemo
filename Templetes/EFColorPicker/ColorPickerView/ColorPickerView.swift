//
//  ColorPickerView.swift
//  Templetes
//
//  Created by ahmed abu elregal on 15/05/2023.
//

import Foundation
import UIKit

public enum ColorPickerViewStyle {
    case square
    case circle
}

public enum ColorPickerViewSelectStyle {
    case check
    case none
}

@objc public protocol ColorPickerViewDelegateFlowLayout: AnyObject {
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets
}

@objc public protocol ColorPickerViewDelegate: AnyObject {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath)
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath)
    
}

open class ColorPickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Open properties
    
    
    /// Array of UIColor you want to show in the color picker
    open var colors: [UIColor] = [#colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.4274509804, blue: 0, alpha: 1), #colorLiteral(red: 0.9495671391, green: 0.7754515409, blue: 0.8802314401, alpha: 1), #colorLiteral(red: 0.8319657445, green: 0.2168057859, blue: 0.5676339865, alpha: 1), #colorLiteral(red: 0.9249386191, green: 0.5609573722, blue: 0.8168564439, alpha: 1), #colorLiteral(red: 0.5304200649, green: 0.04009822384, blue: 0.1873854399, alpha: 1), #colorLiteral(red: 0.9243058562, green: 0.3443527222, blue: 0.4002547264, alpha: 1),
                                  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) ,#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.9750294089, green: 0.9194865823, blue: 0.5499657989, alpha: 1), #colorLiteral(red: 0.6452634931, green: 0.9104209542, blue: 0.8789985776, alpha: 1), #colorLiteral(red: 0.295001477, green: 0.844276011, blue: 0.8144009709, alpha: 1) ,#colorLiteral(red: 0.8848026395, green: 0.7642249465, blue: 0.2515477836, alpha: 1), #colorLiteral(red: 0.8715274334, green: 0.886290729, blue: 0.9249439836, alpha: 1),
                                  #colorLiteral(red: 0.5499875546, green: 0.4596046805, blue: 0.4179323316, alpha: 1), #colorLiteral(red: 0.1008012816, green: 0.7842002511, blue: 0.8577410579, alpha: 1), #colorLiteral(red: 0.02981702983, green: 0.5718432069, blue: 0.7201122046, alpha: 1), #colorLiteral(red: 0.7351917028, green: 0.8349557519, blue: 0.8238980174, alpha: 1), #colorLiteral(red: 0.2322107255, green: 0.03104410321, blue: 0.09371059388, alpha: 1), #colorLiteral(red: 0.9986304641, green: 0.7618848085, blue: 0.7816841006, alpha: 1), #colorLiteral(red: 0.7224107385, green: 0.2223289609, blue: 0.05707215518, alpha: 1),
                                  #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 0.5949329734, green: 0.04915926605, blue: 0.0620553866, alpha: 1), #colorLiteral(red: 1, green: 0.09019607843, blue: 0.2666666667, alpha: 1), #colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 0.8828088045, green: 0.3177781999, blue: 0.6890564561, alpha: 1),
                                  #colorLiteral(red: 0.9176470588, green: 0.5019607843, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0, blue: 1, alpha: 1), #colorLiteral(red: 0.4130273461, green: 0.06773087382, blue: 0.2894317508, alpha: 1), #colorLiteral(red: 0.0302203428, green: 0.0408777073, blue: 0.2252834737, alpha: 1), #colorLiteral(red: 0.07318016142, green: 0.3239130974, blue: 0.4873319864, alpha: 1), #colorLiteral(red: 0.9503406882, green: 0.2856444716, blue: 0.7133789062, alpha: 1),
                                  #colorLiteral(red: 0.7019607843, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.1215686275, blue: 1, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0.5490196078, green: 0.6196078431, blue: 1, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.02024452016, green: 0.316862613, blue: 0.4545269608, alpha: 1), #colorLiteral(red: 0.0002676551812, green: 0.1217691675, blue: 0.2395747304, alpha: 1), #colorLiteral(red: 0.1117684022, green: 0.4757995605, blue: 0.620968461, alpha: 1), #colorLiteral(red: 0.02717796341, green: 0.6724484563, blue: 0.7684217095, alpha: 1), #colorLiteral(red: 0.3633614182, green: 0.7991134524, blue: 0.7963138223, alpha: 1), #colorLiteral(red: 0.7254901961, green: 0.9647058824, blue: 0.7921568627, alpha: 1), #colorLiteral(red: 0.5992789268, green: 0.8438246846, blue: 0.7603632808, alpha: 1), #colorLiteral(red: 0.6342455149, green: 0.6393113136, blue: 0.6477885842, alpha: 1), #colorLiteral(red: 0.1083159521, green: 0.4573822021, blue: 0.1080957428, alpha: 1), #colorLiteral(red: 0.5471449494, green: 0.8042417765, blue: 0.3162094355, alpha: 1), #colorLiteral(red: 0.5610207319, green: 0.6298261881, blue: 0.1230124608, alpha: 1),
                                  #colorLiteral(red: 0.6599076986, green: 0.8831211925, blue: 0.04317791015, alpha: 1), #colorLiteral(red: 0.8969444036, green: 0.3558069468, blue: 0.07325331122, alpha: 1), #colorLiteral(red: 1, green: 0.8582937717, blue: 0.07775338739, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 1, green: 0.9176470588, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.6590596437, green: 0.9028424621, blue: 0.8105538487, alpha: 1), #colorLiteral(red: 0.8641895652, green: 0.9300099611, blue: 0.7565742731, alpha: 1), #colorLiteral(red: 0.9996599555, green: 0.8297442198, blue: 0.7149035931, alpha: 1), #colorLiteral(red: 1, green: 0.6664668918, blue: 0.6459562182, alpha: 1), #colorLiteral(red: 1, green: 0.5464193821, blue: 0.5809180737, alpha: 1), #colorLiteral(red: 0.9992356896, green: 0.7338040471, blue: 0.9327622056, alpha: 1),
                                  #colorLiteral(red: 0.9948348403, green: 0.7557582855, blue: 0.6292507052, alpha: 1), #colorLiteral(red: 0.8145680428, green: 0.8198444247, blue: 0.8195697665, alpha: 1), #colorLiteral(red: 0.3028336763, green: 0, blue: 0.06460181624, alpha: 1), #colorLiteral(red: 0.4068920612, green: 0.1613940299, blue: 0, alpha: 1), #colorLiteral(red: 0.8308435082, green: 0.1202249303, blue: 0, alpha: 1), #colorLiteral(red: 0.9987302423, green: 0.9219549298, blue: 0.6282841563, alpha: 1),  #colorLiteral(red: 0.2283914089, green: 0.3386088312, blue: 0.4525441527, alpha: 1), #colorLiteral(red: 0.3205202818, green: 0.7264318466, blue: 0.8061371446, alpha: 1), #colorLiteral(red: 0.6704872251, green: 0.9453341365, blue: 0.9615026116, alpha: 1), #colorLiteral(red: 0.6704872251, green: 0.9453341365, blue: 0.9615026116, alpha: 1), #colorLiteral(red: 0.9755929112, green: 0.8990162015, blue: 0.9007774591, alpha: 1), #colorLiteral(red: 0.4979951382, green: 0.4980683923, blue: 0.4979720712, alpha: 1),
                                  #colorLiteral(red: 1, green: 0.8196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.568627451, blue: 0, alpha: 1), #colorLiteral(red: 0.9565220475, green: 0.9376488328, blue: 0.8590474725, alpha: 1), #colorLiteral(red: 0.02602007985, green: 1, blue: 0.9430630207, alpha: 1), #colorLiteral(red: 0.6446042657, green: 0.8981752992, blue: 0.8800004125, alpha: 1), #colorLiteral(red: 0.8608458042, green: 0.9606071115, blue: 0.9407854676, alpha: 1)]
        {
        didSet {
            if colors.isEmpty {
                fatalError("ERROR ColorPickerView - You must set at least 1 color!")
            }
        }
    }
    /// The object that acts as the layout delegate for the color picker
    open weak var layoutDelegate: ColorPickerViewDelegateFlowLayout?
    /// The object that acts as the delegate for the color picker
    open weak var delegate: ColorPickerViewDelegate?
    /// The index of the selected color in the color picker
    open var indexOfSelectedColor: Int? {
        return _indexOfSelectedColor
    }
    /// The index of the preselected color in the color picker
    open var preselectedIndex: Int? {
        didSet {
            if let index = preselectedIndex {
                
                guard index >= 0, colors.indices.contains(index) else {
                    //print("ERROR ColorPickerView - preselectedItem out of colors range")
                    return
                }
                
                _indexOfSelectedColor = index
                
                collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    /// If true, the selected color can be deselected by a tap
    open var isSelectedColorTappable: Bool = true
    /// If true, the preselectedIndex is showed in the center of the color picker
    open var scrollToPreselectedIndex: Bool = false
    /// Style of the color picker cells
    open var style: ColorPickerViewStyle = .circle
    /// Style applied when a color is selected
    open var selectionStyle: ColorPickerViewSelectStyle = .check
    
    // MARK: - Private properties
    
    fileprivate var _indexOfSelectedColor: Int?
    fileprivate lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorPickerCell.self, forCellWithReuseIdentifier: ColorPickerCell.cellIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = .clear
        collectionView.semanticContentAttribute = .forceLeftToRight
        return collectionView
    }()
    
    // MARK: - View management
    
    open override func layoutSubviews() {
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        // Check on scrollToPreselectedIndex
        if preselectedIndex != nil, !scrollToPreselectedIndex {
            // Scroll to the first color
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    // MARK: - Private Methods
    
    private func _selectColor(at indexPath: IndexPath, animated: Bool) {
        
        guard let colorPickerCell = collectionView.cellForItem(at: indexPath) as? ColorPickerCell else { return }
        
        if indexPath.item == _indexOfSelectedColor, !isSelectedColorTappable {
            return
        }
        
        if selectionStyle == .check {
            
            if indexPath.item == _indexOfSelectedColor {
                if isSelectedColorTappable {
                    _indexOfSelectedColor = nil
                    colorPickerCell.checkbox.isOn = false
                }
                return
            }
            
            _indexOfSelectedColor = indexPath.item
            
            colorPickerCell.checkbox.tintColor = colors[indexPath.item].isWhiteText ? .white : .black
//            colorPickerCell.checkbox.setCheckState((colorPickerCell.checkbox.checkState == .checked) ? .unchecked : .checked, animated: animated)
            
            
            
            colorPickerCell.checkbox.isOn = !colorPickerCell.checkbox.isOn
        }
        
        delegate?.colorPickerView(self, didSelectItemAt: indexPath)
    
    }
    
    // MARK: - Public Methods
    
    public func selectColor(at index: Int, animated: Bool) {
        self._selectColor(at: IndexPath(row: index, section: 0),
                          animated: animated)
        
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPickerCell.cellIdentifier, for: indexPath) as! ColorPickerCell
        
        cell.backgroundColor = colors[indexPath.item]
        
        if style == .circle {
            cell.layer.cornerRadius = cell.bounds.width / 2
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let colorPickerCell = cell as! ColorPickerCell
        
        guard selectionStyle == .check else { return }
        
        guard indexPath.item == _indexOfSelectedColor else {
            colorPickerCell.checkbox.isOn = false
            return
        }
        
        colorPickerCell.checkbox.tintColor = colors[indexPath.item].isWhiteText ? .white : .black
        colorPickerCell.checkbox.isOn = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self._selectColor(at: indexPath, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        // Check if the old color cell is showed. If true, it deselects it
        guard let oldColorCell = collectionView.cellForItem(at: indexPath) as? ColorPickerCell else {
            return
        }
        
        if selectionStyle == .check {
            oldColorCell.checkbox.isOn = false
        }
        
        delegate?.colorPickerView?(self, didDeselectItemAt: indexPath)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let layoutDelegate = layoutDelegate,
            let sizeForItemAt = layoutDelegate.colorPickerView?(self, sizeForItemAt: indexPath) {
            return sizeForItemAt
        }
        return DefaultValues.cellSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let layoutDelegate = layoutDelegate, let minimumLineSpacingForSectionAt = layoutDelegate.colorPickerView?(self, minimumLineSpacingForSectionAt: section) {
            return minimumLineSpacingForSectionAt
        }
        return DefaultValues.minimumLineSpacingForSectionAt
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let layoutDelegate = layoutDelegate, let minimumInteritemSpacingForSectionAt = layoutDelegate.colorPickerView?(self, minimumInteritemSpacingForSectionAt: section) {
            return minimumInteritemSpacingForSectionAt
        }
        return DefaultValues.minimumInteritemSpacingForSectionAt
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let layoutDelegate = layoutDelegate, let insetForSectionAt = layoutDelegate.colorPickerView?(self, insetForSectionAt: section) {
            return insetForSectionAt
        }
        return DefaultValues.insets
    }
    
}

extension UIColor {
    
    var redValue: CGFloat{
        return cgColor.components! [0]
    }
    
    var greenValue: CGFloat{
        return cgColor.components! [1]
    }
    
    var blueValue: CGFloat{
        return cgColor.components! [2]
    }
    
    var alphaValue: CGFloat{
        return cgColor.components! [3]
    }
    
    var isWhiteText: Bool {
        
        // non-RGB color
        if cgColor.numberOfComponents == 2 {
            return 0.0...0.5 ~= cgColor.components!.first! ? true : false
        }
        
        let red = self.redValue * 255
        let green = self.greenValue * 255
        let blue = self.blueValue * 255
        
        // https://en.wikipedia.org/wiki/YIQ
        // https://24ways.org/2010/calculating-color-contrast/
        let yiq = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return yiq < 192
    }
    
}
