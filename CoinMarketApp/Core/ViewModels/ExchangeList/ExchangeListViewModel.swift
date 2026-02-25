//
//  ExchangeListViewModel.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import Foundation

protocol ExchangeListViewModelDelegate: AnyObject {
    func didUpdateState(_ state: ViewState<[Exchange]>)
}

class ExchangeListViewModel {
    
    weak var delegate: ExchangeListViewModelDelegate?
    
    private let service: CoinMarketCapService
    
    private(set) var state: ViewState<[Exchange]> = .idle {
        didSet {
            delegate?.didUpdateState(state)
        }
    }
    
    private var allExchanges: [Exchange] = []
    private var currentPage = 0
    private let pageSize = 20
    private(set) var isLoadingMore = false
    private(set) var hasMorePages = true
    
    var exchanges: [Exchange] {
        return state.data ?? []
    }
    
    var numberOfExchanges: Int {
        return exchanges.count
    }
    
    var isLoading: Bool {
        return state.isLoading
    }
    
    init(service: CoinMarketCapService = .shared) {
        self.service = service
    }
    
    func fetchExchanges(useMockData: Bool = false) {
        guard !state.isLoading else {
            return
        }
        
        currentPage = 0
        allExchanges = []
        hasMorePages = true
        
        state = .loading
        
        if useMockData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                let mockData = Exchange.mockData
                
                if mockData.isEmpty {
                    self.state = .empty
                } else {
                    self.allExchanges = mockData
                    self.state = .loaded(mockData)
                }
            }
            return
        }
        
        loadPage()
    }
    
    func loadMoreIfNeeded(currentIndex: Int) {
        guard !isLoadingMore,
              !state.isLoading,
              hasMorePages,
              currentIndex >= exchanges.count - 5 else {
            return
        }
        
        loadPage()
    }
    
    private func loadPage() {
        guard !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        let isFirstPage = currentPage == 0
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let allData: [Exchange]
                
                if isFirstPage {
                    allData = try await self.service.fetchExchanges(limit: 50)
                    
                    await MainActor.run {
                        self.allExchanges = allData
                    }
                } else {
                    allData = self.allExchanges
                }
                
                await MainActor.run {
                    let start = self.currentPage * self.pageSize
                    let end = min(start + self.pageSize, allData.count)
                    
                    if start >= allData.count {
                        self.hasMorePages = false
                        self.isLoadingMore = false
                        return
                    }
                    
                    let pageData = Array(allData[start..<end])
                    
                    var displayedData = self.exchanges
                    displayedData.append(contentsOf: pageData)
                    
                    self.currentPage += 1
                    self.isLoadingMore = false
                    
                    if end >= allData.count {
                        self.hasMorePages = false
                    }
                    
                    if displayedData.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .loaded(displayedData)
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.isLoadingMore = false
                    
                    if isFirstPage {
                        self.state = .error(error)
                    } else {
                    }
                }
            }
        }
    }
    
    func exchange(at index: Int) -> Exchange? {
        guard index >= 0 && index < exchanges.count else { return nil }
        return exchanges[index]
    }
    
    func formattedVolume(for exchange: Exchange) -> String {
        guard let volume = exchange.spotVolumeUsd else { return "N/A" }
        return formatCurrency(volume)
    }
    
    func formattedDate(for exchange: Exchange) -> String {
        guard let dateString = exchange.dateL else { return "N/A" }
        return formatDate(dateString)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        
        if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.2fK", value / 1_000)
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale(identifier: "pt_BR")
        
        return outputFormatter.string(from: date)
    }
}
