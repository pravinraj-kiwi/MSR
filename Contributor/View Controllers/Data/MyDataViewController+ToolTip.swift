//
//  MyDataViewController+ToolTip.swift
//  Contributor
//
//  Created by KiwiTech on 6/22/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Instructions

// MARK: - Protocol Conformance | CoachMarksControllerDataSource
extension MyDataViewController: CoachMarksControllerDataSource {

func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
   return 4
}

func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {

    let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
        return UIBezierPath(rect: frame)
    }

    var coachMark: CoachMark

    switch index {
    case 0:
//            coachMark = coachMarksController.helper.makeCoachMark(for: self.avatar) { (frame: CGRect) -> UIBezierPath in
//                // This will create a circular cutoutPath, perfect for the circular avatar!
//                return UIBezierPath(ovalIn: frame.insetBy(dx: -4, dy: -4))
//            }
//        case 1:
//            coachMark = coachMarksController.helper.makeCoachMark(for: self.handleLabel)
//            coachMark.arrowOrientation = .top
//        case 2:
//            coachMark = coachMarksController.helper.makeCoachMark(
//                for: self.allView,
//                pointOfInterest: self.emailLabel?.center,
//                cutoutPathMaker: flatCutoutPathMaker
//            )
//        case 3:
//            coachMark = coachMarksController.helper.makeCoachMark(
//                for: self.allView,
//                pointOfInterest: self.postsLabel?.center,
//                cutoutPathMaker: flatCutoutPathMaker
//            )

    default:
        coachMark = coachMarksController.helper.makeCoachMark()
    }
    coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
    return coachMark
}

func coachMarksController(
        _ coachMarksController: CoachMarksController,
        coachMarkViewsAt index: Int,
        madeFrom coachMark: CoachMark
    ) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {

    let coachMarkBodyView = CustomCoachMarkBodyView()
    var coachMarkArrowView: CustomCoachMarkArrowView?

    var width: CGFloat = 0.0

    switch index {
    case 0: configure(view0: coachMarkBodyView, andUpdateWidth: &width)
    case 1: configure(view1: coachMarkBodyView, andUpdateWidth: &width)
    case 2: configure(view2: coachMarkBodyView, andUpdateWidth: &width)
    case 3: configure(view3: coachMarkBodyView, andUpdateWidth: &width)
    default: break
    }

    // We create an arrow only if an orientation is provided (i. e., a cutoutPath is provided).
    // For that custom coachmark, we'll need to update a bit the arrow, so it'll look like
    // it fits the width of the view.
    if let arrowOrientation = coachMark.arrowOrientation {
        let view = CustomCoachMarkArrowView(orientation: arrowOrientation)

        // If the view is larger than 1/3 of the overlay width, we'll shrink a bit the width
        // of the arrow.
        let oneThirdOfWidth = self.view.window!.frame.size.width / 3
        let adjustedWidth = width >= oneThirdOfWidth
                                ? width - 2 * coachMark.horizontalMargin
                                : width

        view.plate.widthAnchor.constraint(equalToConstant: adjustedWidth).isActive = true
        coachMarkArrowView = view
    }
    return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
}

func coachMarksController(
        _ coachMarksController: CoachMarksController,
        constraintsForSkipView skipView: UIView,
        inParent parentView: UIView
    ) -> [NSLayoutConstraint]? {

    var constraints: [NSLayoutConstraint] = []
    var topMargin: CGFloat = 0.0

    if !UIApplication.shared.isStatusBarHidden {
        topMargin = UIApplication.shared.statusBarFrame.size.height
    }

    constraints.append(contentsOf: [
        skipView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
        skipView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
    ])

    if UIApplication.shared.isStatusBarHidden {
        constraints.append(contentsOf: [
            skipView.topAnchor.constraint(equalTo: parentView.topAnchor),
            skipView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    } else {
        constraints.append(contentsOf: [
            skipView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: topMargin),
            skipView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    return constraints
}

    // MARK: - Private Helpers
private func configure(view0 view: CustomCoachMarkBodyView,
                           andUpdateWidth width: inout CGFloat) {
    view.headerLabel.text = "New"
    view.hintLabel.text = self.avatarText
    view.nextButton.setTitle(self.nextButtonText, for: .normal)

    if let avatar = self.avatar {
        width = avatar.bounds.width
    }
}

private func configure(view1 view: CustomCoachMarkBodyView,
                           andUpdateWidth width: inout CGFloat) {
    view.headerLabel.text = "New1"
    view.hintLabel.text = self.handleText
    view.nextButton.setTitle(self.nextButtonText, for: .normal)

    if let handleLabel = self.handleLabel {
        width = handleLabel.bounds.width
    }
}

private func configure(view2 view: CustomCoachMarkBodyView,
                           andUpdateWidth width: inout CGFloat) {
    view.headerLabel.text = "New2"
    view.hintLabel.text = self.emailText
    view.nextButton.setTitle(self.nextButtonText, for: .normal)

    if let emailLabel = self.emailLabel {
        width = emailLabel.bounds.width
    }
}

private func configure(view3 view: CustomCoachMarkBodyView,
                           andUpdateWidth width: inout CGFloat) {
    view.headerLabel.text = "New3"
    view.hintLabel.text = self.postsText
    view.nextButton.setTitle(self.nextButtonText, for: .normal)

    if let postsLabel = self.postsLabel {
        width = postsLabel.bounds.width
    }
}

private func configure(view4 view: CustomCoachMarkBodyView,
                           andUpdateWidth width: inout CGFloat) {
    view.headerLabel.text = "New4"
    view.hintLabel.text = self.reputationText
    view.nextButton.setTitle(self.nextButtonText, for: .normal)

    if let reputationLabel = self.reputationLabel {
        width = reputationLabel.bounds.width
    }
 }
}
