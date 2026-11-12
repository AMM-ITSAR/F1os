//
//  Driver.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation
import SwiftUI

struct Driver: Identifiable, Codable {
    let driverNumber: Int
    let broadcastName: String?
    let fullName: String?
    let firstName: String?
    let lastName: String?
    let nameAcronym: String?
    let teamName: String?
    let teamColour: String?
    let headshotUrl: String?
    let countryCode: String?
    let meetingKey: Int?
    let sessionKey: Int?

    var id: Int { driverNumber }

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case broadcastName = "broadcast_name"
        case fullName = "full_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case nameAcronym = "name_acronym"
        case teamName = "team_name"
        case teamColour = "team_colour"
        case headshotUrl = "headshot_url"
        case countryCode = "country_code"
        case meetingKey = "meeting_key"
        case sessionKey = "session_key"
    }
}

extension Color {
    init(hex: String?) {
        guard let hex = hex, !hex.isEmpty else {
            self = .gray
            return
        }
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleanHex.count {
        case 6:
            (r, g, b) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}
