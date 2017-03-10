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
    
    public init(with IDs: [String]) {
        super.init()
        
        SKPaymentQueue.default().add(self)
        
        productIDs = IDs
        canMakePayments = SKPaymentQueue.canMakePayments()
        
        requestProductInfo(withIDs: IDs)
    }
    
    
    public func checkIfPaymentPossible() {
        canMakePayments = SKPaymentQueue.canMakePayments()
    }
    
    
    public func restoreTransactions() {
        if canMakePayments {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    
    public func buyProduct(withID: String) {
        if products[withID] != nil && SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: products[withID]! as SKProduct)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    public func requestProductInfo(withIDs: [String]) {
        if canMakePayments {
            let productIdentifiers = NSSet(array: withIDs)
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
            print("There are no products")
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                delegate?.purchaseDidSucceed(with: transaction.payment.productIdentifier, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("purchase restored")
                delegate?.purchaseDidRestore(with: transaction.payment.productIdentifier, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                print("purchase deferred")
            case .failed:
                delegate?.purchaseDidFail(with: transaction.payment.productIdentifier, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                print(transaction.transactionState.hashValue)
            }
        }
    }
}


public protocol SimpleStoreDelegate: class {
    
    func purchaseDidSucceed(with id: String, transaction: SKPaymentTransaction)
    
    func purchaseDidFail(with id: String, transaction: SKPaymentTransaction)
    
    func purchaseDidRestore(with id: String, transaction: SKPaymentTransaction)
}

