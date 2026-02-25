//
//  ExchangeListViewController.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import UIKit

class ExchangeListViewController: UIViewController {
    
    private let viewModel: ExchangeListViewModel
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(ExchangeTableViewCell.self, forCellReuseIdentifier: ExchangeTableViewCell.identifier)
        table.rowHeight = 100
        table.separatorStyle = .singleLine
        return table
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Puxe para atualizar a lista de exchanges"
        label.textAlignment = .center
        label.textColor = .mbSecondaryText
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private lazy var loadingFooterView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .mbOrange
        spinner.startAnimating()
        
        footerView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }()
    
    init(viewModel: ExchangeListViewModel) {
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
        loadInitialData()
    }
    
    private func setupUI() {
        title = "Exchanges"
        view.backgroundColor = .mbBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .mbBackground
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.mbOrange,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.mbOrange,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .mbOrange
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)
        
        refreshControl.tintColor = .mbOrange
        tableView.refreshControl = refreshControl
        
        tableView.backgroundColor = .mbBackground
        tableView.separatorColor = .mbSeparator
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func loadInitialData() {
        activityIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        viewModel.fetchExchanges(useMockData: false)
    }
    
    @objc private func handleRefresh() {
        emptyStateLabel.isHidden = true
        viewModel.fetchExchanges(useMockData: false)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.numberOfExchanges == 0
        emptyStateLabel.isHidden = !isEmpty || viewModel.isLoading
        tableView.isHidden = isEmpty && !viewModel.isLoading
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Erro",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Tentar novamente", style: .default) { [weak self] _ in
            self?.handleRefresh()
        })
        present(alert, animated: true)
    }
}

extension ExchangeListViewController: ExchangeListViewModelDelegate {
    
    func didUpdateState(_ state: ViewState<[Exchange]>) {
        refreshControl.endRefreshing()
        
        switch state {
        case .idle:
            break
            
        case .loading:
            if !refreshControl.isRefreshing {
                activityIndicator.startAnimating()
            }
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            tableView.tableFooterView = nil
            
        case .loaded(let exchanges):
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            
            if viewModel.isLoadingMore {
                tableView.tableFooterView = loadingFooterView
            } else if viewModel.hasMorePages {
                tableView.tableFooterView = nil
            } else {
                tableView.tableFooterView = createEndFooter()
            }
            
        case .empty:
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = "Nenhuma exchange encontrada.\nPuxe para atualizar."
            tableView.isHidden = true
            tableView.tableFooterView = nil
            
        case .error(let error):
            activityIndicator.stopAnimating()
            
            showError(error)
            
            if viewModel.numberOfExchanges == 0 {
                emptyStateLabel.isHidden = false
                emptyStateLabel.text = "Erro ao carregar.\nPuxe para tentar novamente."
                tableView.isHidden = true
            } else {
                tableView.isHidden = false
            }
            
            tableView.tableFooterView = nil
        }
    }
    
    private func createEndFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Todas as exchanges carregadas"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .mbSecondaryText
        label.textAlignment = .center
        
        footerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }
}

extension ExchangeListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfExchanges
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExchangeTableViewCell.identifier,
            for: indexPath
        ) as? ExchangeTableViewCell else {
            return UITableViewCell()
        }
        
        if let exchange = viewModel.exchange(at: indexPath.row) {
            cell.configure(with: exchange, viewModel: viewModel)
        }
        
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
        
        return cell
    }
}

extension ExchangeListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let exchange = viewModel.exchange(at: indexPath.row) {
            let detailViewModel = ExchangeDetailViewModel(exchange: exchange)
            let detailVC = ExchangeDetailViewController(viewModel: detailViewModel)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
