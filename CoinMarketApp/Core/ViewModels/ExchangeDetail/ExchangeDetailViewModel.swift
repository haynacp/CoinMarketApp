//
//  ExchangeDetailViewModel.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import Foundation

protocol ExchangeDetailViewModelDelegate: AnyObject {
    func didUpdateExchangeDetails()
    func didUpdateMarkets()
    func didFailWithError(_ error: Error)
}

class ExchangeDetailViewModel {
    
    weak var delegate: ExchangeDetailViewModelDelegate?
    
    private let service: CoinMarketCapService
    private(set) var exchange: Exchange
    private(set) var markets: [Market] = []
    private(set) var currencies: [Currency] = []
    private(set) var isLoadingDetails = false
    private(set) var isLoadingMarkets = false
    
    var numberOfCurrencies: Int {
        return currencies.count
    }
    
    init(exchange: Exchange, service: CoinMarketCapService = .shared) {
        self.exchange = exchange
        self.service = service
    }
    
    func fetchExchangeDetails() {
        guard !isLoadingDetails else { return }
        
        isLoadingDetails = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let exchangeInfo = try await self.service.fetchExchangeInfo(id: self.exchange.id)
                
                await MainActor.run {
                    self.exchange = exchangeInfo
                    
                    if let fiats = exchangeInfo.fiats {
                        self.currencies = fiats
                    } else {
                    }
                    
                    self.isLoadingDetails = false
                    self.delegate?.didUpdateExchangeDetails()
                }
                
            } catch {
                await MainActor.run {
                    self.isLoadingDetails = false
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func fetchCurrencies() {
        guard !isLoadingMarkets else { return }
        
        isLoadingMarkets = true
       
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let currencies = try await self.service.fetchExchangeAssets(id: self.exchange.id)
                
                await MainActor.run {
                    self.currencies = currencies
                    
                    self.isLoadingMarkets = false
                    self.delegate?.didUpdateMarkets()
                }
                
            } catch {
                await MainActor.run {
                    self.isLoadingMarkets = false
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func fetchMarkets() {
        guard !isLoadingMarkets else { return }
        
        isLoadingMarkets = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let markets = try await self.service.fetchExchangeMarketPairs(id: self.exchange.id, limit: 50)
                
                await MainActor.run {
                    self.markets = markets
                    
                    self.extractCurrenciesFromMarkets()
                    
                    self.isLoadingMarkets = false
                    self.delegate?.didUpdateMarkets()
                }
                
            } catch {
                await MainActor.run {
                    self.isLoadingMarkets = false
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func currency(at index: Int) -> Currency? {
        guard index >= 0 && index < currencies.count else { return nil }
        return currencies[index]
    }
    
    func formattedWebsite() -> String {
        guard let urls = exchange.urls,
              let websites = urls.website,
              let firstWebsite = websites.first else {
            return "N/A"
        }
        return firstWebsite
    }
    
    func formattedMakerFee() -> String {
        guard let fee = exchange.makerFee else { return "N/A" }
        return String(format: "%.2f%%", fee)
    }
    
    func formattedTakerFee() -> String {
        guard let fee = exchange.takerFee else { return "N/A" }
        return String(format: "%.2f%%", fee)
    }
    
    func formattedDate() -> String {
        guard let dateString = exchange.dateL else { return "N/A" }
        return formatDate(dateString)
    }
    
    func formattedPrice(for currency: Currency) -> String {
        guard let price = currency.priceUsd else { return "N/A" }
        return String(format: "$%.4f", price)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale(identifier: "pt_BR")
        
        return outputFormatter.string(from: date)
    }
    
    private func extractCurrenciesFromMarkets() {
        var uniqueCurrencies: [String: Currency] = [:]
        
        for market in markets {
            if let marketPair = market.marketPair {
                let components = marketPair.components(separatedBy: "/")
                
                for (index, symbol) in components.enumerated() {
                    let cleanSymbol = symbol.trimmingCharacters(in: .whitespaces)
                    
                    if uniqueCurrencies[cleanSymbol] == nil {
                        let currency = Currency(
                            id: uniqueCurrencies.count + 1,
                            name: cleanSymbol,
                            symbol: cleanSymbol,
                            slug: cleanSymbol.lowercased(),
                            priceUsd: index == 1 ? market.priceUsd : nil
                        )
                        uniqueCurrencies[cleanSymbol] = currency
                    }
                }
            }
        }
        
        let marketCurrencies = Array(uniqueCurrencies.values)
        
        for currency in marketCurrencies {
            if !currencies.contains(where: { $0.symbol == currency.symbol }) {
                currencies.append(currency)
            }
        }
    }
}
