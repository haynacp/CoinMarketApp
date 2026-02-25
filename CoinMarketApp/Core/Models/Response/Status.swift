//
//  Status.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

struct Status: Codable {
    let timestamp: String?
    let errorCode: Int?
    let errorMessage: String?
    let elapsed: Int?
    let creditCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
    }
}
