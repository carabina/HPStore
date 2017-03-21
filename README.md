# SimpleStore
SimpleStore is a leightweight framework built on top of Apple's StoreKit to perform in-app purchases. It takes pretty much all the work from you so that you can focus on your own code.

To install simply add `pod 'SimpleStore'` to your Podfile or `github "SwiftyJSON/SwiftyJSON"` to your Cartfile

**Usage:**
Simply initialize a new `SimpleStore` object with an array of product id, assign the delegate and you're set. It automatically request the product information for you 
```swift
import SimpleStore

var store = SimpleStore(with: [String])

store.delegate = self //see delegate methods below
```

**The following functions are available:**

```swift
store.checkIfPaymentPossible() // refreshes the canMakePayments Boolean

store.requestProductInfo(withIDs: [String]) // this will reload all products with the supplied identifiers

store.buyProduct(withID: String) // I recommend using an enum for this
```

**Properties**
```swift
var productIDs = [String]()
var products = [String : SKProduct]()
var canMakePayments = true
var delegate: SimpleStoreDelegate?
```

**Delegate Methods**
```swift
func purchaseDidSucceed(with id: String, transaction: SKPaymentTransaction) {}
    
func purchaseDidFail(with id: String, transaction: SKPaymentTransaction) {}

func purchaseDidRestore(with id: String, transaction: SKPaymentTransaction) {}

func restoreDidFail(with error: Error) {}
```

If you have any suggestion or improvements, feel free to contribute :)
