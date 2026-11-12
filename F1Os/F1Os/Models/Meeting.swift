//
//  Meeting.swift
//  F1Os
//
//  Created by s12 on 30/10/26.
//

import Foundation

struct Meeting: Identifiable, Codable {
    let meetingKey: Int
    let meetingName: String
    let meetingOfficialName: String?
    let location: String?
    let countryName: String?
    let countryCode: String?
    let circuitShortName: String?
    let dateStart: String?
    let year: Int

    var id: Int { meetingKey }

    enum CodingKeys: String, CodingKey {
        case meetingKey = "meeting_key"
        case meetingName = "meeting_name"
        case meetingOfficialName = "meeting_official_name"
        case location
        case countryName = "country_name"
        case countryCode = "country_code"
        case circuitShortName = "circuit_short_name"
        case dateStart = "date_start"
        case year
    }
}
