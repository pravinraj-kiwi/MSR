//
//  SurveyCallbackManager.swift
//  Contributor
//
//  Created by John Martin on 2/18/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

struct SurveyStart: Codable {
    let message, nextAction: String?

    enum CodingKeys: String, CodingKey {
        case message
        case nextAction = "next_action"
    }
}
typealias surveyStatusCompletion = (SurveyStatus, ExternalSurveyCompletion)
class SurveyCallbackManager: NSObject {
    static let shared: SurveyCallbackManager = {
        let manager = SurveyCallbackManager()
        return manager
    }()
    var externalSurveyManager: ExternalSurveyManager?
   // var surveyStatus: SurveyStatus = .inProgress
   // var surveyStatus: [SurveyStatus: ExternalSurveyCompletion] = [:]
    
    fileprivate var surveyBackgroundTaskRunner: BackgroundTaskRunner!
    
    func callback(surveyType: SurveyType, callbackType: SurveyCallbackType,
                  manager: SurveyManager? = nil,
                  videoUrl: String? = nil,
                  _ hasSkipContentValidation: Bool = false,
                  twitterDetails: [String: Any]? = nil,
                  completion:@escaping (SurveyStart?, surveyStatusCompletion? , Error?) -> Void){
        var callbackURL: URL?
        var parameters: Parameters = [:]
        switch surveyType {
        case .categoryOffer(let offerItem, _),
             .embeddedOffer(let offerItem, _),
             .externalOffer(let offerItem):
            
            if offerItem.isExternallySampled {
                switch callbackType {
                case .started:
                    callbackURL = offerItem.startedCallbackURL
                case .completed:
                    callbackURL = offerItem.completedCallbackURL
                case .terminated:
                    callbackURL = offerItem.terminatedCallbackURL
                }
                parameters = [
                    "srid": offerItem.sampleRequestID! as Any,
                    "cid": UserManager.shared.user!.userID! as Any
                ]
                if callbackType == .completed {
                    if let callbackURL = callbackURL {
                        let str = "?srid=\(offerItem.sampleRequestID! as Any)&cid=\(UserManager.shared.user!.userID! as Any)"
                        guard let finalUrl = URL(string: callbackURL.absoluteString + str) else {return}
                        Alamofire.request(finalUrl ,
                                          parameters: nil)
                            .responseString { [weak self] response in
                                debugPrint(response)
                                guard let this = self else {return}

                                switch response.result {
                                case .failure(let error):
                                    debugPrint("Failure>>>")
                                    completion(nil, nil, error)
                                case . success(let response):
                                    debugPrint("Success")
                                    if offerItem.sampleRequestType == SampleRequestType.workShopSurvey
                                        && callbackType == .completed {
                                        this.updateWorkShopData(offerItem: offerItem,
                                                                manager: manager,
                                                                hasSkipContentValidation,
                                                                videoUrl: videoUrl,
                                                                twitterDetails: twitterDetails) {}
                                    }
                                    this.externalSurveyManager = ExternalSurveyManager(offerItem: offerItem)
                                    if let retriveData = this.externalSurveyManager?.checkSurveyStatus(html: response.stringValue) {
                                       // this.surveyStatus = retriveData
                                        completion(nil, retriveData, nil)

                                    } else {
                                        completion(nil, nil, nil)
                                    }
                                }
                                
                            }
                    }
                    
                } else {
                    
                    if let callbackURL = callbackURL {
                        Alamofire.request(callbackURL, method: .post,
                                          parameters: parameters,
                                          encoding: JSONEncoding.default)
                            .validate()
                            .responseJSON {  [weak self] response in
                                guard let this = self else {return}
                                switch response.result {
                                case .failure(let error):
                                    debugPrint("Failure>>>")
                                    completion(nil, nil ,error)
                                case . success(let response):
                                    debugPrint("Success")
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                                        let reqJSONStr = String(data: jsonData, encoding: .utf8)
                                        let data = reqJSONStr?.data(using: .utf8)
                                        let jsonDecoder = JSONDecoder()
                                        let responModel = try jsonDecoder.decode(SurveyStart.self, from: data!)
                                        if offerItem.sampleRequestType == SampleRequestType.workShopSurvey
                                            && callbackType == .completed {
                                            this.updateWorkShopData(offerItem: offerItem,
                                                                    manager: manager,
                                                                    hasSkipContentValidation,
                                                                    videoUrl: videoUrl,
                                                                    twitterDetails: twitterDetails) {}
                                        }
                                        completion(responModel,nil, nil)
                                    } catch {
                                        completion(nil, nil, error)
                                    }
                                }
                                
                            }
                    }
                }
                
            } else {
                switch callbackType {
                case .started:
                    NetworkManager.shared.markOfferItemsAsStarted(items: [offerItem]) {
                        error in
                        if let _ = error {
                            os_log("markOfferItemsAsStarted failed", log: OSLog.feed, type: .error)
                        }
                        completion(nil, nil, error)
                    }
                case .completed:
                    NetworkManager.shared.markOfferItemsAsCompleted(items: [offerItem]) {
                        error in
                        if let _ = error {
                            os_log("markOfferItemsAsCompleted failed", log: OSLog.feed, type: .error)
                        }
                        completion(nil, nil, error)
                    }
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func getValueForTheQuestionId(_ manager: SurveyManager?) -> [String] {
        var questionsId = [String]()
        if let surveyPages = manager?.survey?.pages {
            let question = BlockPageType.question.rawValue
            let pages = surveyPages.map({$0.blocks.filter({$0.blockType == question})})
            _ = pages.map { (blocks) in
                let profileQuestions = blocks.filter({$0.isProfile == true})
                questionsId += profileQuestions.map({$0.blockID}) as? [String] ?? []
            }
        }
        return questionsId
    }
    
    func getUploadedVideo(_ manager: SurveyManager?, _ videoURL: String?,
                          _ hasSkipContentValidation: Bool) -> (String,
                                                                [String: AnyHashable]) {
        var screenCaptureDict = [String: AnyHashable]()
        var blockId = ""
        if let surveyPages = manager?.survey?.pages {
            for page in surveyPages {
                for block in page.blocks {
                    if let screenCaptureID = block.screenCaptureBlock?.screenCaptureId {
                        blockId = screenCaptureID
                        screenCaptureDict.updateValue("s3", forKey: "storage_type")
                        screenCaptureDict.updateValue("measure-user", forKey: "bucket_name")
                        if let url = videoURL {
                            screenCaptureDict.updateValue(url, forKey: "path")
                        }
                        if hasSkipContentValidation == true {
                            screenCaptureDict.updateValue(true,
                                                          forKey: "user_skipped_check_file_content_validation")
                        }
                        let approxSpeed = Defaults[.retroVideoApproxUploadSpeed]
                        if approxSpeed != nil && approxSpeed?.isEmpty == false {
                            screenCaptureDict.updateValue(approxSpeed, forKey: "approx_upload_speed_mbps")
                        }
                        
                    }
                }
            }
            return (blockId, screenCaptureDict)
        }
        return ("", [:])
    }
    
    func getWorkShopSurveyParameters(_ manager: SurveyManager?) -> [String: AnyHashable] {
        let questionsIds = getValueForTheQuestionId(manager)
        var profileDict = [String: AnyHashable]()
        if let profileStore = manager?.networkManager.userManager?.profileStore,
           let userId = UserManager.shared.user?.userID {
            if questionsIds.isEmpty == false {
                for questionId in questionsIds {
                    if let value = profileStore.values[questionId] {
                        profileDict.updateValue(value, forKey: questionId)
                    }
                }
            }
            let nonProfileDefault = UserDefaults.standard.value(forKey: "nonProfileStore-\(userId)")
            let nonProfileValue = nonProfileDefault as? [String: AnyHashable] ?? [:]
            let totalVal = profileDict.merging(nonProfileValue) { (_, new) in new }
            return totalVal
        }
        return [:]
    }
    
    func getWorkShopSurveyParameter(offerItem: OfferItem, _ manager: SurveyManager?,
                                    videoURL: String?, _ hasSkipContentValidation: Bool,
                                    twitterDetails: [String: Any]? = nil) -> [String: Any] {
        var parameters = [String: Any]()
        let values = self.getWorkShopSurveyParameters(manager)
        if let _ = videoURL {
            let uploadValues = self.getUploadedVideo(manager, videoURL,
                                                     hasSkipContentValidation)
            let captureValue = [uploadValues.0: uploadValues.1]
            let dataParam = values.merging(captureValue) { (_, new) in new }
            parameters = [
                "srid": offerItem.sampleRequestID! as Any,
                "cid": UserManager.shared.user!.userID! as Any,
                "data": ["values": dataParam]
            ]
        } else {
            if let currentBlock = manager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.oAuthCapture.rawValue}),
               currentBlock.isEmpty == false {
                var twitterDetailsDict = [String: Any]()
                let keyInfo = manager?.currentPage?.blocks.first?.screenCaptureBlock?.screenCaptureId ?? ""
                if let details = twitterDetails {
                    twitterDetailsDict = [keyInfo: details]
                    parameters = [
                        "srid": offerItem.sampleRequestID! as Any,
                        "cid": UserManager.shared.user!.userID! as Any,
                        "data": ["values": twitterDetailsDict]
                    ]
                }
            } else {
                parameters = [
                    "srid": offerItem.sampleRequestID! as Any,
                    "cid": UserManager.shared.user!.userID! as Any,
                    "data": ["values": values]
                ]
            }
            
        }
        return parameters
    }
    
    func updateWorkShopData(offerItem: OfferItem, manager: SurveyManager?,
                            _ hasSkipContentValidation: Bool = false,
                            videoUrl: String? = nil,
                            twitterDetails: [String: Any]? = nil,
                            completion: (() -> Void)? = nil) {
        surveyBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
        surveyBackgroundTaskRunner.startTask {
            let params = self.getWorkShopSurveyParameter(offerItem: offerItem, manager,
                                                         videoURL: videoUrl, hasSkipContentValidation,
                                                         twitterDetails: twitterDetails)
            if let workshopUrl = offerItem.workShopSurveyCallbackURL {
                Alamofire.request(workshopUrl, method: .post, parameters: params,
                                  encoding: JSONEncoding.default, headers: Helper.getRequestHeader())
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .failure(_): break
                        default:
                            break
                        }
                        completion?()
                    }
            }
        }
        removeNonProfileStore(offerItem, manager)
        surveyBackgroundTaskRunner.endTask()
    }
    
    func removeNonProfileStore(_ offerItem: OfferItem, _ manager: SurveyManager?) {
        if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
            if let userId = UserManager.shared.user?.userID {
                UserDefaults.standard.removeObject(forKey: "nonProfileStore-\(userId)")
                UserDefaults.standard.removeObject(forKey: Constants.nonProfileTempKey)
                if let profileStore = manager?.networkManager.userManager?.profileStore {
                    profileStore.removeNonProfileValue(forKey: profileStore.nonProfileKey)
                }
            }
        }
    }
}
