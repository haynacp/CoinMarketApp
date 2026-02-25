//
//  TestConfiguration.swift
//  CoinMarketAppTests
//
//  Created by Hayna Cardoso on 25/02/26.
//

import Foundation

enum TestConfiguration {
    
    static let defaultAsyncTimeout: UInt64 = 200_000_000
    
    static let longAsyncTimeout: UInt64 = 1_000_000_000
    
    static let uiTestTimeout: TimeInterval = 10.0
    
    static let longUITestTimeout: TimeInterval = 15.0
 
    static let paginationTestExchangeCount = 50
    
    static let pageSize = 20
    
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    static var isRunningUITests: Bool {
        return ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
    
    static func shortDelay() async throws {
        try await Task.sleep(nanoseconds: defaultAsyncTimeout)
    }
    
    static func longDelay() async throws {
        try await Task.sleep(nanoseconds: longAsyncTimeout)
    }
}

extension CoinMarketCapService {
    
    static var testInstance: CoinMarketCapService {
        if TestConfiguration.isRunningTests {
            return MockCoinMarketCapService()
        }
        return .shared
    }
}

enum TestDataBuilder {
    
    static func createExchange(
        id: Int = 270,
        name: String = "Test Exchange",
        volume: Double = 1_000_000_000
    ) -> Exchange {
        return MockCoinMarketCapService.createMockExchange(
            id: id,
            name: name,
            volume: volume
        )
    }
    
    static func createExchanges(count: Int) -> [Exchange] {
        return (1...count).map { index in
            createExchange(
                id: index,
                name: "Exchange \(index)",
                volume: Double(index) * 1_000_000_000
            )
        }
    }
    
    static func createCurrency(
        id: Int = 1,
        symbol: String = "BTC",
        price: Double = 50_000
    ) -> Currency {
        return MockCoinMarketCapService.createMockCurrency(
            id: id,
            symbol: symbol,
            name: symbol,
            price: price
        )
    }
    
    static func createCurrencies(count: Int) -> [Currency] {
        return (1...count).map { index in
            createCurrency(
                id: index,
                symbol: "COIN\(index)",
                price: Double(index) * 100
            )
        }
    }
    
    static func createMarket(
        id: String = "1",
        pair: String = "BTC/USDT",
        volume: Double = 1_000_000
    ) -> Market {
        return MockCoinMarketCapService.createMockMarket(
            id: id,
            pair: pair,
            volume: volume
        )
    }
    
    static func createMarkets(count: Int) -> [Market] {
        return (1...count).map { index in
            createMarket(
                id: "\(index)",
                pair: "COIN\(index)/USDT",
                volume: Double(index) * 10_000
            )
        }
    }
}

enum TestAssertions {
    
    static func isValidURL(_ string: String) -> Bool {
        return URL(string: string) != nil
    }
    
    static func isValidCurrencyFormat(_ string: String) -> Bool {
        return string.contains("$") && !string.isEmpty
    }
    
    static func isValidPercentageFormat(_ string: String) -> Bool {
        return string.contains("%") && !string.isEmpty
    }
    
    static func isValidDateFormat(_ string: String) -> Bool {
        let yearPattern = "\\d{4}"
        return string.range(of: yearPattern, options: .regularExpression) != nil
    }
}

class PerformanceTestHelper {
    
    static func measure(_ operation: () async throws -> Void) async rethrows -> TimeInterval {
        let start = Date()
        try await operation()
        return Date().timeIntervalSince(start)
    }
    
    static func assertPerformance(
        expectedMaxDuration: TimeInterval,
        operation: () async throws -> Void
    ) async throws -> Bool {
        let duration = try await measure(operation)
        return duration <= expectedMaxDuration
    }
}

class MockDelegate<T> {
    var callCount = 0
    var lastValue: T?
    var values: [T] = []
    
    func record(_ value: T) {
        callCount += 1
        lastValue = value
        values.append(value)
    }
    
    func reset() {
        callCount = 0
        lastValue = nil
        values = []
    }
}
