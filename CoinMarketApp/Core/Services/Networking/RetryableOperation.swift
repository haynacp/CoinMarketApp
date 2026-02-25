//
//  RetryableOperation.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

actor RetryableOperation {
    
    private let maxAttempts: Int
    private let initialDelay: TimeInterval
    private let maxDelay: TimeInterval
    
    init(maxAttempts: Int = 3, initialDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 10.0) {
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
    }
    
    func execute<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        var currentDelay = initialDelay
        
        for attempt in 1...maxAttempts {
            do {
                let result = try await operation()
                
                return result
                
            } catch {
                lastError = error
                
                guard shouldRetry(error: error) else {
                    throw error
                }
                
                if attempt < maxAttempts {
                    let delay = min(currentDelay, maxDelay)
                    
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    
                    currentDelay *= 2
                } else {
                }
            }
        }
        
        throw lastError ?? RetryError.unknownError
    }

    private func shouldRetry(error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .invalidResponse:
                return true
            case .noConnection:
                return false
            default:
                return false
            }
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .cannotConnectToHost, .networkConnectionLost, .dnsLookupFailed:
                return true
            case .notConnectedToInternet:
                return false
            default:
                return false
            }
        }
        
        return false
    }
}


enum RetryError: Error, LocalizedError {
    case unknownError
    case maxAttemptsReached
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "Erro desconhecido durante retry"
        case .maxAttemptsReached:
            return "Número máximo de tentativas atingido"
        }
    }
}


extension RetryableOperation {
    
    static func withDefaults() -> RetryableOperation {
        return RetryableOperation(maxAttempts: 3, initialDelay: 1.0, maxDelay: 8.0)
    }
    
    static func aggressive() -> RetryableOperation {
        return RetryableOperation(maxAttempts: 5, initialDelay: 0.5, maxDelay: 5.0)
    }
    
    static func conservative() -> RetryableOperation {
        return RetryableOperation(maxAttempts: 2, initialDelay: 2.0, maxDelay: 10.0)
    }
}

func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: TimeInterval = 1.0,
    operation: @escaping () async throws -> T
) async throws -> T {
    let retryOperation = RetryableOperation(maxAttempts: maxAttempts, initialDelay: initialDelay)
    return try await retryOperation.execute(operation)
}
