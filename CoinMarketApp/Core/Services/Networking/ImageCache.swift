//
//  ImageCache.swift
//  CoinMarketApp
//
//  Created by Hayna Cardoso on 23/02/26.
//

import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "com.coinmarket.imagecache", qos: .utility)
    
    private lazy var cacheDirectory: URL = {
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("ImageCache")
    }()
    
    private init() {
        createCacheDirectoryIfNeeded()
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func getImage(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        if let diskImage = loadFromDisk(url: url) {
            cache.setObject(diskImage, forKey: key)
            return diskImage
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        
        cache.setObject(image, forKey: key, cost: imageCost(image))
        
        ioQueue.async { [weak self] in
            self?.saveToDisk(image: image, url: url)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            self.createCacheDirectoryIfNeeded()
        }
    }
    
    func removeImage(for url: URL) {
        let key = url.absoluteString as NSString
        cache.removeObject(forKey: key)
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            let fileURL = self.diskURL(for: url)
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func loadFromDisk(url: URL) -> UIImage? {
        let fileURL = diskURL(for: url)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveToDisk(image: UIImage, url: URL) {
        let fileURL = diskURL(for: url)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        do {
            try data.write(to: fileURL)
        } catch {
        }
    }
    
    private func diskURL(for url: URL) -> URL {
        let filename = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics)?
            .replacingOccurrences(of: "%", with: "_") ?? UUID().uuidString
        
        return cacheDirectory.appendingPathComponent(filename + ".jpg")
    }
    
    private func imageCost(_ image: UIImage) -> Int {
        let pixelCount = Int(image.size.width * image.size.height * image.scale * image.scale)
        let bytesPerPixel = 4
        return pixelCount * bytesPerPixel
    }
}

extension UIImageView {

    func loadImage(from url: URL, placeholder: UIImage? = nil, completion: ((Bool) -> Void)? = nil) {
        
        self.image = placeholder
        
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            self.image = cachedImage
            completion?(true)
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let image = UIImage(data: data) else {
                    await MainActor.run {
                        completion?(false)
                    }
                    return
                }
                
                ImageCache.shared.setImage(image, for: url)
                
                await MainActor.run {
                    self.image = image
                    completion?(true)
                }
                
            } catch {
                await MainActor.run {
                    completion?(false)
                }
            }
        }
    }
    
    func cancelImageLoad() {
        self.image = nil
    }
}
