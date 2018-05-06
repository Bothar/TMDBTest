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
    var page = 0
    var rowSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TVmovies.delegate = self
        TVmovies.dataSource = self
        networkManager.configNetwork() { [weak self] succes in
            if succes {
                self?.loadMoreMovies()
            }
        }
    }
    
    private func loadMoreMovies() {
        self.page += 1
        self.networkManager.requestPopularMovies(atPage: page) { [weak self] succes, movies in
            if succes {
                self?.movies += movies
                self?.TVmovies.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let movie = movies[rowSelected]
            let nextVC = segue.destination as! MovieDetailViewController
            nextVC.movie = movie
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
        //When we load the last cell, we need to request more movies
        if (indexPath.row+1 == self.movies.count) {
            self.loadMoreMovies()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        let movie = self.movies[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.yearLabel.text = movie.year
        cell.imageview.image = movie.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.rowSelected = indexPath.row
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
}

