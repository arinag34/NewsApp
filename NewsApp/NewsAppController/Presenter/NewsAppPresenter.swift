import Foundation
import CoreData

protocol NewsAppPresenter {
    func viewDidLoad()
    func searchNews(by keyword: String)
    func loadNextPageNews()
    func saveArticles(newArticles: [Article], keyword: String)
    func getArticles(keyword: String, page: Int, pageSize: Int) -> [Article]
}

final class NewsAppPresenterImpl {
    private weak var view: NewsAppViewController?
    
    private let networkManager = NetworkManager.shared
    
    private let coreDataService = CoreDataService.shared
    
    private let pageSize: Int = 20
    private var page: Int = 1
    private var isLoading: Bool = false
    private var allNews: [Article] = []
    private var currentKeyword: String = "news"
}

extension NewsAppPresenterImpl {
    func setupView(_ view: NewsAppViewController) {
        self.view = view
    }
}

extension NewsAppPresenterImpl: NewsAppPresenter {
    func viewDidLoad() {
        loadNews(keyword: "news", isSearchQueryNew: true)
    }
    
    func searchNews(by keyword: String) {
        currentKeyword = keyword
        loadNews(keyword: keyword, isSearchQueryNew: true)
    }
    
    func loadNextPageNews() {
        guard !isLoading else { return }
        page += 1
        loadNews(keyword: currentKeyword, isSearchQueryNew: false)
    }
    
    private func loadNews(keyword: String, isSearchQueryNew: Bool){
        if isSearchQueryNew {
            self.page = 1
            self.allNews.removeAll()
        }
        
        let savedNews = getArticles(keyword: keyword, page: self.page, pageSize: self.pageSize)
        
        if !savedNews.isEmpty {
            if isSearchQueryNew {
                self.allNews = savedNews
                DispatchQueue.main.async {
                    self.view?.showNews(news: savedNews)
                }
            }
            else{
                self.allNews.append(contentsOf: savedNews)
                DispatchQueue.main.async {
                    self.view?.loadMoreNews(news: savedNews)
                }
            }
        }
        
        isLoading = true
        view?.showLoadingState(isLoading: true)
        
        networkManager.searchNewsByKeyword(keyword: keyword, page: self.page, pageSize: self.pageSize) { [weak self] result in
            
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.view?.showLoadingState(isLoading: false)
            }
            
            switch result {
            case .success(let success):
                let articles = success.articles ?? []

                let newArticles = self?.filterArticlesFromAPI(articles: articles, keyword: keyword) ?? []
                
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
                    self?.saveArticles(newArticles: newArticles, keyword: keyword)
                }
                                
            case .failure(let failure):
                if self?.allNews.isEmpty == true {
                    let savedArticles = self?.getArticles(
                        keyword: keyword,
                        page: self?.page ?? 1,
                        pageSize: self?.pageSize ?? 20
                    ) ?? []

                    self?.allNews = savedArticles
                    DispatchQueue.main.async {
                        self?.view?.showNews(news: savedArticles)
                    }
                }
                print(failure)
            }
        }
    }

    private func filterArticlesFromAPI(articles: [Article], keyword: String) -> [Article] {
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
    
    func saveArticles(newArticles: [Article], keyword: String) {
        let context = coreDataService.persistentContainer.viewContext
                
        for articleFromAPI in newArticles {
            let article = ArticleEntity(context: context)
            article.title_ = articleFromAPI.title
            article.urlToImage_ = articleFromAPI.urlToImage
            article.author_ = articleFromAPI.author
            article.description_ = articleFromAPI.description
            article.url_ = articleFromAPI.url
            article.category_ = ""
            article.keyword_ = keyword
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
    
    func getArticles(keyword: String, page: Int, pageSize: Int) -> [Article] {
        let context = coreDataService.persistentContainer.viewContext
        
        var savedArticles = [Article]()
        
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "keyword_ == %@", keyword)
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

