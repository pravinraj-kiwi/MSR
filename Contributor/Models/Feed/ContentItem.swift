//
//  ContentItem.swift
//  Contributor
//
//  Created by John Martin on 3/22/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyUserDefaults
import IGListKit

class ContentItem: NSObject, Mappable {
  enum LayoutType: String {
    case textOnly, topImage1x1, topImage2x1, topImage3x1
  }

  enum ContentType: Int {
    case inline = 10
    case internalLink = 20
    case externalLink = 30
  }
  
  var contentID: Int!
  var contentGUID: String!
  var title: String!
  var body: String?
  var urlString: String?
  var contentDate: Date!
  var contentType: ContentType = .inline
  var imageURLString: String!
  var layoutType: LayoutType = .topImage1x1
  var backgroundColorHexString: String?
  var useWhiteText: Bool = false
  var foregroundColorHexString: String?
  var foregroundLightColorHexString: String?
  var seen: Bool = false
  var opened: Bool = false

  var url: URL? {
    if let urlString = urlString {
      return URL(string: urlString)
    }
    return nil
  }
  
  var imageURL: URL? {
    if let urlString = imageURLString {
      return URL(string: urlString)
    }
    return nil
  }
  
  var backgroundColor: UIColor? {
    if let hexString = backgroundColorHexString {
      return UIColor(hexString: hexString)
    }
    return nil
  }

  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    contentID <- map["id"]
    contentGUID <- map["guid"]
    title <- map["title"]
    body <- map["body"]
    urlString <- map["url"]
    contentType <- map["content_type"]
    contentDate <- (map["content_date"], ISO8601DateTransform())
    imageURLString <- map["image_url"]
    layoutType <- map["style.layout_type"]
    backgroundColorHexString <- map["style.background_color"]
    useWhiteText <- map["style.use_white_text"]
    seen <- map["seen"]
    opened <- map["opened"]
  }
  
  public override func diffIdentifier() -> NSObjectProtocol {
    return contentID as NSObjectProtocol
  }
  
  public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let rhs = object as? ContentItem else {
      return false
    }
    
    if title != rhs.title || body != rhs.body || urlString != rhs.urlString || contentType != rhs.contentType || contentDate != rhs.contentDate || imageURLString != rhs.imageURLString || layoutType != rhs.layoutType || backgroundColorHexString != rhs.backgroundColorHexString || useWhiteText != rhs.useWhiteText || seen != rhs.seen || opened != rhs.opened {
      return false
    }
    
    return true
  }
}
