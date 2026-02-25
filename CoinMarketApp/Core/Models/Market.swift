//
//  Market.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

struct Market: Codable, Identifiable {
    let id: String
    let marketPair: String?
    let category: String?
    let feeType: String?
    let volumeUsd: Double?
    let priceUsd: Double?
    let priceQuote: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "market_id"
        case marketPair = "market_pair"
        case category
        case feeType = "fee_type"
        case volumeUsd = "volume_usd"
        case priceUsd = "price_usd"
        case priceQuote = "price_quote"
    }
}
