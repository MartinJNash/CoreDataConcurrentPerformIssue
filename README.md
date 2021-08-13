# ExampleItemStore

 `CoreDataItemStore` provides a simple interface to a `CoreData` store. All actions are performed within the `performAndWait` block of a `ManagedObjectContext`.


## Problem

We are testing multithreaded calls to `CoreDataItemStore.createOrUpdateItem(resourceID:value:)` in multiple ways.

- Creating `DispatchQueue` objects and calling `.async {}`
- Using `class DispatchQueue.concurrentPerform(iterations:execute:)`

When using `viewContext.performAndWait {}` to handle CoreData threading, the tests using  `DispatchQueue.concurrentPerform` don't finish. No success. No failure. Changing to a different `ManagedObjectContext` causes the tests to finish as expected.


## Question

What is causing issues with the combination of  `DispatchQueue.concurrentPerform` and `viewContext.performAndWait`? 
