//
//  MockCoinMarketCapService.swift
//  CoinMarketAppTests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import Foundation

class MockCoinMarketCapService: CoinMarketCapService {
    
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
}

extension MockCoinMarketCapService {
    
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
