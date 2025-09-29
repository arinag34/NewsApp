//
//  NewsTableCell.swift
//  NewsApp
//
//  Created by developer on 23.09.2025.
//

import UIKit

class NewsTableCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = createLabel(labelTextColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), labelSize: 17, labelWeight: .bold)
        return label
    }()
    lazy var authorLabel: UILabel = {
        let label = createLabel(labelTextColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), labelSize: 12, labelWeight: .regular)
        return label
    }()
    lazy var descriptionLabel: UILabel = {
        let label = createLabel(labelTextColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), labelSize: 14, labelWeight: .regular)
        return label
    }()
    lazy var imageViewNews: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        
        return $0
    }(UIImageView())
    
    private func createLabel(labelTextColor: UIColor, labelSize: CGFloat, labelWeight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.textColor = labelTextColor
        label.font = .systemFont(ofSize: labelSize, weight: labelWeight)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(imageViewNews)
        
        NSLayoutConstraint.activate([
            imageViewNews.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageViewNews.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageViewNews.widthAnchor.constraint(equalToConstant: 100),
            imageViewNews.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: imageViewNews.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: imageViewNews.trailingAnchor, constant: 8),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageViewNews.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
