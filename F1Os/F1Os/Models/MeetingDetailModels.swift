//
//  MeetingDetailModels.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation
import SwiftUI

enum MeetingDetailSection: String, CaseIterable, Identifiable {
    case positions = "Posizioni"
    case pitStops = "Pit Stop"
    case stints = "Gomme"
    case weather = "Meteo"
    case raceControl = "Direzione Gara"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .positions: return "flag.checkered.2.crossed"
        case .pitStops: return "wrench.and.screwdriver.fill"
        case .stints: return "circle.hexagongrid.circle.fill"
        case .weather: return "cloud.sun.fill"
        case .raceControl: return "exclamationmark.shield.fill"
        }
    }
}

struct PositionResponse: Codable {
    let driverNumber: Int
    let position: Int
    let date: String?
    let sessionKey: Int?

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case position
        case date
        case sessionKey = "session_key"
    }
}

struct PitStop: Codable, Identifiable {
    let driverNumber: Int
    let pitDuration: Double?
    let lapNumber: Int?
    let date: String?
    let sessionKey: Int?

    var id: String {
        "\(driverNumber)-\(lapNumber ?? 0)-\(date ?? UUID().uuidString)"
    }

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case pitDuration = "pit_duration"
        case lapNumber = "lap_number"
        case date
        case sessionKey = "session_key"
    }
}

struct TyreStint: Codable, Identifiable {
    let driverNumber: Int
    let stintNumber: Int?
    let compound: String?
    let tyreAgeAtStart: Int?
    let lapsStart: Int?
    let lapsEnd: Int?
    let sessionKey: Int?

    var id: String {
        "\(driverNumber)-\(stintNumber ?? 0)-\(compound ?? "UNK")"
    }

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case stintNumber = "stint_number"
        case compound
        case tyreAgeAtStart = "tyre_age_at_start"
        case lapsStart = "laps_start"
        case lapsEnd = "laps_end"
        case sessionKey = "session_key"
    }

    var compoundColor: Color {
        guard let compound = compound?.uppercased() else { return .gray }
        switch compound {
        case "SOFT": return .red
        case "MEDIUM": return .yellow
        case "HARD": return .white
        case "INTERMEDIATE": return .green
        case "WET": return .blue
        default: return .gray
        }
    }
}

struct WeatherData: Codable, Identifiable {
    let airTemperature: Double?
    let trackTemperature: Double?
    let humidity: Double?
    let rainfall: Int?
    let windSpeed: Double?
    let windDirection: Int?
    let date: String?

    var id: String { date ?? UUID().uuidString }

    enum CodingKeys: String, CodingKey {
        case airTemperature = "air_temperature"
        case trackTemperature = "track_temperature"
        case humidity
        case rainfall
        case windSpeed = "wind_speed"
        case windDirection = "wind_direction"
        case date
    }
}

struct RaceControlMessage: Codable, Identifiable {
    let driverNumber: Int?
    let lapNumber: Int?
    let category: String?
    let flag: String?
    let scope: String?
    let sector: Int?
    let message: String?
    let date: String?

    var id: String { "\(date ?? UUID().uuidString)-\(message ?? "")" }

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case lapNumber = "lap_number"
        case category
        case flag
        case scope
        case sector
        case message
        case date
    }

    var flagColor: Color {
        guard let flag = flag?.uppercased() else { return .secondary }
        switch flag {
        case "YELLOW": return .yellow
        case "GREEN": return .green
        case "RED": return .red
        case "CHEQUERED": return .primary
        case "BLACK AND WHITE": return .orange
        case "BLUE": return .blue
        default: return .secondary
        }
    }
}

struct DriverSessionPosition: Identifiable {
    let driverNumber: Int
    let position: Int
    let gridPosition: Int?
    let acronym: String
    let fullName: String
    let teamName: String
    let teamColour: String?
    let pointsEarned: Double

    var id: Int { driverNumber }

    var positionDelta: Int? {
        guard let gridPosition = gridPosition else { return nil }
        return gridPosition - position
    }
}
