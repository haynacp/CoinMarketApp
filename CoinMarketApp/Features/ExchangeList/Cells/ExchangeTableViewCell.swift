//
//  ExchangeTableViewCell.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import UIKit

class ExchangeTableViewCell: UITableViewCell {
    
    static let identifier = "ExchangeTableViewCell"
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .mbSecondaryBackground
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.tintColor = .mbOrange
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .mbPrimaryText
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .mbSecondaryText
        return label
    }()
    
    private lazy var volumeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .mbOrange
        label.textAlignment = .right
        return label
    }()
    
    private lazy var volumeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .mbSecondaryText
        label.text = "Volume 24h"
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .mbBackground
        contentView.backgroundColor = .mbBackground
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(volumeLabel)
        contentView.addSubview(volumeTitleLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: volumeLabel.leadingAnchor, constant: -12),
            
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            volumeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            volumeTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            volumeLabel.trailingAnchor.constraint(equalTo: volumeTitleLabel.trailingAnchor),
            volumeLabel.topAnchor.constraint(equalTo: volumeTitleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with exchange: Exchange, viewModel: ExchangeListViewModel) {
        nameLabel.text = exchange.name
        dateLabel.text = "Lançada em: \(viewModel.formattedDate(for: exchange))"
        volumeLabel.text = viewModel.formattedVolume(for: exchange)
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let defaultIcon = UIImage(systemName: "building.columns.fill", withConfiguration: config)
        
        if let logoURL = exchange.logo, let url = URL(string: logoURL) {
            logoImageView.loadImage(from: url, placeholder: defaultIcon)
        } else {
            logoImageView.image = defaultIcon
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        volumeLabel.text = nil
        logoImageView.cancelImageLoad()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        logoImageView.image = UIImage(systemName: "building.columns.fill", withConfiguration: config)
    }
}
