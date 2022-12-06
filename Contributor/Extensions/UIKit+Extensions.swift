//
//  UIKit+Extensions.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import Foundation
import UIKit
import SnapKit
import CommonCrypto
import Photos

extension UIViewController {
  @objc func setupViews() {
    
  }
  
  @objc func msr_dismiss(_ completion: @escaping () -> Void = {}) {
    dismiss(animated: true, completion: completion)
  }
  
  @objc func dismissSelf() {
    msr_dismiss()
  }
  
  func setTitle(_ title: String?) {
    navigationItem.title = title
  }
  
  func backBarButtonItem(backArrowImage: UIImage = UIImage.init(named: "back-arrow")!) -> UIBarButtonItem {
    return UIBarButtonItem(image: backArrowImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.goBack))
  }
  
  func hideBackButtonTitle() {
    navigationItem.backBarButtonItem = self.hiddenBackBarButtonItem()
  }
  
  func hiddenBackBarButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(title: nil, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
  }
  
  @objc func goBack() {
    navigationController?.popViewController(animated: true)
  }
  
  func embed(viewController: UIViewController) {
    viewController.willMove(toParent: self)
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    viewController.didMove(toParent: self)
  }
}

extension UIView {
  @discardableResult
  static func addUnderline(to: UIView, in inView: UIView, _ inset: UIEdgeInsets = UIEdgeInsets.zero) -> UIView {
    let underline = UIView()
    underline.backgroundColor = Color.border.value
    
    inView.addSubview(underline)
    underline.snp.makeConstraints { (make) in
      make.left.equalTo(to.snp.left).inset(inset.left)
      make.right.equalTo(to.snp.right).inset(inset.right)
      make.top.equalTo(to.snp.bottom).offset(inset.top)
      make.height.equalTo(1)
    }
    
    return underline
  }
  
  func hugContent(in axis: NSLayoutConstraint.Axis) {
    setContentHuggingPriority(UILayoutPriority.required, for: axis)
  }
  
  func removeAllSubviews() {
    self.subviews.forEach { (view) in
      view.removeAllSubviews()
    }
  }

  func bounceBriefly() {
    transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    
    UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction, animations: {
      self.transform = CGAffineTransform.identity
    }, completion: { _ in })
  }
}

extension UINavigationController {
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    func popToVC(ofKind kind: AnyClass) {
        if containsViewController(ofKind: kind) {
            for controller in self.viewControllers {
                if controller.isKind(of: kind) {
                    popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
}

extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    var md5Value: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let d = self.data(using: .utf8) {
            _ = d.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                return ""
            }
        }
        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    func take(_ n: Int) -> String {
        guard n >= 0 else {
            fatalError("n should never negative")
        }
        let index = self.index(self.startIndex, offsetBy: min(n, self.count))
        return String(self[..<index])
    }
}

extension UIViewController {
    func setUpNavBar(backArrowImage: UIImage = UIImage.init(named: "back-arrow")!, _ backArrowText: String = "", titleColor: UIColor = .black) {
      let backbutton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
      backbutton.setImage(backArrowImage, for: .normal)
      backbutton.setTitle(backArrowText, for: .normal)
      backbutton.setTitleColor(titleColor, for: .normal)
      backbutton.titleLabel?.font = Font.bold.of(size: 19)
      backbutton.addTarget(self, action: #selector(clickToMoveBack), for: .touchUpInside)
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    @objc func clickToMoveBack() {
      dismissSelf()
    }
}

extension FileManager {

enum ContentDate {
    case created, modified, accessed

    var resourceKey: URLResourceKey {
        switch self {
        case .created: return .creationDateKey
        case .modified: return .contentModificationDateKey
        case .accessed: return .contentAccessDateKey
        }
    }
}

func contentsOfDirectory(atURL url: URL, sortedBy: ContentDate, ascending: Bool = true, options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]) throws -> [URL]? {

    let key = sortedBy.resourceKey
    var files = try contentsOfDirectory(at: url, includingPropertiesForKeys: [key], options: options)
    try files.sort {
        let values1 = try $0.resourceValues(forKeys: [key])
        let values2 = try $1.resourceValues(forKeys: [key])
        if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {
            return date1.compare(date2) == (ascending ? .orderedAscending : .orderedDescending)
        }
        return true
    }
    return files.map { $0 }
  }
}


public extension URL {
  var filesize: Int? {
    let set = Set.init([URLResourceKey.fileSizeKey])
    var filesize: Int?
    do {
        let values = try self.resourceValues(forKeys: set)
        if let theFileSize = values.fileSize {
            filesize = theFileSize
        }
    }
    catch {
        print("Error: \(error)")
    }
    return filesize
 }
    
var creationDate: Date? {
    return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
}

 var filesizeNicelyformatted: String? {
    guard let fileSize = self.filesize else {
        return nil
    }
    return ByteCountFormatter.init().string(fromByteCount: Int64(fileSize))
  }
}

extension PHAsset {
  var image: UIImage {
  var thumbnail = UIImage()
  let imageManager = PHCachingImageManager()
  imageManager.requestImage(for: self, targetSize: CGSize(width: 116, height: 112),
                           contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
    thumbnail = image!
 })
    return thumbnail
  }
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

extension AVAsset {
 var videoThumbnail: UIImage? {
    let assetImageGenerator = AVAssetImageGenerator(asset: self)
    assetImageGenerator.appliesPreferredTrackTransform = true
    var time = self.duration
    time.value = min(time.value, 2)

    do {
        let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
        let thumbNail = UIImage.init(cgImage: imageRef)
        print("Video Thumbnail genertated successfuly")
        return thumbNail

    } catch {
        print("error getting thumbnail video")
        return nil
    }
  }
}
