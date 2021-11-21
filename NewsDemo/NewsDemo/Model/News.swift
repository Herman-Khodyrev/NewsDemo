//
//  News.swift
//  NewsDemo
//
//  Created by Герман on 18.10.21.
//

import Foundation

struct News : Codable {
	let status : String?
	let totalResults : Int?
	let articles : [Articles]?

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case totalResults = "totalResults"
		case articles = "articles"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		totalResults = try values.decodeIfPresent(Int.self, forKey: .totalResults)
		articles = try values.decodeIfPresent([Articles].self, forKey: .articles)
	}

}
