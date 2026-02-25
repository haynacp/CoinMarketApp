//
//  ViewState.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)
    
    var data: T? {
        if case .loaded(let data) = self {
            return data
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    var debugDescription: String {
        switch self {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case .loaded(let data):
            return "loaded(\(data))"
        case .empty:
            return "empty"
        case .error(let error):
            return "error(\(error.localizedDescription))"
        }
    }
}
