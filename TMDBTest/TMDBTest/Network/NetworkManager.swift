//
//  NetworkManager.swift
//  TMDBTest
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    var baseURLImages: String?
    
    func configNetwork(completion: @escaping(Bool) -> ()) {
        self.getConfig() { [weak self] succes, baseURLImages in
            if succes {
                self?.baseURLImages = baseURLImages
                completion(true)
            }
            completion(false)
        }
    }
    
    private func getConfig(completion: @escaping(Bool, String?) -> ()) {
        
        let parameters: Parameters = [
            Constants.kAPI_KEY: Constants.kAPI_KEY_VALUE,
        ]
        
        let url = Constants.kBASE_URL + Constants.kURL_CONFIGURATION
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
            .responseJSON { response in
                switch(response.result) {
                case .success(let JSON):
                    guard let JSON = JSON as? [String: Any] else {
                        completion(false, nil)
                        return
                    }
                    JsonParser.parseConfigJson(JSON) { baseURL in
                        completion(true, baseURL)
                    }
                       
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false,nil)
                }
        }
    }
    
    func requestPopularMovies(atPage page: Int, completion: @escaping(Bool, [Movie]) -> ()) {
        
        let parameters: Parameters = [
            Constants.kAPI_KEY: Constants.kAPI_KEY_VALUE,
            Constants.kPAGE_KEY: page
        ]
        
        let url = Constants.kBASE_URL + Constants.kURL_POPULAR
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
            .responseJSON { response in
                switch(response.result) {
                case .success(let JSON):
                    guard let JSON = JSON as? [String: Any] else {
                        completion(false, [])
                        return
                    }
                    JsonParser.parseJsonMovies(JSON) { movies in
                        completion(true, movies)
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false, [])
                }
        }
    }
    
    func requestMovies(atPage page: Int, withKeyword keyword: String, completion: @escaping(Bool, [Movie]) -> ()) {
        let parameters:Parameters = [
            Constants.kAPI_KEY: Constants.kAPI_KEY_VALUE,
            Constants.kPAGE_KEY: page,
            Constants.kQUERY_KEY: keyword
        ]
        
        let url = Constants.kBASE_URL + Constants.kURL_SEARCH
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
            .responseJSON { response in
                switch (response.result) {
                case .success(let JSON):
                    guard let JSON = JSON as? [String: Any] else {
                        completion(false, [])
                        return
                    }
                    JsonParser.parseJsonMovies(JSON) { movies in
                        completion(true, movies)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false, [])
                }
        }
    }
    
    func downloadImage(fromURL url: String, completion: @escaping(Bool, UIImage?) -> ()) {
        guard let baseUrlImages = self.baseURLImages else {return}
        let completeUrl = baseUrlImages + url
        Alamofire.request(completeUrl).responseImage { response in
            
            if let image = response.result.value {
                completion(true, image)
            }
            completion(false, nil)
        }
    }
}
