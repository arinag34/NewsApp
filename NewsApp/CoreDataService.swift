//
//  CoreDataController.swift
//  NewsApp
//
//  Created by developer on 24.09.2025.
//

import Foundation
import CoreData

final class CoreDataService {
    static let shared = CoreDataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "NewsModel")
        
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
        
            return container
        }()
    
    func saveContext (completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion(true)
            } catch {
                let nserror = error as NSError
                print(nserror)
                completion(false)
            }
        }
    }
    
    func fetchContext(completion: @escaping (ArticleEntity?, String?) -> Void) {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            
            do {
                let articles = try context.fetch(fetchRequest)
                for article in articles {
                    completion(article, nil)
                }
            } catch {
                completion(nil, "First, you should save article info")
            }
        }
}
