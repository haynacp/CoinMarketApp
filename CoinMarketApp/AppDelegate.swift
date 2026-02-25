//
//  AppDelegate.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 21/02/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let splashVC = createSplashScreen { [weak self] in
            self?.showMainApp(in: window)
        }
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
    
    private func createSplashScreen(onComplete: @escaping () -> Void) -> UIViewController {
        
        let splashVC = UIViewController()
        splashVC.view.backgroundColor = UIColor(red: 249/255, green: 142/255, blue: 27/255, alpha: 1.0)
        
        let logoContainer = UIView()
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.backgroundColor = .white
        logoContainer.layer.cornerRadius = 80
        logoContainer.layer.shadowColor = UIColor.black.cgColor
        logoContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        logoContainer.layer.shadowRadius = 20
        logoContainer.layer.shadowOpacity = 0.3
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        
        if let logo = UIImage(named: "AppLogo") {
            iconImageView.image = logo
        } else if let logo = UIImage(named: "Logo") {
            iconImageView.image = logo
        } else if let logo = UIImage(named: "AppIcon") {
            iconImageView.image = logo
        } else {
            iconImageView.tintColor = UIColor(red: 249/255, green: 142/255, blue: 27/255, alpha: 1.0)
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
            iconImageView.image = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: config)
        }
        
        let appNameLabel = UILabel()
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.text = "CoinMarket"
        appNameLabel.font = .systemFont(ofSize: 42, weight: .black)
        appNameLabel.textColor = .white
        appNameLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Exchanges & Cryptocurrencies"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        
        splashVC.view.addSubview(logoContainer)
        logoContainer.addSubview(iconImageView)
        splashVC.view.addSubview(appNameLabel)
        splashVC.view.addSubview(subtitleLabel)
        splashVC.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: splashVC.view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: splashVC.view.centerYAnchor, constant: -60),
            logoContainer.widthAnchor.constraint(equalToConstant: 160),
            logoContainer.heightAnchor.constraint(equalToConstant: 160),
            
            iconImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            appNameLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 30),
            appNameLabel.leadingAnchor.constraint(equalTo: splashVC.view.leadingAnchor, constant: 40),
            appNameLabel.trailingAnchor.constraint(equalTo: splashVC.view.trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: appNameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: appNameLabel.trailingAnchor),
            
            loadingIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            loadingIndicator.centerXAnchor.constraint(equalTo: splashVC.view.centerXAnchor)
        ])
        
        logoContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        logoContainer.alpha = 0
        appNameLabel.alpha = 0
        subtitleLabel.alpha = 0
        loadingIndicator.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            logoContainer.transform = .identity
            logoContainer.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            appNameLabel.alpha = 1
            subtitleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.7) {
            loadingIndicator.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .curveLinear]) {
                iconImageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.5, animations: {
                splashVC.view.alpha = 0
                splashVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                onComplete()
            }
        }
        
        return splashVC
    }
    
    private func showMainApp(in window: UIWindow) {
        
        let viewModel = ExchangeListViewModel()
        let exchangeListVC = ExchangeListViewController(viewModel: viewModel)
        
        let navController = UINavigationController(rootViewController: exchangeListVC)
        navController.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navController
        })
    
    }
}
