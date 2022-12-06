//
//  TwitterHelper.swift
//  Contributor
//
//  Created by Shashi Kumar on 05/04/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
import TwitterKit
enum TRTwitterLoginStatus {
    case success(user: TwitterLoginData)
    case cancelled
    case error(msg: String)
}
struct TwitterLoginData: Codable {
    var userName: String?
    var userID: String?
    var authToken: String?
    var authTokenSecret: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var profileImageURL: String?
    var profileImageLargeURL: String?
    enum CodingKeys: String, Codable, CodingKey {
        case userID = "id"
    }
}
class TRTwitterHelper: NSObject {
    private var controller: UIViewController?
    private var handler: ((TRTwitterLoginStatus) -> Void)?
    func twitterLoginRequest(viewcontroller: UIViewController,
                             compeltionHandler: @escaping (TRTwitterLoginStatus) -> Void) {
        self.controller = viewcontroller
        twitterLogin(handler: compeltionHandler)
    }
    func getLoginTwitterToken(viewcontroller: UIViewController,
                              compeltionHandler: @escaping (TRTwitterLoginStatus) -> Void) {
        if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
            var loginUserData = TwitterLoginData()
            loginUserData.authToken = session.authToken
            loginUserData.authTokenSecret = session.authTokenSecret
            loginUserData.userID = session.userID
            compeltionHandler(TRTwitterLoginStatus.success(user: loginUserData))
        } else {
            self.controller = viewcontroller
            twitterLogin(handler: compeltionHandler)
        }
    }
    private func twitterLogin(handler: @escaping (TRTwitterLoginStatus) -> Void) {
        TRTwitterHelper.logoutUser()
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            var loginUserData = TwitterLoginData()
            if session != nil {
                loginUserData.userName = session?.userName ?? ""
                loginUserData.userID = session?.userID  ?? ""
                loginUserData.authToken = session?.authToken  ?? ""
                loginUserData.authTokenSecret = session?.authTokenSecret  ?? ""
                handler(TRTwitterLoginStatus.success(user: loginUserData))
            } else {
                handler(TRTwitterLoginStatus.error(msg: error?.localizedDescription ?? ""))
            }
        }
    }
    static func logoutUser() {
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
    }
}
