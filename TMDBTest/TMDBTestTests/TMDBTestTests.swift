//
//  TMDBTestTests.swift
//  TMDBTestTests
//
//  Created by David Miguel Martinez on 06/05/2018.
//  Copyright © 2018 David Miguel Martinez. All rights reserved.
//

import XCTest
@testable import TMDBTest

class TMDBTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestPopularMoviesCorrectPage() {
        let expectation = XCTestExpectation(description: "Download 20 popular movies")
        NetworkManager.shared.requestPopularMovies(atPage: 1) { succes, movies in
            if (!movies.isEmpty) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testRequestPopularMoviesInCorrectPage() {
        let expectation = XCTestExpectation(description: "Return empty movies")
        NetworkManager.shared.requestPopularMovies(atPage: 0) { succes, movies in
            if (movies.isEmpty) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
    }
    
}
