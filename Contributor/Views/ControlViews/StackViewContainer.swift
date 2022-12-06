//
//  StackViewContainer.swift
//

import UIKit
import SnapKit

class StackViewContainer: UIView {
    let stackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect.zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = superview?.backgroundColor ?? UIColor.white
    }

    func add(view: UIView, insets: UIEdgeInsets? = nil, spacing: CGFloat = 0) {
        var viewToAdd: UIView!
        
        if let insets = insets {
            let wrapper = UIView()
            wrapper.backgroundColor = superview?.backgroundColor ?? UIColor.white
            
            wrapper.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.equalTo(wrapper).offset(insets.left)
                make.right.equalTo(wrapper).offset(-insets.right).priority(999)
                make.top.equalTo(wrapper).offset(insets.top)
                make.bottom.equalTo(wrapper).offset(-insets.bottom)
            }
            
            viewToAdd = wrapper
        }
        else {
            viewToAdd = view
        }
        
        stackView.addArrangedSubview(viewToAdd)
        stackView.setCustomSpacing(spacing, after: viewToAdd)
    }
    
    func remove(view: UIView) {
        view.removeFromSuperview()
    }
}
