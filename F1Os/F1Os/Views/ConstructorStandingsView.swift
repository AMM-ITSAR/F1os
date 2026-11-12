//
//  ConstructorStandingsView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct ConstructorStandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()
    @State private var selectedStanding: DisplayDriverStanding? = nil

    private var groupedTeams: [(teamName: String, teamColour: String, position: Int, points: Double, drivers: [DisplayDriverStanding])] {
        let grouped = Dictionary(grouping: viewModel.driverStandings, by: { $0.teamName })
        var list: [(teamName: String, teamColour: String, position: Int, points: Double, drivers: [DisplayDriverStanding])] = []

        for (teamName, drivers) in grouped {
            let color = drivers.first?.teamColour ?? "000000"
            let totalPoints = drivers.reduce(0.0) { $0 + $1.points }
            list.append((teamName: teamName, teamColour: color, position: 0, points: totalPoints, drivers: drivers))
        }

        let sorted = list.sorted { $0.points > $1.points }
        return sorted.enumerated().map { index, item in
            (teamName: item.teamName, teamColour: item.teamColour, position: index + 1, points: item.points, drivers: item.drivers)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Caricamento Classifica...")
                        .controlSize(.large)
                } else if groupedTeams.isEmpty && viewModel.teamStandings.isEmpty {
                    ContentUnavailableView(
                        "Dati Non Disponibili",
                        systemImage: "calendar.badge.clock",
                        description: Text("Nessun dato costruttori disponibile per la stagione selezionata.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(groupedTeams, id: \.teamName) { team in
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("\(team.position)")
                                            .font(.headline)
                                            .bold()
                                            .frame(width: 28, alignment: .leading)

                                        Rectangle()
                                            .fill(Color(hex: team.teamColour))
                                            .frame(width: 4, height: 28)
                                            .cornerRadius(2)

                                        Text(team.teamName)
                                            .font(.headline)
                                            .bold()
                                            .foregroundStyle(.primary)

                                        Spacer()

                                        Text("\(String(format: "%.0f", team.points)) PTS")
                                            .font(.headline)
                                            .bold()
                                            .foregroundStyle(.red)
                                    }

                                    Divider()
                                        .overlay(Color.primary.opacity(0.1))

                                    VStack(spacing: 6) {
                                        ForEach(team.drivers) { driver in
                                            Button {
                                                selectedStanding = driver
                                            } label: {
                                                HStack {
                                                    Text("#\(driver.driverNumber)")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundStyle(Color(hex: driver.teamColour))
                                                        .frame(width: 28, alignment: .leading)

                                                    Text(driver.fullName)
                                                        .font(.subheadline)
                                                        .foregroundStyle(.primary)

                                                    Spacer()

                                                    Text("\(String(format: "%.0f", driver.points)) PTS")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundStyle(.secondary)

                                                    Image(systemName: "chevron.right")
                                                        .font(.caption2)
                                                        .foregroundStyle(.tertiary)
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color(.systemGroupedBackground))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Classifica Costruttori")
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
