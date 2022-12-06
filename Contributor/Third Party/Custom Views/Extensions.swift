// Copyright (c) 2017-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

extension UIView {
    internal func fillSuperview() {
        fillSuperviewVertically()
        fillSuperviewHorizontally()
    }

    internal func fillSuperviewVertically() {
        guard let superview = superview else { return }

        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }

    internal func fillSuperviewHorizontally() {
        guard let superview = superview else { return }

        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
}
public extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String(describing: self)
        guard let viewObj = Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as? T else {
            fatalError("Couldn't instantiate view with identifier \(T.loadNib()) ")
        }
        return viewObj
    }

    class func loadCommanNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String(describing: self)
        guard let viewObj = Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as? T else {
            fatalError("Couldn't instantiate view  with identifier \(T.loadNib()) ")
        }
        return viewObj
    }

    class func loadNib() -> Self {
        return loadNib(self)
    }

    class func loadCommanNib() -> Self {
        return loadCommanNib(self)
    }
}
extension UITableView {
func setEmptyView(title: String, message: String, subColor: UIColor) {
  let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
  let titleLabel = UILabel()
  let messageLabel = UILabel()
  let countLabel = UILabel()
  titleLabel.translatesAutoresizingMaskIntoConstraints = false
  messageLabel.translatesAutoresizingMaskIntoConstraints = false
  countLabel.translatesAutoresizingMaskIntoConstraints = false
  titleLabel.textColor = UIColor.black
  titleLabel.font = Font.bold.of(size: 21)
  messageLabel.textColor = subColor
  messageLabel.font = Font.regular.of(size: 16)
  countLabel.textColor = UIColor.black
  countLabel.font = Font.medium.of(size: 17)
  emptyView.addSubview(titleLabel)
  emptyView.addSubview(messageLabel)
  emptyView.addSubview(countLabel)
  updateConstraintOfEmptyView(emptyView, titleLabel, messageLabel, countLabel)
  titleLabel.text = title
  messageLabel.text = message
  messageLabel.numberOfLines = 0
  countLabel.text = "0"
  countLabel.textAlignment = .center
  messageLabel.textAlignment = .center
  self.backgroundView = emptyView
  self.separatorStyle = .none
}
    
func updateConstraintOfEmptyView(_ emptyView: UIView, _ titleLabel: UILabel,
                                 _ messageLabel: UILabel, _ countLabel: UILabel) {
  titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 20).isActive = true
  titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
  messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7).isActive = true
  messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
  countLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
  countLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 20).isActive = true
}
    
func restore() {
 self.backgroundView = nil
 self.separatorStyle = .singleLine
 }
}
public extension UIView {

    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func gradientBorder(width: CGFloat,
                        colors: [UIColor],
                        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0),
                        andRoundCornersWithRadius cornerRadius: CGFloat = 0) {

        let existingBorder = gradientBorderLayer()
        let border = existingBorder ?? CAGradientLayer()
        border.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y,
                              width: bounds.size.width + width, height: bounds.size.height + width)
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        let maskRect = CGRect(x: bounds.origin.x + width/2, y: bounds.origin.y + width/2,
                              width: bounds.size.width - width, height: bounds.size.height - width)
        mask.path = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let exists = (existingBorder != nil)
        if !exists {
            layer.addSublayer(border)
        }
    }
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}
extension UIView {
    
    enum Direction: Int {
        case topToBottom = 0
        case bottomToTop
        case leftToRight
        case rightToLeft
    }
    
    func applyGradient(colors: [Any]?, locations: [NSNumber]? = [0.0, 1.0], direction: Direction = .topToBottom) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        self.layer.addSublayer(gradientLayer)
    }
}
