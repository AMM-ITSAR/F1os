//
//  F1APIService.swift
//  F1Os
//
//  Created by s12 on 30/10/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)
}

final class F1APIService {
    static let shared = F1APIService()
    private let baseURL = "https://api.openf1.org/v1"

    private init() {}

    private func performRequest(url: URL, retries: Int = 3) async throws -> (Data, HTTPURLResponse) {
        var attempts = 0
        while attempts < retries {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 429 {
                    attempts += 1
                    try await Task.sleep(nanoseconds: 400_000_000 * UInt64(attempts))
                    continue
                }
                return (data, httpResponse)
            }
            attempts += 1
        }
        throw NetworkError.invalidResponse(statusCode: 429)
    }

    func fetchMeetings(year: Int = 2024) async throws -> [Meeting] {
        guard let url = URL(string: "\(baseURL)/meetings?year=\(year)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)

        if httpResponse.statusCode == 404 {
            return []
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Meeting].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func fetchLatestRaceSessionKey(year: Int) async throws -> String? {
        guard let url = URL(string: "\(baseURL)/sessions?year=\(year)&session_name=Race") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let sessions = try decoder.decode([F1Session].self, from: data)
            if let lastSession = sessions.last {
                return String(lastSession.sessionKey)
            }
            return nil
        } catch {
            return nil
        }
    }

    func fetchDrivers(sessionKey: String = "latest") async throws -> [Driver] {
        guard let url = URL(string: "\(baseURL)/drivers?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)

        if httpResponse.statusCode == 404 {
            return []
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Driver].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func fetchChampionshipDrivers(sessionKey: String = "latest") async throws -> [DriverChampionshipResponse] {
        guard let url = URL(string: "\(baseURL)/championship_drivers?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)

        if httpResponse.statusCode == 404 {
            return []
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([DriverChampionshipResponse].self, from: data)
        } catch {
            return []
        }
    }

    func fetchChampionshipTeams(sessionKey: String = "latest") async throws -> [TeamChampionshipResponse] {
        guard let url = URL(string: "\(baseURL)/championship_teams?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)

        if httpResponse.statusCode == 404 {
            return []
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([TeamChampionshipResponse].self, from: data)
        } catch {
            return []
        }
    }

    func fetchSessions(meetingKey: Int) async throws -> [F1Session] {
        guard let url = URL(string: "\(baseURL)/sessions?meeting_key=\(meetingKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([F1Session].self, from: data)
        } catch {
            return []
        }
    }

    func fetchPositions(sessionKey: Int) async throws -> [PositionResponse] {
        guard let url = URL(string: "\(baseURL)/position?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([PositionResponse].self, from: data)
        } catch {
            return []
        }
    }

    func fetchPitStops(sessionKey: Int) async throws -> [PitStop] {
        guard let url = URL(string: "\(baseURL)/pit?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([PitStop].self, from: data)
        } catch {
            return []
        }
    }

    func fetchStints(sessionKey: Int) async throws -> [TyreStint] {
        guard let url = URL(string: "\(baseURL)/stints?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([TyreStint].self, from: data)
        } catch {
            return []
        }
    }

    func fetchWeather(sessionKey: Int) async throws -> [WeatherData] {
        guard let url = URL(string: "\(baseURL)/weather?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([WeatherData].self, from: data)
        } catch {
            return []
        }
    }

    func fetchRaceControl(sessionKey: Int) async throws -> [RaceControlMessage] {
        guard let url = URL(string: "\(baseURL)/race_control?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, httpResponse) = try await performRequest(url: url)
        guard httpResponse.statusCode == 200 else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([RaceControlMessage].self, from: data)
        } catch {
            return []
        }
    }
}
