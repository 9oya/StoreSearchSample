//
//  StoreModel.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import Foundation

struct SearchResponseModel: Codable {
    let resultCount: Int
    let results: [SearchModel]?
}

struct SearchModel: Codable {
    let features: [String]?
    let supportedDevices: [String]?
    let advisories: [String]?
    let isGameCenterEnabled: Bool
    let ipadScreenshotUrls: [String]?
    let appletvScreenshotUrls: [String]?
    let artworkUrl60: String?
    let artworkUrl512: String?
    let artworkUrl100: String?
    let artistViewUrl: String?
    let screenshotUrls: [String]?
    let kind: String?
    let minimumOsVersion: String?
    let formattedPrice: String?
    let primaryGenreName: String?
    let trackId: Int
    let trackName: String
    let genreIds: [String]?
    let sellerName: String
    let currentVersionReleaseDate: String
    let releaseNotes: String?
    let releaseDate: String?
    let isVppDeviceBasedLicensingEnabled: Bool
    let trackCensoredName: String?
    let languageCodesISO2A: [String]
    let fileSizeBytes: String
    let sellerUrl: String?
    let contentAdvisoryRating: String
    let averageUserRatingForCurrentVersion: Float
    let userRatingCountForCurrentVersion: Int
    let averageUserRating: Float?
    let trackViewUrl: String?
    let trackContentRating: String
    let artistId: Int
    let artistName: String
    let genres: [String]?
    let price: Int
    let primaryGenreId: Int
    let bundleId: String
    let description: String
    let currency: String
    let version: String
    let wrapperType: String
    let userRatingCount: Int
}
