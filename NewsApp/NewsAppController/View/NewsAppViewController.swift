import UIKit
import SDWebImage

protocol NewsAppViewController: AnyObject {
    func showNews(news: [Article])
    func loadMoreNews(news: [Article])
    func showLoadingState(isLoading: Bool)
}

final class NewsAppViewControllerImpl: UIViewController {

    private let presenter: NewsAppPresenter
    private var news: [Article] = []
    
    private lazy var searchController: UISearchController = {
        $0.searchBar.delegate = self
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = "recent ios update"
        $0.searchBar.frame = .zero
        return $0
    }(UISearchController(searchResultsController: nil))
    
    
    private lazy var newsTable: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.register(NewsTableCell.self, forCellReuseIdentifier: "newsCell")
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    private lazy var browseCategoriesButton: UIButton = {
        $0.setTitle("Browse categories", for: .normal)
        $0.setTitleColor(#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        let buttonAction = UIAction { [weak self] _ in
                     self?.showCategoriesViewAction()
                }
        
        $0.addAction(buttonAction, for: .touchUpInside)
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        return $0
    }(UIButton())
    
    lazy var noNewsLabel: UILabel = {
        $0.text = "There's no news for your search or you have no cached news for it. Please, check your internet connection or try another search or browse available categories."
        $0.textColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        
        return $0
    }(UILabel())
    
    lazy var newsLoader: UIActivityIndicatorView = {
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.color = .gray
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        return $0
    }(UIActivityIndicatorView())

    init(presenter: NewsAppPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
        view.backgroundColor = #colorLiteral(red: 0.973554194, green: 1, blue: 0.9483045936, alpha: 1)
        noNewsLabel.isHidden = true
        presenter.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        view.addSubview(newsTable)
        view.addSubview(browseCategoriesButton)
        view.addSubview(noNewsLabel)
        view.addSubview(newsLoader)
        
        
        NSLayoutConstraint.activate([
            browseCategoriesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            browseCategoriesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            newsTable.topAnchor.constraint(equalTo: browseCategoriesButton.bottomAnchor, constant: 15),
            newsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            newsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            noNewsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noNewsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noNewsLabel.widthAnchor.constraint(equalToConstant: 250),
            
            newsLoader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            newsLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    private func showCategoriesViewAction() {
        self.navigationController?.pushViewController(makeCategoriesViewController(), animated: true)
    }
    
    private func makeCategoriesViewController() -> UIViewController {
        let presenter = CategoriesPresenterImpl()
        let view = CategoriesViewControllerImpl(presenter: presenter)
        
        presenter.setupView(view)
        
        return view
    }
}

extension NewsAppViewControllerImpl: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keywords = searchBar.text, !keywords.isEmpty else { return }
        presenter.searchNews(by: keywords)
        searchBar.resignFirstResponder()
    }
}

extension NewsAppViewControllerImpl: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableCell
        cell.backgroundColor = #colorLiteral(red: 0.973554194, green: 1, blue: 0.9483045936, alpha: 1)
        
        cell.titleLabel.text = news[indexPath.row].title ?? ""
        cell.authorLabel.text = "By: " + (news[indexPath.row].author ?? "Unknown")
        cell.descriptionLabel.text = news[indexPath.row].description ?? ""
        cell.imageViewNews.sd_setImage(with: URL(string: news[indexPath.row].urlToImage ?? ""), placeholderImage: UIImage(systemName: "questionmark"))

        return cell
    }
}

extension NewsAppViewControllerImpl: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            presenter.loadNextPageNews()
        }
    }
}

extension NewsAppViewControllerImpl: NewsAppViewController {
    func showNews(news: [Article]) {
        self.news = news
        newsTable.reloadData()
        
        noNewsLabel.isHidden = !news.isEmpty
        newsTable.isHidden = news.isEmpty
    }
    
    func loadMoreNews(news: [Article]) {
        self.news.append(contentsOf: news)
        newsTable.reloadData()
    }
    
    func showLoadingState(isLoading: Bool) {
        if isLoading {
            newsLoader.startAnimating()
        } else {
            newsLoader.stopAnimating()
        }
    }
}
