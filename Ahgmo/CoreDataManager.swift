//
//  CoreDataManager.swift
//  Ahgmo
//
//  Created by 지현 on 3/28/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared: CoreDataManager = .init()
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Ahgmo")
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext { return persistentContainer.viewContext }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(for entityType: T.Type) -> NSFetchedResultsController<T>? {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: entityType))
        
        if entityType == CategoryEntity.self {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        } else if entityType == InfoEntity.self {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        } else if entityType == SortTypeEntity.self  {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        } else {
            return nil
        }
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to fetch \(entityType): \(error.localizedDescription)")
            return nil
        }
        return controller
    }
    
    func fetchSingleEntity<T: NSManagedObject>(ofType type: T.Type, withPredicate predicate: NSPredicate? = nil) -> T? {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request) as? [T]
            return results?.first
        } catch {
            print("Fetch error:", error)
            return nil
        }
    }
    
    @discardableResult
    func saveCategory(title: String) -> UUID? {
        let entity = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            let id = UUID()
            managedObject.setValue(id, forKey: "id")
            managedObject.setValue(title, forKey: "title")
            
            do {
                try self.context.save()
                print("category save: \(managedObject)")
                return id
            } catch let error {
                print("category save error: \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    @discardableResult
    func saveInfo(title: String, details: String?, urlString: String, imageURL: String?, categoryID: UUID) -> UUID? {
        let entity = NSEntityDescription.entity(forEntityName: "InfoEntity", in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            let id = UUID()
            managedObject.setValue(id, forKey: "id")
            managedObject.setValue(title, forKey: "title")
            managedObject.setValue(details, forKey: "details")
            managedObject.setValue(urlString, forKey: "urlString")
            managedObject.setValue(imageURL, forKey: "imageURL")
            
            let predicate = NSPredicate(format: "id == %@", categoryID as CVarArg)
            guard let category = fetchSingleEntity(ofType: CategoryEntity.self, withPredicate: predicate) else { return nil }
            managedObject.setValue(category, forKey: "categoryItem")
            
            do {
                try self.context.save()
                print("information save: \(managedObject)")
                return id
            } catch let error {
                print("info data save error: \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    @discardableResult
    func updateCategory(id: UUID, title: String) -> UUID? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let category = fetchSingleEntity(ofType: CategoryEntity.self, withPredicate: predicate) else { return nil }
        category.title = title
        
        do {
            try context.save()
            print("category update")
            return id
        } catch {
            print("info update error: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func updateInfo(id: UUID, title: String?, details: String?, urlString: String?, imageURL: String?, categoryID: UUID?) -> UUID? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let info = fetchSingleEntity(ofType: InfoEntity.self, withPredicate: predicate) else { return nil }
        
        if let title = title {
            info.title = title
        }
        
        if let details = details {
            info.details = details
        }
        
        if let urlString = urlString {
            info.urlString = urlString
        }
        
        if let imageURL = imageURL {
            info.imageURL = imageURL
        }
        
        if let categoryID = categoryID {
            let categoryPredicate = NSPredicate(format: "id == %@", categoryID as CVarArg)
            if let category = fetchSingleEntity(ofType: CategoryEntity.self, withPredicate: categoryPredicate) {
                info.categoryItem = category
            }
        }
        
        do {
            try context.save()
            print("info update")
            return id
        } catch {
            print("info update error: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func delete(object: NSManagedObject) -> Bool {
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let error {
            print("data delete error: \(error.localizedDescription)")
            return false
        }
    }
    
    func insertMockData() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        
        let context = self.context
        
        let categoryFetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let infoFetchRequest: NSFetchRequest<InfoEntity> = InfoEntity.fetchRequest()
        let sortTypeFetchRequest: NSFetchRequest<SortTypeEntity> = SortTypeEntity.fetchRequest()
        
        do {
            let existingCategories = try context.fetch(categoryFetchRequest)
            let existingInfo = try context.fetch(infoFetchRequest)
            let existingSortTypes = try context.fetch(sortTypeFetchRequest)
            
            if !existingCategories.isEmpty || !existingInfo.isEmpty || !existingSortTypes.isEmpty {
                print("already exists")
                return
            }
        } catch {
            print("data existence check error: \(error)")
        }
        
        let category1 = CategoryEntity(context: context)
        category1.id = UUID()
        category1.title = "요리"
        
        let category2 = CategoryEntity(context: context)
        category2.id = UUID()
        category2.title = "신발"
        
        let category3 = CategoryEntity(context: context)
        category3.id = UUID()
        category3.title = "코스트코"
        
        let category4 = CategoryEntity(context: context)
        category4.id = UUID()
        category4.title = "아우터"
        
        let info1 = InfoEntity(context: context)
        info1.id = UUID()
        info1.title = "로제파스타 레시피"
        info1.details = "편스토랑 류수영 레시피"
        info1.urlString = "https://youtu.be/myYOcLR8Ni4?si=QYaZ3Fb0AwKKH-oD"
        info1.imageURL = "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg"
        info1.categoryItem = category1
        
        let info2 = InfoEntity(context: context)
        info2.id = UUID()
        info2.title = "호카 본디 8"
        info2.details = "족저근막염에 좋은 신발"
        info2.urlString = "https://youtu.be/xDHDEWG1kG4?si=fsXPT7DbxKMgzZEd"
        info2.imageURL = "https://img.youtube.com/vi/xDHDEWG1kG4/mqdefault.jpg"
        info2.categoryItem = category2
        
        let info3 = InfoEntity(context: context)
        info3.id = UUID()
        info3.title = "코스트코 베이글"
        info3.details = "13번"
        info3.urlString = "https://blog.naver.com/sum-merr/223288534510"
        info3.imageURL = "https://img.youtube.com/vi/xDHDEWG1kG4/mqdefault.jpg"
        info3.categoryItem = category3
        
        let info4 = InfoEntity(context: context)
        info4.id = UUID()
        info4.title = "코스트코 샐러드"
        info4.details = "14번"
        info4.urlString = "https://blog.naver.com/sum-merr/223288534510"
        info4.imageURL = "https://img.youtube.com/vi/xDHDEWG1kG4/mqdefault.jpg"
        info4.categoryItem = category3
        
        let info5 = InfoEntity(context: context)
        info5.id = UUID()
        info5.title = "무탠다드 코트"
        info5.details = "발마칸, 99890원"
        info5.urlString = "https://www.musinsa.com/products/4209266"
        info5.imageURL = "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg"
        info5.categoryItem = category4
        
        let info6 = InfoEntity(context: context)
        info6.id = UUID()
        info6.title = "디네댓 패딩"
        info6.details = "덕다운, 191200원"
        info6.urlString = "https://www.musinsa.com/products/4460714"
        info6.imageURL = "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg"
        info6.categoryItem = category4
        
        let info7 = InfoEntity(context: context)
        info7.id = UUID()
        info7.title = "뉴발란스 패딩"
        info7.details = "구스다운, 299000원"
        info7.urlString = "https://www.musinsa.com/products/4507921"
        info7.imageURL = "https://img.youtube.com/vi/myYOcLR8Ni4/mqdefault.jpg"
        info7.categoryItem = category4
        
        let sortType1 = SortTypeEntity(context: context)
        sortType1.id = UUID()
        sortType1.title = "정보"
        sortType1.isSortedAscending = true
        
        let sortType2 = SortTypeEntity(context: context)
        sortType2.id = UUID()
        sortType2.title = "카테고리"
        sortType2.isSortedAscending = true
        
        do {
            try context.save()
            print("Mock data")
        } catch {
            print("Mock data error: \(error)")
        }
    }
}
