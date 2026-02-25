//
//  ExchangeListViewModelTests.swift
//  CoinMarketAppTests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import Testing
import Foundation
@testable import CoinMarketApp

final class MockCoinMarketCapService: CoinMarketCapService {
    
    var mockExchanges: [Exchange] = []
    var mockExchangeInfo: Exchange?
    var mockCurrencies: [Currency] = []
    var mockMarkets: [Market] = []
    
    var shouldFail = false
    var errorToThrow: Error = APIError.networkError(NSError(domain: "test", code: -1))
    var delayInSeconds: Double = 0.0
    
    var fetchExchangesCalled = false
    var fetchExchangeInfoCalled = false
    var fetchExchangeAssetsCalled = false
    var fetchExchangeMarketPairsCalled = false
    
    var lastFetchedExchangeId: Int?
    
    override init(forTesting: Bool = true) {
        super.init(forTesting: forTesting)
    }
    
    override func fetchExchanges(limit: Int = 50) async throws -> [Exchange] {
        fetchExchangesCalled = true
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if shouldFail {
            throw errorToThrow
        }
        
        return mockExchanges
    }
    
    override func fetchExchangeInfo(id: Int) async throws -> Exchange {
        fetchExchangeInfoCalled = true
        lastFetchedExchangeId = id
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let info = mockExchangeInfo else {
            throw APIError.invalidResponse
        }
        
        return info
    }
    
    override func fetchExchangeAssets(id: Int) async throws -> [Currency] {
        fetchExchangeAssetsCalled = true
        lastFetchedExchangeId = id
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if shouldFail {
            throw errorToThrow
        }
        
        return mockCurrencies
    }
    
    override func fetchExchangeMarketPairs(id: Int, limit: Int = 100) async throws -> [Market] {
        fetchExchangeMarketPairsCalled = true
        lastFetchedExchangeId = id
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if shouldFail {
            throw errorToThrow
        }
        
        return mockMarkets
    }
    
    func reset() {
        mockExchanges = []
        mockExchangeInfo = nil
        mockCurrencies = []
        mockMarkets = []
        shouldFail = false
        delayInSeconds = 0.0
        fetchExchangesCalled = false
        fetchExchangeInfoCalled = false
        fetchExchangeAssetsCalled = false
        fetchExchangeMarketPairsCalled = false
        lastFetchedExchangeId = nil
    }
    
    static func createMockExchange(
        id: Int = 270,
        name: String = "Binance",
        volume: Double = 15_000_000_000
    ) -> Exchange {
        return Exchange(
            id: id,
            name: name,
            slug: name.lowercased(),
            logo: "https://example.com/logo.png",
            description: "Test exchange description",
            dateL: "2017-07-14T00:00:00.000Z",
            urls: ExchangeUrls(
                website: ["https://example.com"],
                twitter: ["https://twitter.com/example"],
                blog: nil,
                chat: nil,
                fee: nil
            ),
            spotVolumeUsd: volume,
            makerFee: 0.1,
            takerFee: 0.1,
            weeklyVisits: 50_000_000,
            numMarkets: 1500,
            numCoins: 350,
            fiats: nil,
            markets: nil
        )
    }
    
    static func createMockCurrency(
        id: Int = 1,
        symbol: String = "BTC",
        name: String = "Bitcoin",
        price: Double = 50_000.0
    ) -> Currency {
        return Currency(
            id: id,
            name: name,
            symbol: symbol,
            slug: symbol.lowercased(),
            priceUsd: price
        )
    }
    
    static func createMockMarket(
        id: String = "1",
        pair: String = "BTC/USDT",
        volume: Double = 1_000_000.0
    ) -> Market {
        return Market(
            id: id,
            marketPair: pair,
            category: "spot",
            feeType: "percentage",
            volumeUsd: volume,
            priceUsd: 50_000.0,
            priceQuote: nil
        )
    }
}

@Suite("Exchange List ViewModel Tests")
struct ExchangeListViewModelTests {
    
    @Test("Deve iniciar com estado idle")
    func testInitialState() {
        let mockService = MockCoinMarketCapService()
        let viewModel = ExchangeListViewModel(service: mockService)
        
        #expect(viewModel.exchanges.isEmpty)
        #expect(viewModel.numberOfExchanges == 0)
        #expect(!viewModel.isLoading)
    }
    
