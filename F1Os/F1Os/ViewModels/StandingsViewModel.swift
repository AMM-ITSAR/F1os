//
//  StandingsViewModel.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation

@MainActor
final class StandingsViewModel: ObservableObject {
    @Published var driverStandings: [DisplayDriverStanding] = []
    @Published var teamStandings: [DisplayTeamStanding] = []
    @Published var selectedType: StandingType = .drivers
    @Published var selectedYear: Int = 2026
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    let availableYears: [Int] = [2026, 2025, 2024, 2023]
    private let apiService: F1APIService

    init(apiService: F1APIService = .shared) {
        self.apiService = apiService
    }

    func loadStandings() async {
        isLoading = true
        errorMessage = nil
        driverStandings = []
        teamStandings = []

        do {
            let targetSessionKey: String
            if selectedYear == 2026 {
                targetSessionKey = "latest"
            } else {
                guard let key = try await apiService.fetchLatestRaceSessionKey(year: selectedYear) else {
                    isLoading = false
                    return
                }
                targetSessionKey = key
            }

            let driversInfo = try await apiService.fetchDrivers(sessionKey: targetSessionKey)
            let driversDict = Dictionary(grouping: driversInfo, by: { $0.driverNumber })
                .compactMapValues { $0.first }

            if selectedType == .drivers {
                let rawDriverStandings = try await apiService.fetchChampionshipDrivers(sessionKey: targetSessionKey)

                var standingsDict: [Int: DisplayDriverStanding] = [:]
                for raw in rawDriverStandings {
                    let number = raw.driverNumber
                    let info = driversDict[number]

                    let standing = DisplayDriverStanding(
                        position: raw.positionCurrent ?? 0,
                        driverNumber: number,
                        driverAcronym: info?.nameAcronym ?? "F1",
                        fullName: info?.fullName ?? info?.broadcastName ?? "Pilota #\(number)",
                        teamName: raw.teamName ?? info?.teamName ?? "Team",
                        teamColour: info?.teamColour,
                        points: raw.pointsCurrent ?? 0.0
                    )
                    standingsDict[number] = standing
                }

                self.driverStandings = standingsDict.values.sorted { $0.position < $1.position }
            } else {
                let rawTeamStandings = try await apiService.fetchChampionshipTeams(sessionKey: targetSessionKey)

                var teamColours: [String: String] = [:]
                for info in driversInfo {
                    if let team = info.teamName, let colour = info.teamColour {
                        teamColours[team] = colour
                    }
                }

                var teamStandingsDict: [String: DisplayTeamStanding] = [:]
                for raw in rawTeamStandings {
                    let teamName = raw.teamName
                    let standing = DisplayTeamStanding(
                        position: raw.positionCurrent ?? 0,
                        teamName: teamName,
                        teamColour: teamColours[teamName],
                        points: raw.pointsCurrent ?? 0.0
                    )
                    teamStandingsDict[teamName] = standing
                }

                self.teamStandings = teamStandingsDict.values.sorted { $0.position < $1.position }
            }
        } catch {
            print("F1Os Debug - Errore recupero classifiche: \(error)")
            self.errorMessage = "Impossibile caricare le classifiche per il \(selectedYear)."
        }

        isLoading = false
    }
}
