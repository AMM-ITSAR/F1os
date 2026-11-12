//
//  MeetingDetailViewModel.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation

@MainActor
final class MeetingDetailViewModel: ObservableObject {
    let meeting: Meeting
    private let apiService: F1APIService

    @Published var sessions: [F1Session] = []
    @Published var selectedSession: F1Session? = nil
    @Published var selectedSection: MeetingDetailSection = .positions

    @Published var driversPosition: [DriverSessionPosition] = []
    @Published var pitStops: [PitStop] = []
    @Published var stints: [TyreStint] = []
    @Published var weather: WeatherData? = nil
    @Published var raceControlMessages: [RaceControlMessage] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var driverMap: [Int: Driver] = [:]

    init(meeting: Meeting, apiService: F1APIService = .shared) {
        self.meeting = meeting
        self.apiService = apiService
    }

    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedSessions = try await apiService.fetchSessions(meetingKey: meeting.meetingKey)
            self.sessions = fetchedSessions.sorted { $0.sessionKey < $1.sessionKey }

            if let raceSession = self.sessions.first(where: { $0.sessionName?.lowercased().contains("race") == true }) {
                self.selectedSession = raceSession
            } else {
                self.selectedSession = self.sessions.last
            }

            if let activeSession = self.selectedSession {
                await loadSessionDetails(sessionKey: activeSession.sessionKey)
            }
        } catch {
            self.errorMessage = "Impossibile caricare i dati della gara."
        }

        isLoading = false
    }

    func loadSessionDetails(sessionKey: Int) async {
        isLoading = true
        let keyString = String(sessionKey)

        do {
            let rawDrivers = (try? await apiService.fetchDrivers(sessionKey: keyString)) ?? []
            try await Task.sleep(nanoseconds: 100_000_000)

            let rawPositions = (try? await apiService.fetchPositions(sessionKey: sessionKey)) ?? []
            try await Task.sleep(nanoseconds: 100_000_000)

            let fetchedPits = (try? await apiService.fetchPitStops(sessionKey: sessionKey)) ?? []
            try await Task.sleep(nanoseconds: 100_000_000)

            let fetchedStints = (try? await apiService.fetchStints(sessionKey: sessionKey)) ?? []
            try await Task.sleep(nanoseconds: 100_000_000)

            let fetchedWeather = (try? await apiService.fetchWeather(sessionKey: sessionKey)) ?? []
            try await Task.sleep(nanoseconds: 100_000_000)

            let fetchedControl = (try? await apiService.fetchRaceControl(sessionKey: sessionKey)) ?? []

            var dict: [Int: Driver] = [:]
            for driver in rawDrivers {
                if dict[driver.driverNumber] == nil {
                    dict[driver.driverNumber] = driver
                }
            }
            self.driverMap = dict

            let groupedPositions = Dictionary(grouping: rawPositions, by: { $0.driverNumber })
            var gridPositionsMap: [Int: Int] = [:]
            for (driverNum, posArray) in groupedPositions {
                if let firstRecord = posArray.first {
                    gridPositionsMap[driverNum] = firstRecord.position
                }
            }

            let sessionNameLower = selectedSession?.sessionName?.lowercased() ?? ""
            let isMainRace = sessionNameLower.contains("race") && !sessionNameLower.contains("sprint")
            let isSprintRace = sessionNameLower.contains("sprint") && !sessionNameLower.contains("qualifying") && !sessionNameLower.contains("shootout")
            let isRaceSession = isMainRace || isSprintRace

            var index = 1
            var computedPositions: [DriverSessionPosition] = []
            let sortedDrivers = rawDrivers.sorted { $0.driverNumber < $1.driverNumber }

            var seenNumbers = Set<Int>()
            for d in sortedDrivers {
                if !seenNumbers.contains(d.driverNumber) {
                    seenNumbers.insert(d.driverNumber)
                    let currentPos = index
                    let points = calculatePoints(position: currentPos, isMainRace: isMainRace, isSprintRace: isSprintRace)
                    let gridPos = isRaceSession ? gridPositionsMap[d.driverNumber] : nil

                    computedPositions.append(
                        DriverSessionPosition(
                            driverNumber: d.driverNumber,
                            position: currentPos,
                            gridPosition: gridPos,
                            acronym: d.nameAcronym ?? "F1",
                            fullName: d.fullName ?? d.broadcastName ?? "Pilota #\(d.driverNumber)",
                            teamName: d.teamName ?? "Scuderia",
                            teamColour: d.teamColour,
                            pointsEarned: points
                        )
                    )
                    index += 1
                }
            }
            self.driversPosition = computedPositions

            self.pitStops = fetchedPits.sorted { ($0.lapNumber ?? 0) < ($1.lapNumber ?? 0) }
            self.stints = fetchedStints
            self.weather = fetchedWeather.last
            self.raceControlMessages = fetchedControl.reversed()
        } catch {
            print("F1Os Debug - Errore caricamento dettagli sessione: \(error)")
        }

        isLoading = false
    }

    private func calculatePoints(position: Int, isMainRace: Bool, isSprintRace: Bool) -> Double {
        if isMainRace {
            switch position {
            case 1: return 25.0
            case 2: return 18.0
            case 3: return 15.0
            case 4: return 12.0
            case 5: return 10.0
            case 6: return 8.0
            case 7: return 6.0
            case 8: return 4.0
            case 9: return 2.0
            case 10: return 1.0
            default: return 0.0
            }
        } else if isSprintRace {
            switch position {
            case 1: return 8.0
            case 2: return 7.0
            case 3: return 6.0
            case 4: return 5.0
            case 5: return 4.0
            case 6: return 3.0
            case 7: return 2.0
            case 8: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
}
