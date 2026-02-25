//
//  UIColor+MercadoBitcoin.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import UIKit

extension UIColor {
    
    static let mbOrange = UIColor(red: 255/255, green: 107/255, blue: 53/255, alpha: 1.0)
    
    static let mbOrangeDark = UIColor(red: 232/255, green: 90/255, blue: 42/255, alpha: 1.0)
    
    static let mbOrangeLight = UIColor(red: 255/255, green: 243/255, blue: 239/255, alpha: 1.0)
    
    static let mbDarkBlue = UIColor(red: 26/255, green: 31/255, blue: 54/255, alpha: 1.0)
    
    static let mbGray = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0)
    
    static let mbLightGray = UIColor(red: 249/255, green: 250/255, blue: 251/255, alpha: 1.0)
    
    static let mbPositive = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
    
    static let mbNegative = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
    
    static let mbWhite = UIColor.white
    
    static var mbBackground: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1.0)
            default:
                return .mbWhite
            }
        }
    }
    
    static var mbSecondaryBackground: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
            default:
                return .mbLightGray
            }
        }
    }
    
    static var mbPrimaryText: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .mbDarkBlue
            }
        }
    }
    
    static var mbSecondaryText: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 174/255, green: 174/255, blue: 178/255, alpha: 1.0)
            default:
                return .mbGray
            }
        }
    }
    
    static var mbSeparator: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(white: 1.0, alpha: 0.1)
            default:
                return UIColor(white: 0.0, alpha: 0.1)
            }
        }
    }
}
