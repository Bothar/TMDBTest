//
//  ViewController.swift
//  TMDBTest
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import UIKit

class ListMoviesViewController: UIViewController {
    @IBOutlet weak var TVmovies: UITableView!
    
    let networkManager = NetworkManager.shared
    var movies: [Movie] = []
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TVmovies.delegate = self
        TVmovies.dataSource = self
        networkManager.requestPopularMovies(atPage: page) { [weak self] succes, movies in
            if succes {
                self?.movies += movies
                self?.TVmovies.reloadData()
            }
        }
    }
}

extension ListMoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        let movie = self.movies[indexPath.row]
        cell.titleLabel.text = movie.title
        return cell
    }
    
}

