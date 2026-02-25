//
//  CoinMarketCapService.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import Foundation

class CoinMarketCapService {
    
    static let shared = CoinMarketCapService()
    
    private let apiKey = "cc10fd0afdeb4f71ad3bf1b59a97bc5f"
    private let baseURL = "https://pro-api.coinmarketcap.com/v1"
    
    private let session: URLSession
    private let retryOperation = RetryableOperation.withDefaults()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    internal init(forTesting: Bool) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchExchanges(limit: Int = 50) async throws -> [Exchange] {
        
        let mapEndpoint = "/exchange/map"
        guard var urlComponents = URLComponents(string: baseURL + mapEndpoint) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort", value: "volume_24h")
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (mapData, mapResponse) = try await session.data(for: request)
        
        guard let httpResponse = mapResponse as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: mapData) as? [String: Any],
               let status = json["status"] as? [String: Any],
               let errorMessage = status["error_message"] as? String {
                throw APIError.apiError(errorMessage)
            }
            throw APIError.invalidResponse
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: mapData) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]] else {
            throw APIError.invalidResponse
        }
        
        let exchangeIds = dataArray.compactMap { $0["id"] as? Int }

        let limitedIds = Array(exchangeIds.prefix(min(20, exchangeIds.count)))
        
        let infoEndpoint = "/exchange/info"
        guard var infoUrlComponents = URLComponents(string: baseURL + infoEndpoint) else {
            throw APIError.invalidURL
        }
        
        let idsString = limitedIds.map { String($0) }.joined(separator: ",")
        infoUrlComponents.queryItems = [
            URLQueryItem(name: "id", value: idsString)
        ]
        
        guard let infoUrl = infoUrlComponents.url else {
            throw APIError.invalidURL
        }
        
        var infoRequest = URLRequest(url: infoUrl)
        infoRequest.httpMethod = "GET"
        infoRequest.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        infoRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (infoData, infoResponse) = try await session.data(for: infoRequest)
        
        guard let infoHttpResponse = infoResponse as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if let jsonString = String(data: infoData, encoding: .utf8) {
            let preview = String(jsonString.prefix(2000))
        }
        
        guard (200...299).contains(infoHttpResponse.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
               let status = json["status"] as? [String: Any],
               let errorMessage = status["error_message"] as? String {
                throw APIError.apiError(errorMessage)
            }
            throw APIError.invalidResponse
        }
        
        guard let infoJson = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
              let dataDict = infoJson["data"] as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        var exchanges: [Exchange] = []
        
        for (idString, value) in dataDict {
            guard let exchangeDict = value as? [String: Any] else { continue }
            
            let id = Int(idString) ?? (exchangeDict["id"] as? Int ?? 0)
            let name = exchangeDict["name"] as? String ?? ""
            let slug = exchangeDict["slug"] as? String ?? ""
            let logo = exchangeDict["logo"] as? String
            let description = exchangeDict["description"] as? String
            let dateL = exchangeDict["date_launched"] as? String
            
            var urls: ExchangeUrls?
            if let urlsDict = exchangeDict["urls"] as? [String: Any] {
                urls = ExchangeUrls(
                    website: urlsDict["website"] as? [String],
                    twitter: urlsDict["twitter"] as? [String],
                    blog: urlsDict["blog"] as? [String],
                    chat: urlsDict["chat"] as? [String],
                    fee: urlsDict["fee"] as? [String]
                )
            }
            
            let spotVolumeUsd = exchangeDict["spot_volume_usd"] as? Double
            let makerFee = exchangeDict["maker_fee"] as? Double
            let takerFee = exchangeDict["taker_fee"] as? Double
            let numMarkets = exchangeDict["num_market_pairs"] as? Int
            
            let exchange = Exchange(
                id: id,
                name: name,
                slug: slug,
                logo: logo,
                description: description,
                dateL: dateL,
                urls: urls,
                spotVolumeUsd: spotVolumeUsd,
                makerFee: makerFee,
                takerFee: takerFee,
                weeklyVisits: nil,
                numMarkets: numMarkets,
                numCoins: nil,
                fiats: nil,
                markets: nil
            )
            
            exchanges.append(exchange)
        }
        
        exchanges.sort {
            if let vol1 = $0.spotVolumeUsd, let vol2 = $1.spotVolumeUsd {
                return vol1 > vol2
            }
            return $0.name < $1.name
        }
        
        if let first = exchanges.first {
        }
        
        return exchanges
    }
    
    func fetchExchangeInfo(id: Int) async throws -> Exchange {
        let endpoint = "/exchange/info"
        
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: "\(id)")
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? [String: Any],
                   let errorMessage = status["error_message"] as? String {
                    throw APIError.apiError(errorMessage)
                }
                throw APIError.invalidResponse
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let exchangeData = dataDict["\(id)"] {
                
                let exchangeJSON = try JSONSerialization.data(withJSONObject: exchangeData)
                let decoder = JSONDecoder()
                let exchange = try decoder.decode(Exchange.self, from: exchangeJSON)
                return exchange
            }
            
            throw APIError.invalidResponse
            
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchExchangeAssets(id: Int) async throws -> [Currency] {
        let endpoint = "/exchange/assets"
        
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: "\(id)")
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? [String: Any],
                   let errorMessage = status["error_message"] as? String {
                    throw APIError.apiError(errorMessage)
                }
                throw APIError.invalidResponse
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                var currencies: [Currency] = []
                
                if let assets = json["data"] as? [[String: Any]] {
                    
                    for asset in assets {
                        if let currencyDict = asset["currency"] as? [String: Any],
                           let name = currencyDict["name"] as? String,
                           let symbol = currencyDict["symbol"] as? String {
                            
                            let cryptoId = currencyDict["crypto_id"] as? Int
                            let priceUsd = currencyDict["price_usd"] as? Double
                            
                            let currency = Currency(
                                id: cryptoId,
                                name: name,
                                symbol: symbol,
                                slug: symbol.lowercased(),
                                priceUsd: priceUsd
                            )
                            currencies.append(currency)
                        }
                    }

                    return currencies
                }
                
                if let dataDict = json["data"] as? [String: Any] {
                    
                    let assetsData: Any? = dataDict["\(id)"] ?? dataDict
                    
                    if let assets = assetsData as? [[String: Any]] {
                       
                        for asset in assets {
                            if let currencyDict = asset["currency"] as? [String: Any],
                               let name = currencyDict["name"] as? String,
                               let symbol = currencyDict["symbol"] as? String {
                                
                                let cryptoId = currencyDict["crypto_id"] as? Int
                                let priceUsd = currencyDict["price_usd"] as? Double
                                
                                let currency = Currency(
                                    id: cryptoId,
                                    name: name,
                                    symbol: symbol,
                                    slug: symbol.lowercased(),
                                    priceUsd: priceUsd
                                )
                                currencies.append(currency)
                            }
                        }
                    }
                }
                
                return currencies
            }
            
            return []
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchExchangeMarketPairs(id: Int, limit: Int = 100) async throws -> [Market] {
        let endpoint = "/exchange/market-pairs/latest"
        
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: "\(id)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? [String: Any],
                   let errorMessage = status["error_message"] as? String {
                    throw APIError.apiError(errorMessage)
                }
                throw APIError.invalidResponse
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let marketPairs = dataDict["market_pairs"] as? [[String: Any]] {
                
                var markets: [Market] = []
                for (index, marketDict) in marketPairs.enumerated() {
                    let marketPair = marketDict["market_pair"] as? String
                    let category = marketDict["category"] as? String
                    let feeType = marketDict["fee_type"] as? String
                    
                    var volumeUsd: Double?
                    var priceUsd: Double?
                    var priceQuote: Double?
                    
                    if let quote = marketDict["quote"] as? [String: Any],
                       let usd = quote["USD"] as? [String: Any] {
                        volumeUsd = usd["volume_24h"] as? Double
                        priceUsd = usd["price"] as? Double
                    }
                    
                    let market = Market(
                        id: "\(id)_\(index)",
                        marketPair: marketPair,
                        category: category,
                        feeType: feeType,
                        volumeUsd: volumeUsd,
                        priceUsd: priceUsd,
                        priceQuote: priceQuote
                    )
                    markets.append(market)
                }
                
                return markets
            }
            
            return []
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
