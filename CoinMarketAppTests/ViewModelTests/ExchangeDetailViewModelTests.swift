//
//  ExchangeDetailViewModelTests.swift
//  CoinMarketAppTests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import Foundation

@Suite("Exchange Detail ViewModel Tests")
struct ExchangeDetailViewModelTests {
    
    @Test("Deve inicializar com exchange fornecida")
    func testInitialization() {
        let exchange = MockCoinMarketCapService.createMockExchange(
            id: 270,
            name: "Binance"
        )
        
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        #expect(viewModel.exchange.id == 270)
        #expect(viewModel.exchange.name == "Binance")
        #expect(viewModel.numberOfCurrencies == 0)
        #expect(!viewModel.isLoadingDetails)
        #expect(!viewModel.isLoadingMarkets)
    }
    
    @Test("Deve buscar detalhes da exchange com sucesso")
    func testFetchExchangeDetailsSuccess() async throws {
        let initialExchange = MockCoinMarketCapService.createMockExchange(
            id: 270,
            name: "Binance"
        )
        
        let mockService = MockCoinMarketCapService()
        mockService.mockExchangeInfo = MockCoinMarketCapService.createMockExchange(
            id: 270,
            name: "Binance",
            volume: 20_000_000_000
        )
        
        let viewModel = ExchangeDetailViewModel(
            exchange: initialExchange,
            service: mockService
        )
        
        let delegate = MockExchangeDetailDelegate()
        viewModel.delegate = delegate
        
        viewModel.fetchExchangeDetails()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangeInfoCalled)
        #expect(mockService.lastFetchedExchangeId == 270)
        #expect(viewModel.exchange.spotVolumeUsd == 20_000_000_000)
        #expect(delegate.detailsUpdated)
        #expect(!viewModel.isLoadingDetails)
    }
    
    @Test("Deve lidar com erro ao buscar detalhes")
    func testFetchExchangeDetailsError() async throws {
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let mockService = MockCoinMarketCapService()
        mockService.shouldFail = true
        mockService.errorToThrow = APIError.networkError(
            NSError(domain: "test", code: -1)
        )
        
        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            service: mockService
        )
        
        let delegate = MockExchangeDetailDelegate()
        viewModel.delegate = delegate
        
        viewModel.fetchExchangeDetails()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangeInfoCalled)
        #expect(delegate.errorReceived != nil)
        #expect(!viewModel.isLoadingDetails)
    }
    
    @Test("Deve buscar currencies com sucesso")
    func testFetchCurrenciesSuccess() async throws {
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let mockService = MockCoinMarketCapService()
        mockService.mockCurrencies = [
            MockCoinMarketCapService.createMockCurrency(id: 1, symbol: "BTC"),
            MockCoinMarketCapService.createMockCurrency(id: 2, symbol: "ETH"),
            MockCoinMarketCapService.createMockCurrency(id: 3, symbol: "USDT")
        ]
        
        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            service: mockService
        )
        
        let delegate = MockExchangeDetailDelegate()
        viewModel.delegate = delegate
        
        viewModel.fetchCurrencies()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangeAssetsCalled)
        #expect(viewModel.numberOfCurrencies == 3)
        #expect(viewModel.currencies.contains { $0.symbol == "BTC" })
        #expect(delegate.marketsUpdated)
    }
    
    @Test("Deve retornar currency por índice")
    func testCurrencyAtIndex() async throws {
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let mockService = MockCoinMarketCapService()
        mockService.mockCurrencies = [
            MockCoinMarketCapService.createMockCurrency(id: 1, symbol: "BTC"),
            MockCoinMarketCapService.createMockCurrency(id: 2, symbol: "ETH")
        ]
        
        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            service: mockService
        )
        
        viewModel.fetchCurrencies()
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let btc = viewModel.currency(at: 0)
        #expect(btc?.symbol == "BTC")
        
        let eth = viewModel.currency(at: 1)
        #expect(eth?.symbol == "ETH")
        
        let invalid = viewModel.currency(at: 999)
        #expect(invalid == nil)
    }
    
    @Test("Deve buscar markets com sucesso")
    func testFetchMarketsSuccess() async throws {
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let mockService = MockCoinMarketCapService()
        mockService.mockMarkets = [
            MockCoinMarketCapService.createMockMarket(id: "1", pair: "BTC/USDT"),
            MockCoinMarketCapService.createMockMarket(id: "2", pair: "ETH/USDT"),
            MockCoinMarketCapService.createMockMarket(id: "3", pair: "BNB/USDT")
        ]
        
        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            service: mockService
        )
        
        let delegate = MockExchangeDetailDelegate()
        viewModel.delegate = delegate
        
        viewModel.fetchMarkets()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangeMarketPairsCalled)
        #expect(viewModel.markets.count == 3)
        #expect(delegate.marketsUpdated)
    }
    
    @Test("Deve formatar website corretamente")
    func testFormattedWebsite() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let website = viewModel.formattedWebsite()
        
        #expect(website == "https://example.com")
    }
    
    @Test("Deve retornar N/A quando website não existe")
    func testFormattedWebsiteNil() {
        var exchange = MockCoinMarketCapService.createMockExchange()
        exchange = Exchange(
            id: exchange.id,
            name: exchange.name,
            slug: exchange.slug,
            logo: exchange.logo,
            description: exchange.description,
            dateL: exchange.dateL,
            urls: nil,
            spotVolumeUsd: exchange.spotVolumeUsd,
            makerFee: exchange.makerFee,
            takerFee: exchange.takerFee,
            weeklyVisits: exchange.weeklyVisits,
            numMarkets: exchange.numMarkets,
            numCoins: exchange.numCoins,
            fiats: exchange.fiats,
            markets: exchange.markets
        )
        
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let website = viewModel.formattedWebsite()
        
        #expect(website == "N/A")
    }
    
    @Test("Deve formatar maker fee")
    func testFormattedMakerFee() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let fee = viewModel.formattedMakerFee()
        
        #expect(fee == "0.10%")
    }
    
    @Test("Deve formatar taker fee")
    func testFormattedTakerFee() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let fee = viewModel.formattedTakerFee()
        
        #expect(fee == "0.10%")
    }
    
    @Test("Deve formatar preço da currency")
    func testFormattedPrice() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let currency = MockCoinMarketCapService.createMockCurrency(
            symbol: "BTC",
            price: 50_000.123456
        )
        
        let price = viewModel.formattedPrice(for: currency)
        
        #expect(price == "$50000.1235")
    }
    
    @Test("Deve retornar N/A quando preço é nil")
    func testFormattedPriceNil() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let currency = Currency(
            id: 1,
            name: "Bitcoin",
            symbol: "BTC",
            slug: "btc",
            priceUsd: nil
        )
        
        let price = viewModel.formattedPrice(for: currency)
        
        #expect(price == "N/A")
    }
    
    @Test("Deve formatar data de lançamento")
    func testFormattedDate() {
        let exchange = MockCoinMarketCapService.createMockExchange()
        let viewModel = ExchangeDetailViewModel(exchange: exchange)
        
        let date = viewModel.formattedDate()
        
        #expect(!date.isEmpty)
        #expect(date != "N/A")
        #expect(date.contains("2017") || date.contains("jul") || date.contains("julho"))
    }
    
    @Test("Não deve carregar detalhes se já estiver carregando")
    func testFetchDetailsWhileLoading() async throws {
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let mockService = MockCoinMarketCapService()
        mockService.delayInSeconds = 1.0
        mockService.mockExchangeInfo = exchange
        
        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            service: mockService
        )
        
        viewModel.fetchExchangeDetails()
        viewModel.fetchExchangeDetails()
        
        try await Task.sleep(nanoseconds: 300_000_000)
        
        #expect(mockService.fetchExchangeInfoCalled)
    }
}

class MockExchangeDetailDelegate: ExchangeDetailViewModelDelegate {
    var detailsUpdated = false
    var marketsUpdated = false
    var errorReceived: Error?
    
    func didUpdateExchangeDetails() {
        detailsUpdated = true
    }
    
    func didUpdateMarkets() {
        marketsUpdated = true
    }
    
    func didFailWithError(_ error: Error) {
        errorReceived = error
    }
}
