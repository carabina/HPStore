//
//  HPProductResponse.swift
//  HPStore
//
//  Created by Henrik Panhans on 27.08.18.
//  Copyright © 2018 Henrik Panhans. All rights reserved.
//

import StoreKit


public class HPProductResponse {
    public var products = [SKProduct]()
    public var invalidProductIdentifiers = [String]()
    
    public init(_ response: SKProductsResponse) {
        self.products = response.products
        self.invalidProductIdentifiers = response.invalidProductIdentifiers
    }
}
