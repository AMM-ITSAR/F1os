//
//  StandingsModels.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation

enum StandingType: String, CaseIterable, Identifiable {
    case drivers = "Piloti"
    case teams = "Scuderie"

    var id: String { self.rawValue }
}

struct F1Session: Codable {
    let sessionKey: Int
    let sessionName: String?
    let year: Int?
    let dateStart: String?

    enum CodingKeys: String, CodingKey {
        case sessionKey = "session_key"
        case sessionName = "session_name"
        case year
        case dateStart = "date_start"
    }
}

struct DriverChampionshipResponse: Codable {
    let driverNumber: Int
    let pointsCurrent: Double?
    let positionCurrent: Int?
    let teamName: String?
    let sessionKey: Int?
    let meetingKey: Int?

    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case pointsCurrent = "points_current"
        case positionCurrent = "position_current"
        case teamName = "team_name"
        case sessionKey = "session_key"
        case meetingKey = "meeting_key"
    }
}

struct TeamChampionshipResponse: Codable {
    let teamName: String
    let pointsCurrent: Double?
    let positionCurrent: Int?
    let sessionKey: Int?
    let meetingKey: Int?

    enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case pointsCurrent = "points_current"
        case positionCurrent = "position_current"
        case sessionKey = "session_key"
        case meetingKey = "meeting_key"
    }
}

struct DisplayDriverStanding: Identifiable {
    let position: Int
    let driverNumber: Int
    let driverAcronym: String
    let fullName: String
    let teamName: String
    let teamColour: String?
    let points: Double

    var id: Int { driverNumber }
}

struct DisplayTeamStanding: Identifiable {
    let position: Int
    let teamName: String
    let teamColour: String?
    let points: Double

    var id: String { teamName }
}

extension DisplayDriverStanding {
    static let mocks: [DisplayDriverStanding] = [
        DisplayDriverStanding(position: 1, driverNumber: 1, driverAcronym: "VER", fullName: "Max Verstappen", teamName: "Red Bull Racing", teamColour: "3671C6", points: 437.0),
        DisplayDriverStanding(position: 2, driverNumber: 4, driverAcronym: "NOR", fullName: "Lando Norris", teamName: "McLaren", teamColour: "FF8000", points: 374.0),
        DisplayDriverStanding(position: 3, driverNumber: 16, driverAcronym: "LEC", fullName: "Charles Leclerc", teamName: "Ferrari", teamColour: "E8002D", points: 356.0),
        DisplayDriverStanding(position: 4, driverNumber: 81, driverAcronym: "PIA", fullName: "Oscar Piastri", teamName: "McLaren", teamColour: "FF8000", points: 292.0),
        DisplayDriverStanding(position: 5, driverNumber: 55, driverAcronym: "SAI", fullName: "Carlos Sainz", teamName: "Ferrari", teamColour: "E8002D", points: 290.0)
    ]
}

extension DisplayTeamStanding {
    static let mocks: [DisplayTeamStanding] = [
        DisplayTeamStanding(position: 1, teamName: "McLaren", teamColour: "FF8000", points: 666.0),
        DisplayTeamStanding(position: 2, teamName: "Ferrari", teamColour: "E8002D", points: 652.0),
        DisplayTeamStanding(position: 3, teamName: "Red Bull Racing", teamColour: "3671C6", points: 589.0),
        DisplayTeamStanding(position: 4, teamName: "Mercedes", teamColour: "27F4D2", points: 468.0),
        DisplayTeamStanding(position: 5, teamName: "Aston Martin", teamColour: "229971", points: 94.0)
    ]
}
