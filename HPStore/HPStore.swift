//
//  SimpleStore.swift
//  SimpleStore
//
//  Created by Henrik Panhans on 06.03.17.
//  Copyright © 2017 Henrik Panhans. All rights reserved.
//

import StoreKit

public class HPStore: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    public var identifiers = [String]() {
        didSet { self.requestProductInfo(with: identifiers) }
    }
    public var products = [String:SKProduct]()
    public var delegate: HPStoreDelegate?
    
    
    public init(with identifiers: [String]) {
        super.init()
        
        SKPaymentQueue.default().add(self)
        self.identifiers = identifiers
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
        } else {
            print("HPStore: No product found or device can't make in-app purchases")
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
        self.delegate?.productsRequest(request, didReceive: response)
        print("HPStore: Did receive Response from Apple")
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
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("HPStore: Received Payment Transaction Response from Apple")
        self.delegate?.paymentQueue(queue, updatedTransactions: transactions)
    }
    
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("HPStore: Payment Qeue finished restoring transactions")
        self.delegate?.paymentQueueRestoreCompletedTransactionsFinished(queue)
    }
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("HPStore: Payment Qeue failed to restore transactions")
        self.delegate?.paymentQueue(queue, restoreCompletedTransactionsFailedWithError: error)
    }
}


public protocol HPStoreDelegate: class {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
}