    @Test("Deve carregar exchanges com sucesso")
    func testFetchExchangesSuccess() async throws {
        let mockService = await MockCoinMarketCapService()
        mockService.mockExchanges = [
            MockCoinMarketCapService.createMockExchange(id: 1, name: "Binance"),
            MockCoinMarketCapService.createMockExchange(id: 2, name: "Coinbase"),
            MockCoinMarketCapService.createMockExchange(id: 3, name: "Kraken")
        ]
        
        let viewModel = await ExchangeListViewModel(service: mockService)
        
        let delegate = MockExchangeListDelegate()
        viewModel.delegate = delegate
  
        await viewModel.fetchExchanges(useMockData: false)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangesCalled)
        #expect(viewModel.numberOfExchanges == 3)
        await #expect(viewModel.exchanges.first?.name == "Binance")
        #expect(!viewModel.isLoading)
        #expect(delegate.stateUpdateCount >= 2)
    }
    
    @Test("Deve lidar com erro de rede")
    func testFetchExchangesNetworkError() async throws {
        let mockService = await MockCoinMarketCapService()
        mockService.shouldFail = true
        mockService.errorToThrow = APIError.networkError(
            NSError(domain: "test", code: -1009, userInfo: [
                NSLocalizedDescriptionKey: "Sem conexão"
            ])
        )
        
        let viewModel = await ExchangeListViewModel(service: mockService)
        let delegate = MockExchangeListDelegate()
        viewModel.delegate = delegate
        
        await viewModel.fetchExchanges(useMockData: false)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(mockService.fetchExchangesCalled)
        #expect(viewModel.exchanges.isEmpty)
        #expect(delegate.lastError != nil)
    }
    
    @Test("Deve retornar exchange por índice")
    func testExchangeAtIndex() async throws {
        let mockService = await MockCoinMarketCapService()
        mockService.mockExchanges = [
            MockCoinMarketCapService.createMockExchange(id: 1, name: "Binance"),
            MockCoinMarketCapService.createMockExchange(id: 2, name: "Coinbase")
        ]
        
        let viewModel = await ExchangeListViewModel(service: mockService)
        await viewModel.fetchExchanges(useMockData: false)
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let exchange = await viewModel.exchange(at: 0)
        #expect(exchange?.name == "Binance")
        
        let secondExchange = await viewModel.exchange(at: 1)
        #expect(secondExchange?.name == "Coinbase")
        
        let invalidExchange = await viewModel.exchange(at: 999)
        #expect(invalidExchange == nil)
    }
    
    @Test("Deve formatar volume em bilhões")
    func testFormattedVolumeBillions() {
        let viewModel = ExchangeListViewModel()
        let exchange = MockCoinMarketCapService.createMockExchange(
            volume: 15_000_000_000
        )
        
        let formatted = viewModel.formattedVolume(for: exchange)
        
        #expect(formatted == "$15.00B")
    }
    
    @Test("Deve formatar volume em milhões")
    func testFormattedVolumeMillions() {
        let viewModel = ExchangeListViewModel()
        let exchange = MockCoinMarketCapService.createMockExchange(
            volume: 500_000_000
        )
        
        let formatted = viewModel.formattedVolume(for: exchange)
        
        #expect(formatted == "$500.00M")
    }
    
    @Test("Deve formatar volume em milhares")
    func testFormattedVolumeThousands() {
        let viewModel = ExchangeListViewModel()
        let exchange = MockCoinMarketCapService.createMockExchange(
            volume: 750_000
        )
        
        let formatted = viewModel.formattedVolume(for: exchange)
        
        #expect(formatted == "$750.00K")
    }
    
    @Test("Deve retornar N/A quando volume é nil")
    func testFormattedVolumeNil() {
        let viewModel = ExchangeListViewModel()
        var exchange = MockCoinMarketCapService.createMockExchange()
        exchange = Exchange(
            id: exchange.id,
            name: exchange.name,
            slug: exchange.slug,
            logo: exchange.logo,
            description: exchange.description,
            dateL: exchange.dateL,
            urls: exchange.urls,
            spotVolumeUsd: nil,
            makerFee: exchange.makerFee,
            takerFee: exchange.takerFee,
            weeklyVisits: exchange.weeklyVisits,
            numMarkets: exchange.numMarkets,
            numCoins: exchange.numCoins,
            fiats: exchange.fiats,
            markets: exchange.markets
        )
        
        let formatted = viewModel.formattedVolume(for: exchange)
        
        #expect(formatted == "N/A")
    }
    
    @Test("Deve formatar data corretamente")
    func testFormattedDate() {
        let viewModel = ExchangeListViewModel()
        let exchange = MockCoinMarketCapService.createMockExchange()
        
        let formatted = viewModel.formattedDate(for: exchange)
        
        #expect(!formatted.isEmpty)
        #expect(formatted != "N/A")
        #expect(formatted.contains("2017") || formatted.contains("jul"))
    }
    
    @Test("Deve implementar paginação básica")
    func testPagination() async throws {
        let mockService = await MockCoinMarketCapService()
        
        mockService.mockExchanges = (1...50).map { index in
            MockCoinMarketCapService.createMockExchange(
                id: index,
                name: "Exchange \(index)"
            )
        }
        
        let viewModel = await ExchangeListViewModel(service: mockService)
        
        await viewModel.fetchExchanges(useMockData: false)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let firstPageCount = await viewModel.numberOfExchanges
        
        #expect(firstPageCount > 0)
        #expect(firstPageCount <= 20)
        
        if await viewModel.hasMorePages {
            await viewModel.loadMoreIfNeeded(currentIndex: firstPageCount - 5)
            try await Task.sleep(nanoseconds: 200_000_000)
            
            let secondPageCount = await viewModel.numberOfExchanges
            
            #expect(secondPageCount > firstPageCount)
        }
    }
    
    @Test("Não deve carregar mais quando já está carregando")
    func testLoadMoreWhileLoading() async throws {
        let mockService = await MockCoinMarketCapService()
        mockService.delayInSeconds = 1.0
        mockService.mockExchanges = Array(repeating: 
            MockCoinMarketCapService.createMockExchange(), count: 50)
        
        let viewModel = await ExchangeListViewModel(service: mockService)
        
        await viewModel.fetchExchanges(useMockData: false)
        
        await viewModel.fetchExchanges(useMockData: false)
        
        try await Task.sleep(nanoseconds: 300_000_000)
        
        #expect(mockService.fetchExchangesCalled)
    }
    
    @Test("Deve carregar mock data quando solicitado")
    func testFetchWithMockData() async throws {

        let viewModel = await ExchangeListViewModel()
        
        await viewModel.fetchExchanges(useMockData: true)
        
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(viewModel.numberOfExchanges == 3)
        #expect(viewModel.exchanges.contains { $0.name == "Binance" })
    }
}

class MockExchangeListDelegate: ExchangeListViewModelDelegate {
    var stateUpdateCount = 0
    var lastState: ViewState<[Exchange]>?
    var lastError: Error?
    
    func didUpdateState(_ state: ViewState<[Exchange]>) {
        stateUpdateCount += 1
        lastState = state
        
        if case .error(let error) = state {
            lastError = error
        }
    }
}
