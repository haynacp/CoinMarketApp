//
//  ExchangeDetailViewController.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import UIKit

class ExchangeDetailViewController: UIViewController {
    
    private let viewModel: ExchangeDetailViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Descrição"
        label.textColor = .mbOrange
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .mbSecondaryText
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var currenciesTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Moedas"
        label.textColor = .mbOrange
        return label
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sem informações de holdings\n(Disponível apenas para carteiras com +$100k USD)"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .mbSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        table.rowHeight = 60
        table.isScrollEnabled = false
        table.layer.cornerRadius = 12
        table.clipsToBounds = true
        return table
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var scrollToTopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .mbOrange
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.alpha = 0
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(scrollToTopTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    init(viewModel: ExchangeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        loadData()
    }
    
    private func setupUI() {
        title = "Detalhes"
        view.backgroundColor = .mbBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .mbBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.mbOrange,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .mbOrange
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(currenciesTitleLabel)
        contentView.addSubview(emptyStateLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(activityIndicator)
        
        view.addSubview(scrollToTopButton)
        
        scrollView.backgroundColor = .mbBackground
        contentView.backgroundColor = .mbBackground
        tableView.backgroundColor = .mbBackground
        tableView.separatorColor = .mbSeparator
        activityIndicator.color = .mbOrange
        
        setupConstraints()
        populateInfoCards()
        updateContent()
    }
    
    private func setupConstraints() {
        let tableHeight = tableView.rowHeight * CGFloat(max(viewModel.numberOfCurrencies, 1))
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        tableHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            currenciesTitleLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            currenciesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currenciesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emptyStateLabel.topAnchor.constraint(equalTo: currenciesTitleLabel.bottomAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            tableView.topAnchor.constraint(equalTo: currenciesTitleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            scrollToTopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollToTopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 56),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
        scrollView.delegate = self
    }
    
    private func loadData() {
        
        if viewModel.exchange.logo == nil || viewModel.exchange.spotVolumeUsd == nil {
            viewModel.fetchExchangeDetails()
        } else {
        }
        viewModel.fetchCurrencies()
    }
    
    private func updateContent() {
        let exchange = viewModel.exchange
        
        nameLabel.text = exchange.name
        idLabel.text = "ID: \(exchange.id)"
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        let defaultIcon = UIImage(systemName: "building.columns.fill", withConfiguration: config)
        
        if let logoURL = exchange.logo, let url = URL(string: logoURL) {
            logoImageView.loadImage(from: url, placeholder: defaultIcon)
        } else {
            logoImageView.image = defaultIcon
        }
        
        descriptionLabel.text = exchange.description ?? "Sem descrição disponível"
        
        let tableHeight = tableView.rowHeight * CGFloat(max(viewModel.numberOfCurrencies, 1))
        tableHeightConstraint?.constant = tableHeight
        
        tableView.reloadData()
        view.layoutIfNeeded()
    }
    
    private func populateInfoCards() {
        _ = viewModel.exchange
        
        let websiteCard = createInfoCard(
            title: "Website",
            value: viewModel.formattedWebsite(),
            icon: "globe"
        )
        infoStackView.addArrangedSubview(websiteCard)
        
        let makerFeeCard = createInfoCard(
            title: "Maker Fee",
            value: viewModel.formattedMakerFee(),
            icon: "chart.line.uptrend.xyaxis"
        )
        infoStackView.addArrangedSubview(makerFeeCard)
        
        let takerFeeCard = createInfoCard(
            title: "Taker Fee",
            value: viewModel.formattedTakerFee(),
            icon: "chart.line.downtrend.xyaxis"
        )
        infoStackView.addArrangedSubview(takerFeeCard)
        
        let dateCard = createInfoCard(
            title: "Data de Lançamento",
            value: viewModel.formattedDate(),
            icon: "calendar"
        )
        infoStackView.addArrangedSubview(dateCard)
    }
    
    private func createInfoCard(title: String, value: String, icon: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .mbSecondaryBackground
        container.layer.cornerRadius = 12
        
        container.layer.borderWidth = 1.5
        container.layer.borderColor = UIColor.mbOrange.withAlphaComponent(0.3).cgColor
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .mbOrange
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .mbSecondaryText
        titleLabel.text = title
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.text = value
        valueLabel.textColor = .mbPrimaryText
        valueLabel.numberOfLines = 0
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Erro",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func scrollToTopTapped() {
        scrollView.setContentOffset(.zero, animated: true)
    }
}

extension ExchangeDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let shouldShowButton = offsetY > 300
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.scrollToTopButton.alpha = shouldShowButton ? 1.0 : 0.0
            self.scrollToTopButton.transform = shouldShowButton ? .identity : CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
}

extension ExchangeDetailViewController: ExchangeDetailViewModelDelegate {
    
    func didUpdateExchangeDetails() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.updateContent()
        }
    }
    
    func didUpdateMarkets() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if self.viewModel.numberOfCurrencies > 0 {
                self.emptyStateLabel.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
                
                let tableHeight = self.tableView.rowHeight * CGFloat(self.viewModel.numberOfCurrencies)
                self.tableHeightConstraint?.constant = tableHeight
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                self.emptyStateLabel.isHidden = false
                self.tableView.isHidden = true
                self.tableHeightConstraint?.constant = 100
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.showError(error)
        }
    }
}

extension ExchangeDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.numberOfCurrencies
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrencyTableViewCell.identifier,
            for: indexPath
        ) as? CurrencyTableViewCell else {
            return UITableViewCell()
        }
        
        if let currency = viewModel.currency(at: indexPath.row) {
            cell.configure(with: currency, viewModel: viewModel)
        } else {
        }
        
        return cell
    }
}

extension ExchangeDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
