//
//  Movie.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 30/03/24.
//

import Foundation

// MARK: - Movie
struct Movie: Codable {
    let movies: [MovieElement]
    let page: Int
}

// MARK: - MovieElement
struct MovieElement: Codable {
    let id: Int
    let backdropPath: String
    let firstAired: String
    let genres: [String]
    let originalTitle, overview: String
    let posterPath: String
    let title: String
    let contentType: ContentType

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case backdropPath = "backdrop_path"
        case firstAired = "first_aired"
        case genres
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case title, contentType
    }
}

enum ContentType: String, Codable {
    case show = "show"
}
