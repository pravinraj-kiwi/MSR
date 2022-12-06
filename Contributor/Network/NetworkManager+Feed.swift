//
//  NetworkManager+Feed.swift
//  Contributor
//
//  Created by Mini on 22/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper
import Alamofire
import os

extension NetworkManager {
    @discardableResult
    func getOfferItems(completion: @escaping (Feed?, Error?) -> Void) -> Cancellable? {
        return provider.request(ContributorAPI.getOfferItems) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let response):
                do {
                    let offerItems = try response.mapObject(Feed.self)
                    debugPrint("Array is ", offerItems)
                     completion(offerItems, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    @discardableResult
    func getNotifOfferItem(offerId: Int, completion: @escaping (OfferItem?, Error?) -> Void) -> Cancellable? {
        return provider.request(ContributorAPI.getOffer(offerId)) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let response):
                do {
                    let offer = try response.mapObject(OfferItem.self)
                    completion(offer, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    @discardableResult
    func getContentItems(completion: @escaping ([ContentItem], Error?) -> Void) -> Cancellable? {
        return provider.request(ContributorAPI.getContentItems) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion([], error)
            case .success(let response):
                do {
                    let contentItems = try response.mapArray(ContentItem.self)
                    completion(contentItems, nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }
    
    @discardableResult
    func markOfferItemsAsSeen(items: [OfferItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markSeenOfferPath = ContributorAPI.markOfferItemsAsSeen(items: items)
        return provider.request(markSeenOfferPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markOfferItemsAsOpened(items: [OfferItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markOpenedOfferPath = ContributorAPI.markOfferItemsAsOpened(items: items)
        return provider.request(markOpenedOfferPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markOfferItemsAsStarted(items: [OfferItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markStartedOfferPath = ContributorAPI.markOfferItemsAsStarted(items: items)
        return provider.request(markStartedOfferPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markOfferItemsAsCompleted(items: [OfferItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markOfferCompletedPath = ContributorAPI.markOfferItemsAsCompleted(items: items)
        return provider.request(markOfferCompletedPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markOfferItemsAsDeclined(items: [OfferItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markOfferDeclinedPath = ContributorAPI.markOfferItemsAsDeclined(items: items)
        return provider.request(markOfferDeclinedPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markContentItemsAsSeen(items: [ContentItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markContentSeenPath = ContributorAPI.markContentItemsAsSeen(items: items)
        return provider.request(markContentSeenPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    
    @discardableResult
    func markContentItemsAsOpened(items: [ContentItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markContentOpenedPath = ContributorAPI.markContentItemsAsOpened(items: items)
        return provider.request(markContentOpenedPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    @discardableResult
    func markStoryItemsAsOpened(items: [StoryItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markStoryOpenedPath = ContributorAPI.markStoryItemsAsOpened(items: items)
        return provider.request(markStoryOpenedPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
    @discardableResult
    func markStoryItemsAsSeen(items: [StoryItem], completion: @escaping (Error?) -> Void) -> Cancellable? {
        let markStorySeenPath = ContributorAPI.markStoryItemsAsSeen(items: items)
        return provider.request(markStorySeenPath) { [weak self] (result) in
            guard let _ = self else {
                return
            }
            completion(result.error)
        }
    }
}
