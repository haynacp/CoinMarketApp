//
//  CoinMarketCapServiceTests.swift
//  CoinMarketAppTests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import Foundation

@Suite("CoinMarketCap Service Tests")
struct CoinMarketCapServiceTests {
    
    @Test("Exchange deve decodificar corretamente")
    func testExchangeDecoding() throws {
        let json = """
        {
            "id": 270,
            "name": "Binance",
            "slug": "binance",
            "logo": "https://example.com/logo.png",
            "description": "Test description",
            "date_launched": "2017-07-14T00:00:00.000Z",
            "spot_volume_usd": 15000000000.50,
            "maker_fee": 0.1,
            "taker_fee": 0.1,
            "weekly_visits": 50000000,
            "num_markets": 1500,
            "num_coins": 350,
            "urls": {
                "website": ["https://binance.com"],
                "twitter": ["https://twitter.com/binance"]
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let exchange = try decoder.decode(Exchange.self, from: json)
        
        #expect(exchange.id == 270)
        #expect(exchange.name == "Binance")
        #expect(exchange.slug == "binance")
        #expect(exchange.spotVolumeUsd == 15000000000.50)
        #expect(exchange.makerFee == 0.1)
        #expect(exchange.urls?.website?.first == "https://binance.com")
    }
    
    @Test("Currency deve decodificar corretamente")
    func testCurrencyDecoding() throws {

        let json = """
        {
            "id": 1,
            "name": "Bitcoin",
            "symbol": "BTC",
            "slug": "bitcoin",
            "price_usd": 50000.0
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let currency = try decoder.decode(Currency.self, from: json)
        
        #expect(currency.id == 1)
        #expect(currency.name == "Bitcoin")
        #expect(currency.symbol == "BTC")
        #expect(currency.priceUsd == 50000.0)
    }
    
    @Test("Market deve decodificar corretamente")
    func testMarketDecoding() throws {
        let json = """
        {
            "market_id": "btc_usdt",
            "market_pair": "BTC/USDT",
            "category": "spot",
            "fee_type": "percentage",
            "volume_usd": 1000000.0,
            "price_usd": 50000.0
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let market = try decoder.decode(Market.self, from: json)
        
        #expect(market.id == "btc_usdt")
        #expect(market.marketPair == "BTC/USDT")
        #expect(market.category == "spot")
        #expect(market.volumeUsd == 1000000.0)
    }
    
    @Test("APIError deve ter descrições corretas")
    func testAPIErrorDescriptions() {
        let invalidURL = APIError.invalidURL
        #expect(invalidURL.errorDescription == "URL inválida")
        
        let invalidResponse = APIError.invalidResponse
        #expect(invalidResponse.errorDescription == "Resposta inválida do servidor")
        
        let noConnection = APIError.noConnection
        #expect(noConnection.errorDescription?.contains("conexão") == true)
        
        let apiError = APIError.apiError("Teste de erro")
        #expect(apiError.errorDescription?.contains("Teste de erro") == true)
    }
    
    @Test("ViewState deve gerenciar estados corretamente")
    func testViewStateIdle() {
        let state: ViewState<[Exchange]> = .idle
        
        #expect(state.data == nil)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }
    
    @Test("ViewState loading deve retornar isLoading true")
    func testViewStateLoading() {
        let state: ViewState<[Exchange]> = .loading
        
        #expect(state.isLoading)
        #expect(state.data == nil)
    }
    
    @Test("ViewState loaded deve conter dados")
    func testViewStateLoaded() {
        let exchanges = [
            MockCoinMarketCapService.createMockExchange()
        ]
        let state: ViewState<[Exchange]> = .loaded(exchanges)
        
        #expect(state.data?.count == 1)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }
    
    @Test("ViewState empty deve estar vazio")
    func testViewStateEmpty() {
        let state: ViewState<[Exchange]> = .empty
        
        #expect(state.data == nil)
        #expect(!state.isLoading)
    }
    
    @Test("ViewState error deve conter erro")
    func testViewStateError() {
        let testError = APIError.networkError(NSError(domain: "test", code: -1))
        let state: ViewState<[Exchange]> = .error(testError)
        
        #expect(state.error != nil)
        #expect(state.data == nil)
        #expect(!state.isLoading)
    }
    
    
    @Test("Exchange.mockData deve conter dados válidos")
    func testExchangeMockData() {
        let mockData = Exchange.mockData
        
        #expect(mockData.count == 3)
        #expect(mockData.contains { $0.name == "Binance" })
        #expect(mockData.contains { $0.name == "Coinbase Exchange" })
        #expect(mockData.contains { $0.name == "Kraken" })
        
        let binance = mockData.first { $0.name == "Binance" }
        #expect(binance?.id == 270)
        #expect(binance?.spotVolumeUsd != nil)
        #expect(binance?.logo != nil)
    }
    
    @Test("Deve formatar volumes de mock data corretamente")
    func testMockDataVolumeFormatting() {
        let viewModel = ExchangeListViewModel()
        let mockExchanges = Exchange.mockData
        
        for exchange in mockExchanges {
            let formatted = viewModel.formattedVolume(for: exchange)
            #expect(!formatted.isEmpty)
            #expect(formatted != "N/A")
            #expect(formatted.contains("$"))
        }
    }
    
    @Test("Deve formatar datas de mock data corretamente")
    func testMockDataDateFormatting() {
        let viewModel = ExchangeListViewModel()
        let mockExchanges = Exchange.mockData
        
        for exchange in mockExchanges {
            let formatted = viewModel.formattedDate(for: exchange)
            #expect(!formatted.isEmpty)
            #expect(formatted != "N/A")
        }
    }
}

@Suite("Model Validation Tests")
struct ModelValidationTests {
    
    @Test("Exchange deve ser Identifiable")
    func testExchangeIdentifiable() {
        let exchange1 = MockCoinMarketCapService.createMockExchange(id: 1)
        let exchange2 = MockCoinMarketCapService.createMockExchange(id: 2)
        
        #expect(exchange1.id != exchange2.id)
    }
    
    @Test("Currency deve ser Identifiable")
    func testCurrencyIdentifiable() {
        let btc = MockCoinMarketCapService.createMockCurrency(id: 1, symbol: "BTC")
        let eth = MockCoinMarketCapService.createMockCurrency(id: 2, symbol: "ETH")
        
        #expect(btc.id != eth.id)
    }
    
    @Test("Market deve ser Identifiable")
    func testMarketIdentifiable() {
        let market1 = MockCoinMarketCapService.createMockMarket(id: "1")
        let market2 = MockCoinMarketCapService.createMockMarket(id: "2")
        
        #expect(market1.id != market2.id)
    }
    
    @Test("Exchange deve permitir valores opcionais")
    func testExchangeOptionalFields() {
        let exchange = Exchange(
            id: 1,
            name: "Test",
            slug: nil,
            logo: nil,
            description: nil,
            dateL: nil,
            urls: nil,
            spotVolumeUsd: nil,
            makerFee: nil,
            takerFee: nil,
            weeklyVisits: nil,
            numMarkets: nil,
            numCoins: nil,
            fiats: nil,
            markets: nil
        )
        
        #expect(exchange.id == 1)
        #expect(exchange.name == "Test")
        #expect(exchange.slug == nil)
        #expect(exchange.spotVolumeUsd == nil)
    }
}
