//
//  AES-GCMEncryptionDecryption.swift
//  Contributor
//
//  Created by Kiwitech on 27/03/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import CryptoSwift
import NIO

class AESGCMEncryptionDecryption {
    
 var ivLengthInt = [UInt8]()
 let ivLength = 12
 let contibuterPropertyFileName = "Contributor"

 /*
 Get the remaining key after subtracting userId
 from CONTRIBUTOR file to make the encrypted key of 32
 */
 func getContributerData() -> ([String], Int) {
    if let filepath = Bundle.main.path(forResource: contibuterPropertyFileName,
                                       ofType: "txt") {
        do {
           let contents = try String(contentsOfFile: filepath)
           let contributerElements = contents.split { $0 == "\n" || $0 == "=" || $0 == "\"" }
           let keyString = contributerElements[1].description
           return (keyString.map { String($0) }, Int(String(contributerElements[3])) ?? 32)
        } catch {
            debugPrint("Contributor text file not found")
        }
    } else {
        debugPrint("Contributor text file not found")
    }
    return ([""], 0)
 }
    
 /*
  Generate encryption key from CONTRIBUTOR Key and userId
 */
 func generateKeyForEncryption(userId: String) -> [UInt8] {
    let userIdLength = userId.count
    let remainingLength = getContributerData().1 - userIdLength
    let contibuterKeyArray = (getContributerData().0).prefix(upTo: remainingLength)
    let contibuterKey = contibuterKeyArray.joined(separator: "")
    let saltKey = userId + contibuterKey
    return Array(saltKey.utf8)
 }
    
 func encryptData(profileSurveyData: String, _ loggedInUserId: String) -> String {
      var bytes = [UInt8](repeating: 0, count: 12)
      let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
      if status == errSecSuccess {
        ivLengthInt = bytes
      }
      do {
          let gcm = GCM(iv: ivLengthInt, additionalAuthenticatedData: nil, tagLength: 16,
                        mode: .combined)
          let aes = try AES(key: generateKeyForEncryption(userId: loggedInUserId),
                            blockMode: gcm, padding: .noPadding)
          let encrypted = try aes.encrypt(Array(profileSurveyData.utf8))
          let buffer = ByteBufferAllocator()
          var byteBuffer = buffer.buffer(capacity: (1 + ivLengthInt.count + encrypted.count))
          var buffers = [UInt8]()
          buffers.append(UInt8(ivLengthInt.count))
          byteBuffer.writeBytes(buffers)
          byteBuffer.writeBytes(ivLengthInt)
          byteBuffer.writeBytes(encrypted)
          if let actual = byteBuffer.getBytes(at: 0, length: byteBuffer.readableBytes) {
            let encryptedProfileData = actual.toBase64()
            return encryptedProfileData
          }
      } catch {
          debugPrint("Failed to encrypt the profile data")
      }
      return ""
  }
    
  func decryptData(encryptedData: [UInt8], _ loggedInUserId: String) -> String {
      let buffer = ByteBufferAllocator()
      var byteBuffer = buffer.buffer(capacity: encryptedData.count)
      let remainingLength = encryptedData.count - ivLength
      byteBuffer.writeBytes(encryptedData)
      if let dataiV = byteBuffer.getBytes(at: 1, length: ivLength) {
          if let enryptedByteLeft = byteBuffer.getBytes(at: ivLength + 1,
                                                        length: remainingLength - 1) {
              do {
                  let gcm = GCM(iv: dataiV, additionalAuthenticatedData: nil,
                                tagLength: 16, mode: .combined)
                  let aes = try AES(key: generateKeyForEncryption(userId: loggedInUserId),
                                    blockMode: gcm, padding: .noPadding)
                  let decrypted = try aes.decrypt(enryptedByteLeft)
                  return String(data: Data(decrypted), encoding: .utf8) ?? ""
              } catch {
                  debugPrint("Failed to dencrypt the profile data")
              }
          }
      }
    return ""
   }
}
