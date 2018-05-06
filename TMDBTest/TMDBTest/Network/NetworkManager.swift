//
//  NetworkManager.swift
//  TMDBTest
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
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
                    for movieData in results {
                        if let title = movieData[Constants.kTITLE_KEY] as? String,
                            let date = movieData[Constants.kRELEASE_DATE_KEY] as? String,
                            let overview = movieData[Constants.kOVERVIEW_KEY] as? String,
                            let posterPath = movieData[Constants.kPOSTER_PATH_KEY] as? String {
                            
                            //We only want the year (first 4 characters)
                            let year = String(date.prefix(4))
                            let movie = Movie(title: title, year: year, overview: overview, imageUrl: posterPath)
                            movies.append(movie)
                        }
                    }
                    completion(true, movies)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false, [])
                }
        }
    }
}
