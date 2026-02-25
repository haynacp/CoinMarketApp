//
//  Currency.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

struct Currency: Codable, Identifiable {
    let id: Int?
    let name: String?
    let symbol: String?
    let slug: String?
    let priceUsd: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug
        case priceUsd = "price_usd"
    }
}
