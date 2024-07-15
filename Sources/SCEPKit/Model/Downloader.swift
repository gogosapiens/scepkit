//
//  Downloader.swift
//  LinkBio
//
//  Created by Illia Harkavy on 14/09/2023.
//

import UIKit

fileprivate protocol DataConvertible {
    func data(with pathExtension: String) -> Data?
    static func from(data: Data) -> Self?
}

extension UIImage: DataConvertible {
    fileprivate func data(with pathExtension: String) -> Data? {
        if pathExtension.lowercased() == "png" {
            pngData()
        } else {
            jpegData(compressionQuality: 1)
        }
    }
    static func from(data: Data) -> Self? {
        Self(data: data) as Self?
    }
}

extension NSString: DataConvertible {
    func data(with pathExtension: String) -> Data? {
        data(using: NSUTF8StringEncoding)
    }
    static func from(data: Data) -> Self? {
        Self(data: data, encoding: NSUTF8StringEncoding) as Self?
    }
}

struct Downloader {
    
    private static let image = ItemDownloader<UIImage>()
    private static let nsString = ItemDownloader<NSString>()
    
    static func downloadImage(from url: URL, completion: ((UIImage?) -> ())? = nil) {
        self.image.downloadItem(from: url, completion: completion)
    }
    
    static func downloadImage(from url: URL) async throws -> UIImage {
        try await self.image.downloadItem(from: url) as UIImage
    }
    
    static func downloadString(from url: URL, completion: ((String?) -> ())? = nil) {
        self.nsString.downloadItem(from: url) { completion?($0 as? String) }
    }
    
    static func downloadString(from url: URL) async throws -> String {
        try await self.nsString.downloadItem(from: url) as String
    }
    
    static func getSavedImage(from url: URL) -> UIImage? {
        self.image.getCachedOrLocalItem(from: url)
    }
    
    static func localURL(for url: URL) -> URL {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let hashName = url.absoluteString.hash
        return cacheDirectory.appendingPathComponent("\(hashName).\(url.pathExtension)")
    }
}

fileprivate class ItemDownloader<Item: DataConvertible & AnyObject> {
    
    private let cache = NSCache<NSString, Item>()
    private var activeRequests = [URL: [((Item?) -> Void)] ]()
    
    enum DownloadError: Error {
        case unknown
    }
    
    func downloadItem(from url: URL) async throws -> Item {
        try await withCheckedThrowingContinuation { contituation in
            DispatchQueue.main.async {
                self.downloadItem(from: url) { item in
                    if let item {
                        contituation.resume(returning: item)
                    } else {
                        contituation.resume(throwing: DownloadError.unknown)
                    }
                }
            }
        }
    }
    
    func getCachedOrLocalItem(from url: URL) -> Item? {
        if let item = cache.object(forKey: url.absoluteString as NSString) {
            return item
        } else if let item = getItem(from: url) {
            cache.setObject(item, forKey: url.absoluteString as NSString)
            return item
        } else {
            return nil
        }
    }
    
    func downloadItem(from url: URL, completion: ((Item?) -> ())? = nil) {
        
        let completion = completion ?? { _ in }
        
        if let handlers = activeRequests[url], !handlers.isEmpty {
            activeRequests[url]!.append(completion)
            return
        }
        
        activeRequests[url] = [completion]
        
        func complete(with item: Item?) {
            DispatchQueue.main.async {
                self.activeRequests[url]?.forEach { $0(item) }
                self.activeRequests[url] = nil
            }
        }
        
        if let item = getCachedOrLocalItem(from: url) {
            complete(with: item)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                complete(with: nil)
                return
            }
            
            if let item = Item.from(data: data) {
                self.cache.setObject(item, forKey: url.absoluteString as NSString)
                self.saveItem(item, with: url)
                complete(with: item)
            } else {
                complete(with: nil)
            }
        }.resume()
    }
    
    private func getItem(from url: URL) -> Item? {
        let fileURL = Downloader.localURL(for: url)
        
        if let itemData = try? Data(contentsOf: fileURL), let item = Item.from(data: itemData) {
            return item
        }
        
        return nil
    }
    
    private func saveItem(_ item: Item, with url: URL) {
        let fileURL = Downloader.localURL(for: url)
        
        if let data = item.data(with: url.pathExtension) {
            try? data.write(to: fileURL)
        }
    }
}
