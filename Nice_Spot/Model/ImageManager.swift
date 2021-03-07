//
//  ImageManager.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import Foundation
import UIKit

class ImageManager {
    private static let imageCache = NSCache<NSString, UIImage>()
    private let urlAssets = "https://github.com/hludovic/NiceSpotAssets/blob/main/"

    func getUIImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        guard imageName != "placeholder", imageName != "" else { return completion(nil) }
        if let imageCached = ImageManager.imageCache.object(forKey: NSString(string: imageName)) {
            completion(imageCached)
        } else {
            fetchImageData(imageName: imageName) {(data) in
                guard let data = data else { return completion(nil) }
                guard let uiImage = UIImage(data: data) else { return completion(nil) }
                ImageManager.imageCache.setObject(uiImage, forKey: NSString(string: imageName))
                completion(uiImage)
            }
        }
    }

    private func fetchImageData(imageName: String, completion: @escaping (Data?) -> Void) {
        let urlSession = URLSession(configuration: .default)
        var urlRequest = URLComponents(string: "\(urlAssets)/\(imageName)/\(imageName)_1.jpg")!
        urlRequest.queryItems = [URLQueryItem(name: "raw", value: "true")]
        let dataTask = urlSession.dataTask(with: urlRequest.url!) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return completion(nil)
            }
            guard let data = data, error == nil else {
                return completion(nil)
            }
            completion(data)
        }
        dataTask.resume()
    }
}
