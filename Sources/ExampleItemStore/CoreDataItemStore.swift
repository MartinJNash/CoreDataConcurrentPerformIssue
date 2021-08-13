//
//  CoreDataItemStore.swift
//
//
//  Created by Martin Nash on 7/12/21.
//

import Foundation
import CoreData


public final class CoreDataItemStore {
    
    // cache the model, or else it can cause problems if loading multiple times. On load, CoreData registers entity descriptions.
    private static let modelURL = Bundle.module.url(forResource: "ItemStore", withExtension: "momd")!
    private static let model = NSManagedObjectModel(contentsOf: modelURL)!
    
    private let container: NSPersistentContainer
    private let mainContext: NSManagedObjectContext
    private let workingContext: NSManagedObjectContext
    
    private init(container: NSPersistentContainer) {
        self.container = container
        container.loadPersistentStores { _, _ in }
        self.mainContext = container.viewContext
        self.workingContext = container.newBackgroundContext()
    }
    
    public static func inMemoryStorage() -> CoreDataItemStore {
        let container = NSPersistentContainer(name: "ItemStorage", managedObjectModel: model)
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        ]
        return CoreDataItemStore(container: container)
    }
    
    public static func diskStorage(atURL url: URL)  -> CoreDataItemStore {
        let container = NSPersistentContainer(name: "ItemStorage", managedObjectModel: model)
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: url)
        ]
        return CoreDataItemStore(container: container)
    }
    
}

public extension CoreDataItemStore {
    
    // returns updated or created item
    @discardableResult
    func createOrUpdateItem(resourceID: String, value: String) -> Item? {
        
        // using main context here causes tests using `DispatchQueue.concurrentPerform` to never finish
        let context = mainContext
        
        var foundToken: Item?
        
        // fetch extant item
        let fr: NSFetchRequest<Item> = Item.fetchRequest()
        let idPredicate = NSPredicate(format: "resourceID == %@", resourceID)
        fr.predicate = idPredicate
        
        
        var results: [Item]? = []
        
        context.performAndWait {
            
            results = try? context.fetch(fr)
            
            if let extantItem = results?.first {
                extantItem.value = value
                foundToken = extantItem
            }
            else {
                foundToken = Item(context: context)
                foundToken?.resourceID = resourceID
                foundToken?.value = value
            }
    
            try? context.save()
        }
        
        return foundToken
    }
    
}
