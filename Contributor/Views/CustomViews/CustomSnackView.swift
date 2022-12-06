//
//  CustomSnackView.swift
//  Contributor
//
//  Created by KiwiTech on 7/30/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol CustomSnackViewDelegate: class {
    func didTapSnackbar()
}

class CustomSnackView: UIView, NibLoadableView {

@IBOutlet weak var snackView: UIView!
@IBOutlet weak var snackImageView: UIImageView!
weak var snackBarDelegate: CustomSnackViewDelegate?
private var contentView: UIView!

override func awakeFromNib() {
    super.awakeFromNib()
}

override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
}

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
}

func xibSetup() {
    contentView = loadViewFromNib()
    contentView.frame = bounds
    contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
                                    UIView.AutoresizingMask.flexibleHeight]
    addSubview(contentView)
    snackView.snackBarShadow(color: .black, cornerRadius: 24.0, bgColor: UIColor.white.cgColor)
}

func loadViewFromNib() -> UIView! {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
        return view
    }
    return UIView()
}

 @IBAction func clickedOnSnackBar(_ sender: Any) {
    snackBarDelegate?.didTapSnackbar()
 }
}

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

extension UIView {
func snackBarShadow(color: UIColor, cornerRadius: CGFloat, bgColor: CGColor) {
    layer.masksToBounds = false
    layer.cornerRadius = cornerRadius
    layer.backgroundColor = bgColor
    layer.borderColor = UIColor.clear.cgColor
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowOpacity = 0.5
    layer.shadowRadius = 6
  }
}
