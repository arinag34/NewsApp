import Foundation

struct NewsSearchResult: Codable {
    var totalResults: Int
    var articles: [Article]?
}

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var urlToImage: String?
    var url: String?
}
