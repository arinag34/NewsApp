//
//  CategoriesView.swift
//  NewsApp
//
//  Created by developer on 19.09.2025.
//

import Foundation
import UIKit

protocol CategoriesViewController: AnyObject {
    func showNews(news: [Article])
    func loadMoreNews(news: [Article])
    func showLoadingState(isLoading: Bool)
}

final class CategoriesViewControllerImpl: UIViewController {
    
    private let presenter: CategoriesPresenter
    private var news: [Article] = []
    
    private lazy var buttonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        return $0
    }(UIView())
    
    private lazy var backButton: UIButton = {
        $0.setTitle("<- Back to Main", for: .normal)
        $0.setTitleColor(#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        
        let buttonAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        $0.addAction(buttonAction, for: .touchUpInside)
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        return $0
    }(UIButton())
    
    private lazy var newsTable: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.register(NewsTableCell.self, forCellReuseIdentifier: "newsCategoriesCell")
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())

    lazy var noNewsLabel: UILabel = {
        $0.text = "There's no recent news in this category or you have no cached news in it. Please, check your internet connection or choose another one or use the search bar on the previous page"
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
    
    lazy var generalButton = createCategoryButton(title: "General")
    lazy var businessButton = createCategoryButton(title: "Business")
    lazy var entertainmentButton = createCategoryButton(title: "Entertainment")
    lazy var healthButton = createCategoryButton(title: "Health")
    lazy var scienceButton = createCategoryButton(title: "Science")
    lazy var sportsButton = createCategoryButton(title: "Sports")
    lazy var technologyButton = createCategoryButton(title: "Technology")

    lazy var buttons: [UIButton] = [generalButton, businessButton, entertainmentButton, healthButton, scienceButton, sportsButton, technologyButton]
    
    private func createCategoryButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        
        let buttonAction = UIAction { [weak self] _ in
                     self?.showNewsFromChosenCategoryAction(button)
                }
        
        button.addAction(buttonAction, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    

    init(presenter: CategoriesPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.title = "Categories"
        view.backgroundColor = #colorLiteral(red: 0.973554194, green: 1, blue: 0.9483045936, alpha: 1)
        generalButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        noNewsLabel.isHidden = true
        presenter.viewDidLoad()
        
        if(view.bounds.width < view.bounds.height){
            setupUI()
        }
        else{
            setupLandscapeUI()
        }
    }
    
    lazy var portraitConstraints: [NSLayoutConstraint] = [
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
        
        generalButton.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
        generalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 75),
        
        healthButton.topAnchor.constraint(equalTo: generalButton.topAnchor),
        healthButton.leadingAnchor.constraint(equalTo: generalButton.trailingAnchor, constant: 8),
        
        scienceButton.topAnchor.constraint(equalTo: generalButton.topAnchor),
        scienceButton.leadingAnchor.constraint(equalTo: healthButton.trailingAnchor, constant: 8),
        
        sportsButton.topAnchor.constraint(equalTo: generalButton.bottomAnchor, constant: 8),
        sportsButton.leadingAnchor.constraint(equalTo: generalButton.leadingAnchor),
        
        technologyButton.topAnchor.constraint(equalTo: sportsButton.topAnchor),
        technologyButton.leadingAnchor.constraint(equalTo: sportsButton.trailingAnchor, constant: 8),
        
        businessButton.topAnchor.constraint(equalTo: sportsButton.topAnchor),
        businessButton.leadingAnchor.constraint(equalTo: technologyButton.trailingAnchor, constant: 8),
        
        entertainmentButton.topAnchor.constraint(equalTo: sportsButton.bottomAnchor, constant: 8),
        entertainmentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
        newsTable.topAnchor.constraint(equalTo: entertainmentButton.bottomAnchor, constant: 10),
        newsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        newsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        newsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
        
        noNewsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        noNewsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        noNewsLabel.widthAnchor.constraint(equalToConstant: 250),
        
        newsLoader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        newsLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ]
    
    lazy var landscapeConstraints: [NSLayoutConstraint] = [
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
        
        buttonContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
        buttonContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        buttonContainer.widthAnchor.constraint(equalToConstant: 150),
        buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        
        generalButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 8),
        generalButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        healthButton.topAnchor.constraint(equalTo: generalButton.bottomAnchor, constant: 5),
        healthButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        scienceButton.topAnchor.constraint(equalTo: healthButton.bottomAnchor, constant: 5),
        scienceButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        sportsButton.topAnchor.constraint(equalTo: scienceButton.bottomAnchor, constant: 8),
        sportsButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        technologyButton.topAnchor.constraint(equalTo: sportsButton.bottomAnchor, constant: 8),
        technologyButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        businessButton.topAnchor.constraint(equalTo: technologyButton.bottomAnchor, constant: 8),
        businessButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        entertainmentButton.topAnchor.constraint(equalTo: businessButton.bottomAnchor, constant: 8),
        entertainmentButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        
        newsTable.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
        newsTable.leadingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: 10),
        newsTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        newsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
        
        noNewsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        noNewsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        noNewsLabel.widthAnchor.constraint(equalToConstant: 250),
        
        newsLoader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        newsLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ]
    
    private func setupUI() {
        view.addSubview(generalButton)
        view.addSubview(healthButton)
        view.addSubview(scienceButton)
        view.addSubview(sportsButton)
        view.addSubview(technologyButton)
        view.addSubview(businessButton)
        view.addSubview(entertainmentButton)
        
        view.addSubview(backButton)
        view.addSubview(newsTable)
        view.addSubview(noNewsLabel)
        view.addSubview(newsLoader)
        
        NSLayoutConstraint.deactivate(landscapeConstraints)
        NSLayoutConstraint.activate(portraitConstraints)
    }

    private func setupLandscapeUI() {
        view.addSubview(buttonContainer)
        
        buttonContainer.addSubview(generalButton)
        buttonContainer.addSubview(healthButton)
        buttonContainer.addSubview(scienceButton)
        buttonContainer.addSubview(sportsButton)
        buttonContainer.addSubview(technologyButton)
        buttonContainer.addSubview(businessButton)
        buttonContainer.addSubview(entertainmentButton)
        
        view.addSubview(backButton)
        view.addSubview(newsTable)
        view.addSubview(noNewsLabel)
        view.addSubview(newsLoader)
        NSLayoutConstraint.deactivate(portraitConstraints)
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            if (size.width > size.height) {
                self.setupLandscapeUI()
            } else {
                self.setupUI()
            }
        })
    }

    
    private func showNewsFromChosenCategoryAction(_ sender: UIButton) {
        for button in buttons {
            button.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
        sender.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        presenter.searchNews(about: (sender.titleLabel?.text)!.lowercased())
    }
}

extension CategoriesViewControllerImpl: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCategoriesCell", for: indexPath) as! NewsTableCell
        cell.backgroundColor = #colorLiteral(red: 0.973554194, green: 1, blue: 0.9483045936, alpha: 1)
        
        cell.titleLabel.text = news[indexPath.row].title ?? ""
        cell.authorLabel.text = "By: " + (news[indexPath.row].author ?? "Unknown")
        cell.descriptionLabel.text = news[indexPath.row].description ?? ""
        cell.imageViewNews.sd_setImage(with: URL(string: news[indexPath.row].urlToImage ?? ""), placeholderImage: UIImage(systemName: "questionmark"))

        return cell
    }
}

extension CategoriesViewControllerImpl: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            presenter.loadNextPageNews()
        }
    }
}

extension CategoriesViewControllerImpl: CategoriesViewController {
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
