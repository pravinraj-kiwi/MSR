//
//  NetworkManager+Wallet.swift
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
func getExchangeRates(completion: @escaping (ExchangeRates?,
                                             Error?) -> Void) -> Cancellable? {
  let exchangeRatePath = ContributorAPI.getExchangeRates(Constants.msrSymbol)
  return provider.request(exchangeRatePath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let exchangeRates = try response.map(ExchangeRates.self)
        Defaults[.exchangeRates] = exchangeRates
        completion(exchangeRates, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}

@discardableResult
func getWalletTransactions(page: Int,
                           completion: @escaping ([WalletTransaction],
                                                  Error?) -> Void) -> Cancellable? {
  let walletTransPath = ContributorAPI.getWalletTransactions(page: page)
  return provider.request(walletTransPath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion([], error)
    case .success(let response):
      do {
        let transactions = try response.mapArray(WalletTransaction.self)
        completion(transactions, nil)
      } catch {
        completion([], error)
      }
    }
  }
}
    
@discardableResult
func getTransactionDetail(_ transactionId: Int,
                          completion: @escaping (TransactionDetail?,
                                                 Error?) -> Void) -> Cancellable? {
  let transDetailPath = ContributorAPI.getTransactionsDetail(transactionID: transactionId)
  return provider.request(transDetailPath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let transactionDetail = try response.mapObject(TransactionDetail.self)
        completion(transactionDetail, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}

@discardableResult
func getGiftCards(completion: @escaping ([GiftCard],
                                         Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.getGiftCards) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion([], error)
    case .success(let response):
      do {
        let giftCards = try response.mapArray(GiftCard.self)
        completion(giftCards, nil)
      } catch {
        completion([], error)
      }
    }
  }
}

@discardableResult
    func getRedemptionAmounts(type: String, completion: @escaping ([GiftCardRedemptionOption],
                                                 Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.getRedemptionAmounts(redeemType: type)) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion([], error)
    case .success(let response):
      do {
        let options = try response.mapArray(GiftCardRedemptionOption.self)
        completion(options, nil)
      } catch {
        completion([], error)
      }
    }
  }
}

@discardableResult
    func redeemGiftCard(redemptionType:PaymentType, email:String? = nil,
                        _ option: GiftCardRedemptionOption,
                    completion: @escaping (GiftCardRedemptionResponse?,
                                           Error?) -> Void) -> Cancellable? {
        return provider.request(ContributorAPI.redeemGiftCard(redemptionType: redemptionType,
                                                              email: email,
                                                              option)) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let redemptionResponse = try response.mapObject(GiftCardRedemptionResponse.self)
        completion(redemptionResponse, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}

@discardableResult
func redeemGenericReward(_ params: GenericRewardRedemptionParams,
                         completion: @escaping (GenericRewardRedemptionResponse?,
                                                Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.redeemGenericReward(params)) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let redemptionResponse = try response.mapObject(GenericRewardRedemptionResponse.self)
        completion(redemptionResponse, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
 }
}
