//
//  MeetingsViewModel.swift
//  F1Os
//
//  Created by s12 on 30/10/26.
//

import Foundation

@MainActor
final class MeetingsViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedYear: Int = 2024
    @Published var searchText: String = ""

    let availableYears: [Int] = [2026, 2025, 2024, 2023]
    private let apiService: F1APIService

    init(apiService: F1APIService = .shared) {
        self.apiService = apiService
    }

    var filteredMeetings: [Meeting] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return meetings
        }
        return meetings.filter { meeting in
            let query = searchText.lowercased()
            let nameMatch = meeting.meetingName.lowercased().contains(query)
            let locationMatch = meeting.location?.lowercased().contains(query) ?? false
            let countryMatch = meeting.countryName?.lowercased().contains(query) ?? false
            let circuitMatch = meeting.circuitShortName?.lowercased().contains(query) ?? false
            return nameMatch || locationMatch || countryMatch || circuitMatch
        }
    }

    func loadMeetings() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedMeetings = try await apiService.fetchMeetings(year: selectedYear)
            self.meetings = fetchedMeetings
        } catch {
            self.errorMessage = "Impossibile caricare i dati dei meeting per il \(selectedYear)."
        }

        isLoading = false
    }
}
