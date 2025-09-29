import Foundation
import UIKit

let ApiKey = "474465f990ed403081732ee0ed3f31bb"

enum ErrorMessages: String, Error {
    case invalidData = "Sorry, something went wrong"
    case invalidResponse = "Sorry, it's an invalid response"
}

final class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession(configuration: .default)
    
    func searchNewsByCategory(category: String, page: Int, pageSize: Int, completionHandler: @escaping (Result<NewsSearchResult, ErrorMessages>) -> Void) {
        guard let urlString = URL(string: "https://newsapi.org/v2/top-headlines?category=\(category)&apiKey=\(ApiKey)&page=\(page)&pageSize=\(pageSize)") else {return}
        
        guard !category.isEmpty else {return}
        
        let dataTask = session.dataTask(with: urlString) { data, response, error in
            if let _ = error {
                completionHandler(.failure(.invalidData))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }
            
            do {
                let results = try JSONDecoder().decode(NewsSearchResult.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(results))
                }
            } catch {
                completionHandler(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
    
    func searchNewsByKeyword(keyword: String, page: Int, pageSize: Int, completionHandler: @escaping (Result<NewsSearchResult, ErrorMessages>) -> Void) {
        guard let urlString = URL(string: "https://newsapi.org/v2/everything?q=\(keyword)&apiKey=\(ApiKey)&page=\(page)&pageSize=\(pageSize)") else {return}
        
        guard !keyword.isEmpty && keyword != " " else {return}
                
        let dataTask = session.dataTask(with: urlString) { data, response, error in
            if let _ = error {
                completionHandler(.failure(.invalidData))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }
            
            do {
                let results = try JSONDecoder().decode(NewsSearchResult.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(results))
                }
            } catch {
                completionHandler(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
}
