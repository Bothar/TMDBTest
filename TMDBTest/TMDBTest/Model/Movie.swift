//
//  Movie.swift
//  TMDBTest
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import Foundation
import UIKit

class Movie {
    let title: String
    let year: String
    let overview: String
    let image: UIImage
    
    init(title: String, year: String, overview: String, image: UIImage) {
        self.title = title
        self.year = year
        self.overview = overview
        self.image = image
    }
}
