//
//  CategoriesPresenter.swift
//  NewsApp
//
//  Created by developer on 19.09.2025.
//

import Foundation
import CoreData

protocol CategoriesPresenter {
    func viewDidLoad()
    func searchNews(about category: String)
    func loadNextPageNews()
    func saveArticles(newArticles: [Article], category: String)
    func getArticles(category: String, page: Int, pageSize: Int) -> [Article]
}

final class CategoriesPresenterImpl {
    private weak var view: CategoriesViewController?
    
    private let networkManager = NetworkManager.shared
    
    private let coreDataService = CoreDataService.shared
    
    private let pageSize: Int = 20
    private var page: Int = 1
    private var isLoading: Bool = false
    private var allNews: [Article] = []
    private var currentCategory: String = "general"
}

extension CategoriesPresenterImpl {
    func setupView(_ view: CategoriesViewController) {
        self.view = view
    }
}


extension CategoriesPresenterImpl: CategoriesPresenter {
    func viewDidLoad() {
        loadNews(about: "general", isSearchQueryNew: true)
    }
    
    func searchNews(about: String) {
        currentCategory = about
        loadNews(about: about, isSearchQueryNew: true)
    }
    
    func loadNextPageNews() {
        guard !isLoading else { return }
        page += 1
        loadNews(about: currentCategory, isSearchQueryNew: false)
    }
    
    private func loadNews(about: String, isSearchQueryNew: Bool){
        if isSearchQueryNew {
            self.page = 1
            self.allNews.removeAll()
        }
        
        let savedNews = getArticles(category: about, page: self.page, pageSize: self.pageSize)
        if isSearchQueryNew {
            if savedNews.isEmpty {
                self.allNews.removeAll()
                DispatchQueue.main.async {
                    self.view?.showNews(news: [])
                }
            } else {
                self.allNews = savedNews
                DispatchQueue.main.async {
                    self.view?.showNews(news: savedNews)
                }
            }
        } else {
            if !savedNews.isEmpty {
                self.allNews.append(contentsOf: savedNews)
                DispatchQueue.main.async {
                    self.view?.loadMoreNews(news: savedNews)
                }
            }
        }
        
        isLoading = true
        view?.showLoadingState(isLoading: true)
        
        networkManager.searchNewsByCategory(category: about, page: self.page, pageSize: self.pageSize) { [weak self] result in
            
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.view?.showLoadingState(isLoading: false)
            }
            
            switch result {
            case .success(let success):
                let articles = success.articles ?? []
                
                let newArticles = self?.filterArticlesFromAPI(articles: articles, category: about) ?? []
                
                
                if !newArticles.isEmpty {
                    if isSearchQueryNew {
                        self?.allNews.append(contentsOf: newArticles)
                        DispatchQueue.main.async {
                            self?.view?.showNews(news: self?.allNews ?? [])
                        }
                    } else {
                        self?.allNews.append(contentsOf: newArticles)
                        DispatchQueue.main.async {
                            self?.view?.loadMoreNews(news: newArticles)
                        }
                    }
                    self?.saveArticles(newArticles: newArticles, category: about)
                }
                
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func filterArticlesFromAPI(articles: [Article], category: String) -> [Article] {
        let context = coreDataService.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
        do{
            let savedArticles = try context.fetch(fetchRequest)
            let savedURLs = savedArticles.compactMap { $0.url_ }

            return articles.filter { $0.url != nil && !savedURLs.contains($0.url!) }
            
        } catch {
            print("Fetching Failed")
            return []
        }
    }
    
    func saveArticles(newArticles: [Article], category: String) {
        let context = coreDataService.persistentContainer.viewContext
                
        for articleFromAPI in newArticles {
            let article = ArticleEntity(context: context)
            article.title_ = articleFromAPI.title
            article.urlToImage_ = articleFromAPI.urlToImage
            article.author_ = articleFromAPI.author
            article.description_ = articleFromAPI.description
            article.category_ = category
            article.keyword_ = ""
            article.url_ = articleFromAPI.url
        }
        
        coreDataService.saveContext { isSuccess in
            if isSuccess {
                print("Saved")
            }
            else {
                print("Not saved")
            }
        }
    }
    
    func getArticles(category: String, page: Int, pageSize: Int) -> [Article] {
        let context = coreDataService.persistentContainer.viewContext
        
        var savedArticles = [Article]()
        
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category_ == %@", category)
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = (page - 1) * pageSize
        
        do {
            let articles = try context.fetch(fetchRequest)
            for article in articles {
                var newArticle: Article = Article()
                
                newArticle.author = article.author_ ?? ""
                newArticle.title = article.title_ ?? ""
                newArticle.urlToImage = article.urlToImage_ ?? ""
                newArticle.description = article.description_ ?? ""
                newArticle.url = article.url_ ?? ""
                
                savedArticles.append(newArticle)
            }
        } catch {
            print("Fetching Failed")
        }
        
        return savedArticles
    }
}
