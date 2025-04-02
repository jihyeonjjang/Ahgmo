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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
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
    
    @discardableResult
    func saveInfo(information: InfoEntity) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "InfoEntity", in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            managedObject.setValue(information.title, forKey: "title")
            managedObject.setValue(information.details, forKey: "details")
            managedObject.setValue(information.urlString, forKey: "urlString")
            managedObject.setValue(information.imageURL, forKey: "imageURL")
            
            do {
                try self.context.save()
                print("저장완료: \(managedObject)")
                return true
            } catch let error {
                print("데이터 저장 실패: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    
    @discardableResult
    func saveCategory(category: CategoryEntity) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            managedObject.setValue(category.title, forKey: "title")
            managedObject.setValue(category.isSelected, forKey: "isSelected")
            
            do {
                try self.context.save()
                print("저장완료: \(managedObject)")
                return true
            } catch let error {
                print("데이터 저장 실패: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    
    func fetchContext<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch let error {
            print("data fetch error: \(error.localizedDescription)")
            return []
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
        let context = persistentContainer.viewContext
        
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
        category1.isSelected = false
        
        let category2 = CategoryEntity(context: context)
        category2.id = UUID()
        category2.title = "신발"
        category2.isSelected = false
        
        let category3 = CategoryEntity(context: context)
        category3.id = UUID()
        category3.title = "코스트코"
        category3.isSelected = false
        
        let category4 = CategoryEntity(context: context)
        category4.id = UUID()
        category4.title = "아우터"
        category4.isSelected = false
        
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
