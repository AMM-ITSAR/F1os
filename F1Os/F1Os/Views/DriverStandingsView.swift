//
//  DriverStandingsView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct DriverStandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()
    @State private var selectedStanding: DisplayDriverStanding? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Caricamento Classifica...")
                        .controlSize(.large)
                } else if viewModel.driverStandings.isEmpty {
                    ContentUnavailableView(
                        "Dati Non Disponibili",
                        systemImage: "calendar.badge.clock",
                        description: Text("Nessun dato classifica piloti disponibile per la stagione selezionata.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.driverStandings) { standing in
                                Button {
                                    selectedStanding = standing
                                } label: {
                                    HStack(spacing: 12) {
                                        Text("\(standing.position)")
                                            .font(.headline)
                                            .bold()
                                            .frame(width: 28, alignment: .leading)
                                            .foregroundStyle(.primary)

                                        Rectangle()
                                            .fill(Color(hex: standing.teamColour))
                                            .frame(width: 4, height: 36)
                                            .cornerRadius(2)

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(standing.fullName)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundStyle(.primary)

                                                Text(standing.driverAcronym)
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundStyle(.secondary)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(4)
                                            }

                                            Text(standing.teamName)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Text("\(String(format: "%.0f", standing.points)) PTS")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundStyle(.primary)

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
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
            .navigationTitle("Classifica Piloti")
            .sheet(item: $selectedStanding) { standing in
                DriverDetailView(
                    driver: Driver(
                        driverNumber: standing.driverNumber,
                        broadcastName: standing.fullName,
                        fullName: standing.fullName,
                        firstName: nil,
                        lastName: nil,
                        nameAcronym: standing.driverAcronym,
                        teamName: standing.teamName,
                        teamColour: standing.teamColour,
                        headshotUrl: nil,
                        countryCode: nil,
                        meetingKey: nil,
                        sessionKey: nil
                    ),
                    showPastPerformance: true
                )
            }
            .task {
                if viewModel.driverStandings.isEmpty {
                    await viewModel.loadStandings()
                }
            }
        }
    }
}
