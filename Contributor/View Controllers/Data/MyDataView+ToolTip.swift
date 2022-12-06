//
//  MyDataView+ToolTip.swift
//  Contributor
//
//  Created by KiwiTech on 6/22/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Instructions
import SwiftyUserDefaults

extension MyDataViewController: CoachMarksControllerDataSource {
    
func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
    return 4
}

func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
    let screenSize = self.view.bounds.size
    var xOrigin: CGFloat = 0
    var yOrigin: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    let layoutLeadingInset: CGFloat = 10
    let origin: CGFloat = 5
    let lastCellOrigin: CGFloat = 182
    let thirdOrigin: CGFloat = 3
    let layoutLeadingConstant: CGFloat = 18
    let maxWidth: CGFloat = 267
    let gapBetween: CGFloat = 12.0
    
    switch index {
    case 0:
        yOrigin = 35 * (screenSize.height/100)
        xOrigin = 50 * (screenSize.width/100)
        coachMark = coachMarksController.helper.makeCoachMark(
            for: UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: 0, height: 0)),
                    cutoutPathMaker: { (frame: CGRect) -> UIBezierPath in
                        return UIBezierPath(ovalIn: frame.insetBy(dx: 0, dy: 0))
           })
        coachMark?.arrowOrientation = nil
    case 1:
        if let contrl = (adapter.collectionView?.cellForItem(at: IndexPath(item: 0,
                                                                           section: 1)) as? MyDataHeaderCollectionViewCell) {
            let newFrame = contrl.convert(contrl.baseView.frame, to: self.view)
            xOrigin = newFrame.origin.x + origin
            yOrigin = newFrame.origin.y + origin
            width = contrl.baseView.frame.width - layoutLeadingInset
            height = contrl.baseView.frame.height - layoutLeadingInset
        }
        coachMark = coachMarksController.helper.makeCoachMark(
                for: UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: width, height: height))
        )
        coachMark?.arrowOrientation = .top
    case 2:
        if let contrl = adapter.object(atSection: 3) as? DataSurveyCategoriesViewController {
            if let categoryCell = (contrl.collectionView.cellForItem(at: IndexPath(item: 1,
                                                                                   section: 0)) as? DataCategoryCollectionViewCell) {
                let theAttributes = contrl.collectionView.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))
                let cellFrameInSuperview = contrl.collectionView.convert(theAttributes!.frame, to: self.view)
                let newFrame = contrl.collectionView.convert(categoryCell.baseView.frame, to: self.view)
                xOrigin = cellFrameInSuperview.origin.x + thirdOrigin
                yOrigin = newFrame.origin.y
                width = categoryCell.baseView.frame.size.height
                height = categoryCell.baseView.frame.size.height
            }
        }
        coachMark = coachMarksController.helper.makeCoachMark(
            for: UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: width, height: height))
        )
        coachMark?.arrowOrientation = .bottom
       
    case 3:
        if let contrl = adapter.collectionView?.cellForItem(at: IndexPath(item: 0, section: 4)) as? ConnectedAppsCollectionCell {
           let newFrame = contrl.convert(contrl.headerLabel.frame, to: self.view)
           xOrigin = newFrame.origin.x - origin
           yOrigin = newFrame.origin.y - origin
           width = newFrame.size.width + layoutLeadingInset
           height = contrl.headerLabel.frame.size.height + contrl.connectedAppLabel.frame.size.height + layoutLeadingConstant
            coachMark = coachMarksController.helper.makeCoachMark(
                    for: UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: width, height: height))
             )
        } else {
            adapter.scrollViewDelegate = self
            adapter.collectionView?.scrollToItem(at: IndexPath(item: 0,
                                                               section: 4), at: .top, animated: true)
            coachMarksController.flow.pause()
            if let contrl = adapter.collectionView?.cellForItem(at: IndexPath(item: 0,
                                                                              section: 5)) as? ConnectedAppsCollectionCell {
               if let newFrame = scrolledFrame {
                xOrigin = newFrame.origin.x - origin
                yOrigin = newFrame.origin.y - origin
                width = newFrame.size.width + layoutLeadingInset
                height = contrl.headerLabel.frame.size.height + contrl.connectedAppLabel.frame.size.height + layoutLeadingConstant
                coachMark = coachMarksController.helper.makeCoachMark(
                       for: UIView(frame: CGRect(x: xOrigin, y: yOrigin,
                                                 width: width,
                                                 height: height))
                )
               }
            }
        }
        coachMark?.arrowOrientation = .bottom

    default:
        coachMark = coachMarksController.helper.makeCoachMark()
    }
    coachMark?.maxWidth = maxWidth
    coachMark?.gapBetweenCoachMarkAndCutoutPath = gapBetween
    return coachMark!
}

func coachMarksController(
    _ coachMarksController: CoachMarksController,
    coachMarkViewsAt index: Int,
    madeFrom coachMark: CoachMark
) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {

    let coachMarkBodyView = CustomCoachMarkBodyView()
    var coachMarkArrowView: CustomCoachMarkArrowView?

    switch index {
    case 0: configure(view0: coachMarkBodyView)
    case 1: configure(view1: coachMarkBodyView)
    case 2: configure(view2: coachMarkBodyView)
    case 3: configure(view3: coachMarkBodyView)
    default: break
    }
    
    if index == 0 {
        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }
    
    if let arrowOrientation = coachMark.arrowOrientation {
        let view = CustomCoachMarkArrowView(orientation: arrowOrientation)
        coachMarkArrowView?.plate.widthAnchor.constraint(equalToConstant: 29).isActive = true
        coachMarkArrowView = view
    }
    return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
}

private func configure(view0 view: CustomCoachMarkBodyView) {
    view.headerLabel.text = ToolTip.toolTipTitle1.localized()
    view.descLabel.text = ToolTip.toolTipDesc1.localized()
    view.nextButton.setTitle(ToolTip.actionButtonText.localized(), for: .normal)
    view.pageControl.currentPage = 0
}

 private func configure(view1 view: CustomCoachMarkBodyView) {
    view.headerLabel.text = ToolTip.toolTipTitle2.localized()
    view.descLabel.text = ToolTip.toolTipDesc2.localized()
    view.nextButton.setTitle(ToolTip.actionButtonText.localized(), for: .normal)
    view.pageControl.currentPage = 1
}

private func configure(view2 view: CustomCoachMarkBodyView) {
    view.headerLabel.text = ToolTip.toolTipTitle3.localized()
    view.descLabel.text = ToolTip.toolTipDesc3.localized()
    view.nextButton.setTitle(ToolTip.actionButtonText.localized(), for: .normal)
    view.pageControl.currentPage = 2
}

private func configure(view3 view: CustomCoachMarkBodyView) {
    view.headerLabel.text = ToolTip.toolTipTitle4.localized()
    view.descLabel.text = ToolTip.toolTipDesc4.localized()
    view.nextButton.setTitle(ToolTip.finishActionButtonText.localized(), for: .normal)
    view.pageControl.currentPage = 3
  }
}

extension MyDataViewController: UIScrollViewDelegate {
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
     if let contrl = adapter.collectionView?.cellForItem(at: IndexPath(item: 0,
                                                                       section: 5)) as? ConnectedAppsCollectionCell {
        let newFrames = contrl.convert(contrl.headerLabel.frame, to: self.view)
        scrolledFrame = newFrames
        coachMarksController.restoreAfterChangeDidComplete()
        coachMarksController.flow.resume()
     }
  }
}
