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
                    guard let JSON = JSON as? [String: Any],
                        let imagesConfig = JSON[Constants.kIMAGES_KEY] as? [String: Any],
                        let secureBaseUrl = imagesConfig[Constants.kSECURE_BASE_URL_KEY] as? String,
                        let posterSizes = imagesConfig[Constants.kPOSTER_SIZES_KEY] as? [String] else {
                            completion(false, nil)
                            return
                    }
                    //Getting the 4rth element which is an acceptable size
                    completion(true,"\(secureBaseUrl)\(posterSizes[3])")
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
                    guard let JSON = JSON as? [String: Any],
                        let results = JSON[Constants.kRESULTS_KEY] as? [[String: Any]] else {
                            completion(false,[])
                            return
                    }
                    var movies: [Movie] = []
                    //TaskGroup to notify when all images are downloaded
                    let taskGroup = DispatchGroup()
                    for movieData in results {
                        if let title = movieData[Constants.kTITLE_KEY] as? String,
                            let date = movieData[Constants.kRELEASE_DATE_KEY] as? String,
                            let overview = movieData[Constants.kOVERVIEW_KEY] as? String,
                            let posterPath = movieData[Constants.kPOSTER_PATH_KEY] as? String {
                            
                            //We only want the year (first 4 characters)
                            let year = String(date.prefix(4))
                            
                            taskGroup.enter()
                            self.downloadImage(fromURL: posterPath) { succes , image in
                                if (succes) {
                                    let movie = Movie(title: title, year: year, overview: overview, image: image!)
                                    movies.append(movie)
                                } else {
                                    taskGroup.leave()
                                }
                            }
                           
                        }
                    }
                    taskGroup.notify(queue: DispatchQueue.main, execute: {
                        completion(true, movies)
                    })
                    
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
