//
//  SimpleStore.swift
//  SimpleStore
//
//  Created by Henrik Panhans on 06.03.17.
//  Copyright © 2017 Henrik Panhans. All rights reserved.
//

import StoreKit

public class HPStore: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    public var productIDs = [String]()
    public var products = [String:SKProduct]()
    public var delegate: HPStoreDelegate?
    
    
    public init(with identifiers: [String]) {
        super.init()
        
        SKPaymentQueue.default().add(self)
        
        self.productIDs = identifiers
        
        requestProductInfo(with: identifiers)
    }
    
    
    public func canMakePayments() -> Bool{
        return SKPaymentQueue.canMakePayments()
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
        if response.products.count != 0 {
            for product in response.products {
                print(product.price)
                products[product.productIdentifier] = product
            }
        } else {
            print("HPStore: No products found")
        }
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("HPStore: Received Payment Transaction Response from Apple");
        
        delegate?.paymentQueue(queue, updatedTransactions: transactions)
    }
    
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.paymentQueueRestoreCompletedTransactionsFinished(queue)
    }
    
    
    //If an error occurs, the code will go to this function
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.paymentQueue(queue, restoreCompletedTransactionsFailedWithError: error)
    }
}


public protocol HPStoreDelegate: class {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
}

