//
//  Exchange.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

struct Exchange: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String?
    let logo: String?
    let description: String?
    let dateL: String?
    let urls: ExchangeUrls?
    let spotVolumeUsd: Double?
    let makerFee: Double?
    let takerFee: Double?
    let weeklyVisits: Int?
    let numMarkets: Int?
    let numCoins: Int?
    let fiats: [Currency]?
    let markets: [Market]?
    
    private let fiatsRaw: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, logo, description, urls, markets
        case dateL = "date_launched"
        case spotVolumeUsd = "spot_volume_usd"
        case makerFee = "maker_fee"
        case takerFee = "taker_fee"
        case weeklyVisits = "weekly_visits"
        case numMarkets = "num_markets"
        case numCoins = "num_coins"
        case fiatsRaw = "fiats"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        dateL = try container.decodeIfPresent(String.self, forKey: .dateL)
        urls = try container.decodeIfPresent(ExchangeUrls.self, forKey: .urls)
        spotVolumeUsd = try container.decodeIfPresent(Double.self, forKey: .spotVolumeUsd)
        makerFee = try container.decodeIfPresent(Double.self, forKey: .makerFee)
        takerFee = try container.decodeIfPresent(Double.self, forKey: .takerFee)
        weeklyVisits = try container.decodeIfPresent(Int.self, forKey: .weeklyVisits)
        numMarkets = try container.decodeIfPresent(Int.self, forKey: .numMarkets)
        numCoins = try container.decodeIfPresent(Int.self, forKey: .numCoins)
        markets = try container.decodeIfPresent([Market].self, forKey: .markets)
        
        fiatsRaw = try container.decodeIfPresent([String].self, forKey: .fiatsRaw)
        
        if let fiatStrings = fiatsRaw {
            fiats = fiatStrings.enumerated().map { (index, fiatSymbol) in
                Currency(
                    id: index + 1,
                    name: fiatSymbol,
                    symbol: fiatSymbol,
                    slug: fiatSymbol.lowercased(),
                    priceUsd: nil
                )
            }
        } else {
            fiats = nil
        }
    }
    
    init(
        id: Int,
        name: String,
        slug: String?,
        logo: String?,
        description: String?,
        dateL: String?,
        urls: ExchangeUrls?,
        spotVolumeUsd: Double?,
        makerFee: Double?,
        takerFee: Double?,
        weeklyVisits: Int?,
        numMarkets: Int?,
        numCoins: Int?,
        fiats: [Currency]?,
        markets: [Market]?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.logo = logo
        self.description = description
        self.dateL = dateL
        self.urls = urls
        self.spotVolumeUsd = spotVolumeUsd
        self.makerFee = makerFee
        self.takerFee = takerFee
        self.weeklyVisits = weeklyVisits
        self.numMarkets = numMarkets
        self.numCoins = numCoins
        self.fiats = fiats
        self.markets = markets
        self.fiatsRaw = fiats?.map { $0.symbol ?? "" }
    }
}

struct ExchangeUrls: Codable {
    let website: [String]?
    let twitter: [String]?
    let blog: [String]?
    let chat: [String]?
    let fee: [String]?
}

extension Exchange {
    static let mockData: [Exchange] = [
        Exchange(
            id: 270,
            name: "Binance",
            slug: "binance",
            logo: "https://s2.coinmarketcap.com/static/img/exchanges/64x64/270.png",
            description: "Binance is a global cryptocurrency exchange that provides a platform for trading more than 100 cryptocurrencies.",
            dateL: "2017-07-14T00:00:00.000Z",
            urls: ExchangeUrls(
                website: ["https://www.binance.com"],
                twitter: ["https://twitter.com/binance"],
                blog: nil,
                chat: nil,
                fee: nil
            ),
            spotVolumeUsd: 15000000000.50,
            makerFee: 0.1,
            takerFee: 0.1,
            weeklyVisits: 50000000,
            numMarkets: 1500,
            numCoins: 350,
            fiats: [
                Currency(id: 1, name: "US Dollar", symbol: "USD", slug: "usd", priceUsd: 1.0),
                Currency(id: 2, name: "Euro", symbol: "EUR", slug: "eur", priceUsd: 1.08)
            ],
            markets: nil
        ),
        Exchange(
            id: 311,
            name: "Coinbase Exchange",
            slug: "coinbase-exchange",
            logo: "https://s2.coinmarketcap.com/static/img/exchanges/64x64/311.png",
            description: "Coinbase Pro is a secure platform that makes it easy to buy, sell, and store cryptocurrency.",
            dateL: "2015-01-25T00:00:00.000Z",
            urls: ExchangeUrls(
                website: ["https://pro.coinbase.com"],
                twitter: ["https://twitter.com/coinbase"],
                blog: nil,
                chat: nil,
                fee: nil
            ),
            spotVolumeUsd: 2500000000.75,
            makerFee: 0.5,
            takerFee: 0.5,
            weeklyVisits: 20000000,
            numMarkets: 200,
            numCoins: 100,
            fiats: [
                Currency(id: 1, name: "US Dollar", symbol: "USD", slug: "usd", priceUsd: 1.0),
                Currency(id: 3, name: "British Pound", symbol: "GBP", slug: "gbp", priceUsd: 1.27)
            ],
            markets: nil
        ),
        Exchange(
            id: 24,
            name: "Kraken",
            slug: "kraken",
            logo: "https://s2.coinmarketcap.com/static/img/exchanges/64x64/24.png",
            description: "Kraken is a cryptocurrency exchange and bank that offers capital funding.",
            dateL: "2013-09-10T00:00:00.000Z",
            urls: ExchangeUrls(
                website: ["https://www.kraken.com"],
                twitter: ["https://twitter.com/krakenfx"],
                blog: nil,
                chat: nil,
                fee: nil
            ),
            spotVolumeUsd: 1800000000.25,
            makerFee: 0.16,
            takerFee: 0.26,
            weeklyVisits: 15000000,
            numMarkets: 300,
            numCoins: 80,
            fiats: [
                Currency(id: 1, name: "US Dollar", symbol: "USD", slug: "usd", priceUsd: 1.0),
                Currency(id: 4, name: "Japanese Yen", symbol: "JPY", slug: "jpy", priceUsd: 0.0067)
            ],
            markets: nil
        )
    ]
}
