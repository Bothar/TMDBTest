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
    @IBOutlet weak var searchBar: UISearchBar!
    
    let networkManager = NetworkManager.shared
    var movies: [Movie] = []
    var searchMovies: [Movie] = []
    var page = 0
    var pageSearch = 0
    var rowSelected = 0
    var searchEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TVmovies.delegate = self
        TVmovies.dataSource = self
        searchBar.delegate = self
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
    
    private func loadMoreSearchMovies(withKeyword keyword: String)  {
        self.pageSearch += 1
        self.networkManager.requestMovies(atPage: pageSearch, withKeyword: keyword) { [weak self] succes, movies in
            self?.searchMovies += movies
            self?.TVmovies.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            var movie: Movie
            if searchEnabled {
                movie = searchMovies[rowSelected]
            } else {
                movie = movies[rowSelected]
            }
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
        return searchEnabled ? searchMovies.count : movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        var movie: Movie
        if (searchEnabled) {
            movie = self.searchMovies[indexPath.row]
            //When we load the last cell, we need to request more movies
            if (indexPath.row+1 == self.searchMovies.count) {
                self.loadMoreSearchMovies(withKeyword: self.searchBar.text!)
            }
        } else {
            //When we load the last cell, we need to request more movies
            if (indexPath.row+1 == self.movies.count) {
                self.loadMoreMovies()
            }
            movie = self.movies[indexPath.row]
        }
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

extension ListMoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else {return}
        if !searchText.isEmpty {
            searchEnabled = true
            self.pageSearch = 0
            self.searchMovies = []
            self.TVmovies.reloadData()
            self.loadMoreSearchMovies(withKeyword: searchText)
        } else {
            searchEnabled = false
            TVmovies.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

