//
//  JsonParser.swift
//  TMDBTest
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import Foundation

class JsonParser {
    
    static func parseConfigJson(_ json: [String: Any], completion: @escaping(String?) -> ()) {
        guard let imagesConfig = json[Constants.kIMAGES_KEY] as? [String: Any],
        let secureBaseUrl = imagesConfig[Constants.kSECURE_BASE_URL_KEY] as? String,
        let posterSizes = imagesConfig[Constants.kPOSTER_SIZES_KEY] as? [String] else {
            completion(nil)
            return
        }
        //Getting the 4rth element which is an acceptable size
        completion("\(secureBaseUrl)\(posterSizes[3])")
    }
    
    static func parseJsonMovies(_ json: [String: Any], completion: @escaping([Movie]) -> ()) {
        guard let results = json[Constants.kRESULTS_KEY] as? [[String: Any]] else {
            completion([])
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
                NetworkManager.shared.downloadImage(fromURL: posterPath) { succes , image in
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
            completion(movies)
        })
    }
}
