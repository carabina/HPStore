# SimpleStore
A lightweight wrapper class to perform in-app purchases.

To install simply add `pod 'SimpleStore'` to your Podfile

**Usage:**

```swift
import SimpleStore

var store = SimpleStore(with: [String])

store.delegate = self //see delegate methods below
```

**The following functions are available:**

```swift
store.checkIfPaymentPossible() //refreshes the canMakePayments Boolean

store.requestProductInfo(withIDs: [String])

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
func purchaseDidSucceed(with id: String) {}
    
func purchaseDidRestore(with id: String) {}
    
func purchaseDidFail(with id: String) {}
```

If you have any suggestion or improvements, feel free to contribute :)
