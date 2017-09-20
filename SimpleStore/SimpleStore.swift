//
//  SimpleStore.swift
//  SimpleStore
//
//  Created by Henrik Panhans on 06.03.17.
//  Copyright © 2017 Henrik Panhans. All rights reserved.
//

import StoreKit

public class SimpleStore: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    public var productIDs = [String]()
    public var products = [String : SKProduct]()
    public var canMakePayments = true
    public var delegate: SimpleStoreDelegate?
    
    public init(with identifiers: [String]) {
        super.init()
        
        SKPaymentQueue.default().add(self)
        
        productIDs = identifiers
        canMakePayments = SKPaymentQueue.canMakePayments()
        
        requestProductInfo(with: identifiers)
    }
    
    
    public func checkIfPaymentPossible() {
        canMakePayments = SKPaymentQueue.canMakePayments()
    }
    
    
    public func restoreTransactions() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    public func buyProduct(with id: String) {
        if products[id] != nil && SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: products[id]! as SKProduct)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    public func requestProductInfo(with ids: [String]) {
        if canMakePayments {
            let productIdentifiers = NSSet(array: ids)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("Cannot perform In App Purchases")
        }
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                print(product.price)
                products[product.productIdentifier] = product
            }
        } else {
            print("No products found")
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                delegate?.purchaseDidSucceed(with: transaction.payment.productIdentifier, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                delegate?.purchaseDidFail(with: transaction.payment.productIdentifier, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print("processing")
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let payment = queue.transactions.first {
            delegate?.purchaseDidRestore(with: payment.transactionIdentifier!, transaction: payment)
        }
    }
    
    //If an error occurs, the code will go to this function
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.restoreDidFail(with: error)
    }
}


public protocol SimpleStoreDelegate: class {
    
    func purchaseDidSucceed(with id: String, transaction: SKPaymentTransaction)
    
    func purchaseDidFail(with id: String, transaction: SKPaymentTransaction)
    
    func purchaseDidRestore(with id: String, transaction: SKPaymentTransaction)
    
    func restoreDidFail(with error: Error)
}

