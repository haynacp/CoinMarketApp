//
//  APIError.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case apiError(String)
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .decodingError(let error):
            return "Erro ao processar dados: \(error.localizedDescription)"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .apiError(let message):
            return "Erro da API: \(message)"
        case .noConnection:
            return "Sem conexão com a internet. Verifique sua conexão e tente novamente."
        }
    }
}
