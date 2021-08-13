import XCTest
import ExampleItemStore

final class CoreDataItemStoreTests: XCTestCase {
    
    /**
     This test finishes and passes regardless of the context that `CoreDataItemStore` uses.
     */
    func testThreading_One() {
        
        let store = CoreDataItemStore.inMemoryStorage()
        
        let iterationCount = 100
        let justWait = XCTestExpectation(description: "Waiting until things are done")
        justWait.expectedFulfillmentCount = iterationCount * 5

        let main = DispatchQueue.main
        let one = DispatchQueue(label: "one")
        let two = DispatchQueue(label: "two")
        let three = DispatchQueue(label: "three")
        let four = DispatchQueue(label: "four")
        
        for _ in 0 ..< iterationCount {

            main.async {
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }

            one.async {
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }

            two.async {
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }
            
            three.async {
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }

            four.async {
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }
        }
        
        wait(for: [justWait], timeout: 5)
    }
    
    /**
     This test does not finish (no success, no failure) when `CoreDataItemStore` uses `viewContext` to dispatch work.
     */
    func testThreading_Two() {
        
        let store = CoreDataItemStore.inMemoryStorage()
        
        let iterationCount = 100
        let justWait = XCTestExpectation(description: "Waiting until things are done")
        justWait.expectedFulfillmentCount = iterationCount
        
        DispatchQueue.concurrentPerform(iterations: iterationCount) { iter in
            store.createOrUpdateItem(resourceID: "mine", value: "good")
            justWait.fulfill()
        }
        
        wait(for: [justWait], timeout: 5.0)
    
    }

    /**
     This test does not finish (no success, no failure) when `CoreDataItemStore` uses `viewContext` to dispatch work.
     */
    func testThreading_Three() {

        let store = CoreDataItemStore.inMemoryStorage()
        
        let iterationCount = 100
        let justWait = XCTestExpectation(description: "Waiting until things are done")
        justWait.expectedFulfillmentCount = iterationCount
        
        DispatchQueue.main.async {
            DispatchQueue.concurrentPerform(iterations: iterationCount) { iter in
                store.createOrUpdateItem(resourceID: "mine", value: "good")
                justWait.fulfill()
            }
        }

        wait(for: [justWait], timeout: 5.0)

    }
    
}
