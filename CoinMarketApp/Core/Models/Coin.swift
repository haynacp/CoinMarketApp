//
//  CoinModel.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import Foundation

struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChangePercentage24h: Double?
    let marketCap: Double?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCap = "market_cap"
    }
}

extension Coin {
    static let mockData = [
        Coin(
            id: "bitcoin",
            symbol: "BTC",
            name: "Bitcoin",
            currentPrice: 52000.00,
            priceChangePercentage24h: 2.5,
            marketCap: 1000000000000,
            image: nil
        ),
        Coin(
            id: "ethereum",
            symbol: "ETH",
            name: "Ethereum",
            currentPrice: 3200.00,
            priceChangePercentage24h: -1.2,
            marketCap: 380000000000,
            image: nil
        ),
        Coin(
            id: "cardano",
            symbol: "ADA",
            name: "Cardano",
            currentPrice: 0.52,
            priceChangePercentage24h: 3.8,
            marketCap: 18000000000,
            image: nil
        )
    ]
}
