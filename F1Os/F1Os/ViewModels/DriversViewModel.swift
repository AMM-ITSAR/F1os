//
//  DriversViewModel.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import Foundation

@MainActor
final class DriversViewModel: ObservableObject {
    @Published var drivers: [Driver] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    private let apiService: F1APIService

    init(apiService: F1APIService = .shared) {
        self.apiService = apiService
    }

    var filteredDrivers: [Driver] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return drivers
        }
        return drivers.filter { driver in
            let query = searchText.lowercased()
            let nameMatch = driver.fullName?.lowercased().contains(query) ?? false
            let acronymMatch = driver.nameAcronym?.lowercased().contains(query) ?? false
            let teamMatch = driver.teamName?.lowercased().contains(query) ?? false
            let numberMatch = String(driver.driverNumber).contains(query)
            return nameMatch || acronymMatch || teamMatch || numberMatch
        }
    }

    func loadDrivers() async {
        isLoading = true
        errorMessage = nil

        do {
            let rawDrivers = try await apiService.fetchDrivers()
            
            var uniqueDrivers: [Int: Driver] = [:]
            for driver in rawDrivers {
                if uniqueDrivers[driver.driverNumber] == nil {
                    uniqueDrivers[driver.driverNumber] = driver
                }
            }
            
            self.drivers = uniqueDrivers.values.sorted { $0.driverNumber < $1.driverNumber }
        } catch {
            print("F1Os Debug - Errore caricamento piloti: \(error)")
            self.errorMessage = "Impossibile caricare i dati dei piloti."
        }

        isLoading = false
    }
}
