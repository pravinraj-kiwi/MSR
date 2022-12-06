//
//  FacebookLoginHelper.swift
//  Contributor
//
//  Created by Kiwitech on 09/04/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

enum FacebookReadPermissions: String {
    case userProfile = "public_profile"
    case email = "email"
}

enum FacebookPublishPermissions: String {
    case publishPages = "publish_pages"
}

extension FacebookReadPermissions {
    
    static func getAllCasesValue() -> [String] {
        var casesArray: [String] = [String]()
        switch FacebookReadPermissions.email {
        case .email:
            casesArray.append(FacebookReadPermissions.email.rawValue)
            fallthrough
        case .userProfile:
            casesArray.append(FacebookReadPermissions.userProfile.rawValue)
        }
        return casesArray
    }
}

enum FacebookData: String {
    case facebookId = "id"
    case firstName =  "first_name"
    case lastName = "last_name"
    case userEmail = "email"
    case userProfilePic = "picture"
}

extension FacebookData {
    
    static func getAllCasesValue() -> [String] {
        var casesArray: [String] = [String]()
        switch FacebookData.facebookId {
        case .facebookId:
            casesArray.append(FacebookData.facebookId.rawValue)
            fallthrough
        case .firstName:
            casesArray.append(FacebookData.firstName.rawValue)
            fallthrough
        case .lastName:
            casesArray.append(FacebookData.lastName.rawValue)
            fallthrough
        case .userEmail:
            casesArray.append(FacebookData.userEmail.rawValue)
            fallthrough
        case .userProfilePic:
            casesArray.append(FacebookData.userProfilePic.rawValue)
        }
        return casesArray
    }
}

enum FaceBookLoginResult {
    case success(loginResult: FaceBookLoginData)
    case error(message: String)
    case cancelled
}

struct FaceBookLoginData: Codable {
    var facebookId: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var birthday: String?
    var gender: String?
    var picture: Picture?
    var fbToken: String?
    
    enum CodingKeys: String, Codable, CodingKey {
        case facebookId = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case birthday
        case gender
        case picture
    }
}

struct  Picture: Codable {
    var data: PictureData?
}

struct PictureData: Codable {
    var height: Int?
    var width: Int?
    var url: String?
}

final class FacebookLoginHelper {
    private var viewController: UIViewController?
    
    func facebookLoginRequest(viewcontroller: UIViewController,
                              compeltionHandler: @escaping (FaceBookLoginResult) -> Void) {
        LoginManager().logOut()
        viewController = viewcontroller
        doLogin(handler: compeltionHandler)
    }
    
    private func doLogin(handler: @escaping (FaceBookLoginResult) -> Void) {
        if let token = AccessToken.current {
            self.fetchUserData(token, requestData: FacebookData.getAllCasesValue(),
                               completion: {(result, error) in
                if let error = error {
                    handler(FaceBookLoginResult.error(message: error.localizedDescription))
                } else {
                    handler(FaceBookLoginResult.success(loginResult: result!))
                }
            })
        } else {
            LoginManager().logIn(permissions: FacebookReadPermissions.getAllCasesValue(),
                                 from: viewController!) {(result, error) in
                if let error = error {
                    handler(FaceBookLoginResult.error(message: error.localizedDescription))
                } else if let cancelled = result?.isCancelled, cancelled == true {
                    handler(FaceBookLoginResult.cancelled)
                } else {
                    if let token = result?.token {
                        self.fetchUserData(token, requestData: FacebookData.getAllCasesValue(),
                                           completion: {(result, error) in
                            if let error = error {
                                handler(FaceBookLoginResult.error(message: error.localizedDescription))
                            } else {
                                handler(FaceBookLoginResult.success(loginResult: result!))
                            }
                        })
                    } else {
                        handler(FaceBookLoginResult.error(message: ""))
                    }
                }
            }
        }
    }
    
    private func fetchUserData(_ accessToken: AccessToken, requestData: [String],
                               completion: @escaping (_ result: FaceBookLoginData?,
                                                      _ error: Error?) -> Void) {
        // let graphRequest = GraphRequest(graphPath: "/me",
        //                                 parameters: ["fields": requestData.joined(separator: ",")])
        // _ = graphRequest.start(completionHandler: { (_, result, error) in
        //    if let result = result,
        //       let deocdedData = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted) {
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": requestData.joined(separator: ",")])
        graphRequest.start { _, result, error in
            if let result = result, error == nil {
                print("fetched user: \(result)")
                if let deocdedData = try? JSONSerialization.data(withJSONObject: result,
                                                                 options: JSONSerialization.WritingOptions.prettyPrinted) {
                    do {
                        let fbloginData: FaceBookLoginData = try JSONDecoder().decode(FaceBookLoginData.self, from: deocdedData)
                        completion(fbloginData, error)
                    } catch {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
                //  })
            }
        }
    }
    
    func logoutFromFacebook() {
        LoginManager().logOut()
    }
}
