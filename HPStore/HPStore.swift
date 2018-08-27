//
//  SimpleStore.swift
//  SimpleStore
//
//  Created by Henrik Panhans on 06.03.17.
//  Copyright © 2017 Henrik Panhans. All rights reserved.
//

import StoreKit
import SwiftyReceiptValidator

public class HPStore: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    public var identifiers = [String]() {
        didSet { self.requestProductInfo(with: identifiers) }
    }
    public var products = [String:SKProduct]()
    public var delegate: HPStoreDelegate?
    public var sharedSecret: String?
    public var validator = SwiftyReceiptValidator()
    
    public init(with identifiers: [String], secret sharedSecret: String? = nil) {
        super.init()
        
        SKPaymentQueue.default().add(self)
        self.identifiers = identifiers
        self.sharedSecret = sharedSecret
    }
    
    
    public func canMakePayments() -> Bool{
        return SKPaymentQueue.canMakePayments()
    }
    
    
    public func restoreTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    public func buyProduct(with id: String) {
        if products[id] != nil && SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: products[id]! as SKProduct)
            SKPaymentQueue.default().add(payment)
        } else {
            print("HPStore: No products found or device can't make in-app purchases")
        }
    }
    
    
    public func requestProductInfo(with ids: [String]) {
        print("HPStore: Requesting Product Info")
        if self.canMakePayments() {
            let productIdentifiers = NSSet(array: ids)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("HPStore: Cannot perform In App Purchases")
        }
    }
    
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let response = HPProductResponse(response)
        
        self.delegate?.productsRequest(didReceive: response)
        if response.products.count != 0 {
            self.products.removeAll()
            for product in response.products {
                products[product.productIdentifier] = product
            }
            print("HPStore: Loaded \(products.count) products")
        } else {
            print("HPStore: No products found")
        }
    }
    
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        self.delegate?.productsRequest(didFailWithError: error)
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                let productIdentifier = transaction.payment.productIdentifier
                
                self.validator.validate(productIdentifier, sharedSecret: sharedSecret) { result in
                    switch result {
                    case .success(let data):
                        print("HPStore: Receipt validation was successfull with data \(data)")
                        self.delegate?.transactionFinished(for: productIdentifier)
                        
                    case .failure(let code, let error):
                        print("HPStore: Receipt validation failed with code: \(code), error: \(error.localizedDescription)")
                        self.delegate?.transactionFailed(for: productIdentifier, with: error)
                    }
                    
                    queue.finishTransaction(transaction) // make sure this is in the validation closure
                }
            case .restored:
                if let productIdentifier = transaction.original?.payment.productIdentifier {
                    self.validator.validate(productIdentifier, sharedSecret: sharedSecret) { result in
                        switch result {
                        case .success(let data):
                            print("HPStore: Receipt validation was successfull with data \(data)")
                            self.delegate?.transactionRestored(for: productIdentifier)
                            
                        case .failure(let code, let error):
                            print("HPStore: Receipt validation failed with code: \(code), error: \(error.localizedDescription)")
                            self.delegate?.transactionFailed(for: productIdentifier, with: error)
                        }
                        
                        queue.finishTransaction(transaction) // make sure this is in the validation closure
                    }
                }
            case .failed:
                let productIdentifier = transaction.payment.productIdentifier
                self.delegate?.transactionFailed(for: productIdentifier, with: transaction.error)
            default:
                break
            }
        }
    }
    
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.delegate?.purchaseRestoringFinished()
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.delegate?.purchaseRestoringFailed(with: error)
    }
}


public protocol HPStoreDelegate: class {
    func transactionFinished(for identifier: String)
    func transactionFailed(for identifier: String, with error: Error?)
    func transactionRestored(for identifier: String)
    func purchaseRestoringFinished()
    func purchaseRestoringFailed(with error: Error)
    func productsRequest(didReceive response: HPProductResponse)
    func productsRequest(didFailWithError error: Error)
}

