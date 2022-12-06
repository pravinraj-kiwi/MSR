//
//  Profile.swift
//  Contributor
//
//  Created by arvindh on 16/04/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import CloudKit
import SwiftyUserDefaults

class Profile: NSObject {
    
  static let recordType: String = "Profile"
  var record: CKRecord
  var email: String?
  var userID: Int?
  var voteGUID: String? = Profile.generateVoteGUID()
  var data: String?
  var changeTag: String?
  var modifiedAt: Date?

  var json: [String: AnyHashable] {
    return decodeServerData()
  }
    
  func decodeServerData() -> [String: AnyHashable] {
    guard let profileData = data else {
      return [:]
    }

    if let loggedInUserId = userID {
    if let decodedData = Data(base64Encoded: profileData, options: .ignoreUnknownCharacters) {
        let bytes = [UInt8](decodedData)
        let decryptProfileData = AESGCMEncryptionDecryption().decryptData(encryptedData: Array(bytes),
                                                                          "\(loggedInUserId)")
        return convertToDictionary(decryptProfileData) ?? [:]
      }
    }
    return [:]
 }

 func convertToDictionary(_ values: String) -> [String: AnyHashable]? {
    var updatedJson = [String: AnyHashable]()
    if let data = values.data(using: .utf8) {
      do {
          if let jsonResult = try JSONSerialization.jsonObject(with: data,
                                                           options: []) as? [String: AnyHashable] {
        let _ = jsonResult.flatMap { (key, value)  in
            if String(describing: value).contains(",") {
                let updatedValue = String(describing: value).filter { !" \n\t\r".contains($0) }.trimTrailingWhitespaces()
                let commaSeperatedValue = updatedValue.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
                updatedJson.updateValue(commaSeperatedValue, forKey: key)
            } else {
                updatedJson.updateValue(value, forKey: key)
            }
        }
      }
     } catch {
        print(error.localizedDescription)
      }
     return updatedJson
    }
   return nil
  }
  
  static func generateVoteGUID() -> String {
    return UUID().uuidString
  }
    
  init(record: CKRecord? = nil) {
    self.record = record ?? CKRecord(recordType: Profile.recordType)
    super.init()
  }
}

struct ProfileBackUpData: Codable {
 var profileBackupId: Int?
 var userId: Int?
 var voteGUID: String?
 var encryptedData: String?
 var tag: String?
 var modifiedDate: String?
     
 private enum CodingKeys: String, CodingKey {
   case profileBackupId = "id"
   case userId = "user"
   case voteGUID
   case encryptedData = "encrypted_profile"
   case tag
   case modifiedDate = "modified_date"
 }
}

extension String {
    func trimTrailingWhitespaces() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
    func trimAllSpace() -> String {
             return components(separatedBy: .whitespacesAndNewlines).joined()
        }
}
