//
//  DriverListView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct DriversListView: View {
    @StateObject private var viewModel = DriversViewModel()
    @State private var selectedDriver: Driver? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Caricamento Piloti...")
                        .controlSize(.large)
                } else if viewModel.filteredDrivers.isEmpty {
                    ContentUnavailableView(
                        "Nessun pilota trovato",
                        systemImage: "person.slash",
                        description: Text("Nessun pilota corrisponde ai criteri.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.filteredDrivers) { driver in
                                Button {
                                    selectedDriver = driver
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("#\(driver.driverNumber)")
                                                .font(.title3)
                                                .bold()
                                                .foregroundStyle(Color(hex: driver.teamColour))

                                            Spacer()

                                            if let acronym = driver.nameAcronym {
                                                Text(acronym)
                                                    .font(.caption2)
                                                    .bold()
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(4)
                                            }
                                        }

                                        Text(driver.fullName ?? driver.broadcastName ?? "Pilota")
                                            .font(.headline)
                                            .bold()
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Text(driver.teamName ?? "")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)

                                        HStack {
                                            Label(driver.countryCode ?? "F1", systemImage: "globe")
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                            Spacer()
                                            Image(systemName: "info.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Piloti F1")
            .searchable(text: $viewModel.searchText, prompt: "Cerca pilota...")
            .sheet(item: $selectedDriver) { driver in
                DriverDetailView(driver: driver, showPastPerformance: false)
            }
            .task {
                if viewModel.drivers.isEmpty {
                    await viewModel.loadDrivers()
                }
            }
        }
    }
}
