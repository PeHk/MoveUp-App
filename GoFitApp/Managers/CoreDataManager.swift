//
//  CoreDataManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//
import Foundation
import CoreData
import Combine

typealias Action = (()->())

struct CoreDataSaveModelPublisher: Publisher {
    typealias Output = Bool
    typealias Failure = NSError
    
    private let action: Action
    private let context: NSManagedObjectContext
    
    init(action: @escaping Action, context: NSManagedObjectContext) {
        self.action = action
        self.context = context
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, action: action)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreDataSaveModelPublisher {
    class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let action: Action
        private let context: NSManagedObjectContext
        
        init(subscriber: S, context: NSManagedObjectContext, action: @escaping Action) {
            self.subscriber = subscriber
            self.context = context
            self.action = action
        }
    }
}

extension CoreDataSaveModelPublisher.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber = subscriber, demand > 0 else { return }
        
        do {
            action()
            demand -= 1
            try context.save()
            demand += subscriber.receive(true)
        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension CoreDataSaveModelPublisher.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}

struct CoreDataFetchResultsPublisher<Entity>: Publisher where Entity: NSManagedObject {
    typealias Output = [Entity]
    typealias Failure = NSError
    
    private let request: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext
    
    init(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
        self.request = request
        self.context = context
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, request: request)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreDataFetchResultsPublisher {
    class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private var request: NSFetchRequest<Entity>
        private var context: NSManagedObjectContext
        
        init(subscriber: S, context: NSManagedObjectContext, request: NSFetchRequest<Entity>) {
            self.subscriber = subscriber
            self.context = context
            self.request = request
        }
    }
}


extension CoreDataFetchResultsPublisher.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber = subscriber, demand > 0 else { return }
        do {
            demand -= 1
            let items = try context.fetch(request)
            demand += subscriber.receive(items)
        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension CoreDataFetchResultsPublisher.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}

struct CoreDataDeleteModelPublisher: Publisher {
    typealias Output = NSBatchDeleteResult
    typealias Failure = NSError
    
    private let request: NSFetchRequest<NSFetchRequestResult>
    private let context: NSManagedObjectContext
    
    init(delete request: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) {
        self.request = request
        self.context = context
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, request: request)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreDataDeleteModelPublisher {
    class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let request: NSFetchRequest<NSFetchRequestResult>
        private var context: NSManagedObjectContext
        
        init(subscriber: S, context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>) {
            self.subscriber = subscriber
            self.context = context
            self.request = request
        }
    }
}

extension CoreDataDeleteModelPublisher.Subscription: Subscription  {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber = subscriber, demand > 0 else { return }
        
        do {
            demand -= 1
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: self.request)
            batchDeleteRequest.resultType = .resultTypeCount
            
            if let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                demand += subscriber.receive(result)
            }
            else {
                subscriber.receive(completion: .failure(NSError()))
            }
            
        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension CoreDataDeleteModelPublisher.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}

enum StorageType {
    case persistent, inMemory
}

extension NSManagedObject {
    class var entityName: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

protocol EntityCreating {
    var viewContext: NSManagedObjectContext { get }
    func createEntity<T: NSManagedObject>() -> T
}

extension EntityCreating {
    func createEntity<T: NSManagedObject>() -> T {
        T(context: viewContext)
    }
}

protocol CoreDataFetchResultsPublishing {
    var viewContext: NSManagedObjectContext { get }
    func publicher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> CoreDataFetchResultsPublisher<T>
}

extension CoreDataFetchResultsPublishing {
    func publicher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> CoreDataFetchResultsPublisher<T> {
        return CoreDataFetchResultsPublisher(request: request, context: viewContext)
    }
}

protocol CoreDataDeleteModelPublishing {
    var viewContext: NSManagedObjectContext { get }
    func publicher(delete request: NSFetchRequest<NSFetchRequestResult>) -> CoreDataDeleteModelPublisher
}

extension CoreDataDeleteModelPublishing {
    func publicher(delete request: NSFetchRequest<NSFetchRequestResult>) -> CoreDataDeleteModelPublisher {
        return CoreDataDeleteModelPublisher(delete: request, context: viewContext)
    }
}

protocol CoreDataSaveModelPublishing {
    var viewContext: NSManagedObjectContext { get }
    func publicher(save action: @escaping Action) -> CoreDataSaveModelPublisher
}

extension CoreDataSaveModelPublishing {
    func publicher(save action: @escaping Action) -> CoreDataSaveModelPublisher {
        return CoreDataSaveModelPublisher(action: action, context: viewContext)
    }
}

protocol CoreDataStoring: EntityCreating, CoreDataFetchResultsPublishing, CoreDataDeleteModelPublishing, CoreDataSaveModelPublishing {
    var viewContext: NSManagedObjectContext { get }
}

class CoreDataStore: CoreDataStoring {
    
    private let container: NSPersistentContainer
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter
    }()
    
    
    static var `default`: CoreDataStoring = {
        return CoreDataStore(name: "CoreDataExample", in: .persistent)
    }()
    
    var viewContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    init(name: String, in storageType: StorageType) {
        self.container = NSPersistentContainer(name: name)
        self.setupIfMemoryStorage(storageType)
        self.container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private func setupIfMemoryStorage(_ storageType: StorageType) {
        if storageType  == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.container.persistentStoreDescriptions = [description]
        }
    }
}
