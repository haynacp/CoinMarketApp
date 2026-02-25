//
//  ExchangeResponse.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

struct ExchangeResponse: Codable {
    let status: Status?
    let data: [Exchange]?
}
