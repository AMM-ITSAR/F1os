//
//  StandingsView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct StandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Tipo Classifica", selection: $viewModel.selectedType) {
                        ForEach(StandingType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Caricamento Classifica...")
                            .controlSize(.large)
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Riprova") {
                                Task {
                                    await viewModel.loadStandings()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        Spacer()
                    } else if viewModel.selectedType == .drivers && viewModel.driverStandings.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "Dati Non Disponibili",
                            systemImage: "calendar.badge.clock",
                            description: Text("I dati per la stagione \(String(viewModel.selectedYear)) non sono ancora stati registrati su OpenF1.")
                        )
                        Spacer()
                    } else if viewModel.selectedType == .teams && viewModel.teamStandings.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "Dati Non Disponibili",
                            systemImage: "calendar.badge.clock",
                            description: Text("I dati per la stagione \(String(viewModel.selectedYear)) non sono ancora stati registrati su OpenF1.")
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                if viewModel.selectedType == .drivers {
                                    ForEach(viewModel.driverStandings) { standing in
                                        DriverStandingCardButton(standing: standing) {
                                            // Riservato per la futura schermata di dettaglio classifica pilota
                                        }
                                    }
                                } else {
                                    ForEach(viewModel.teamStandings) { standing in
                                        TeamStandingCardButton(standing: standing) {
                                            // Riservato per la futura schermata di dettaglio classifica scuderia
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .navigationTitle("Classifiche F1")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Stagione", selection: $viewModel.selectedYear) {
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Text("Stagione \(String(year))").tag(year)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(String(viewModel.selectedYear))
                                .bold()
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                    }
                }
            }
            .task {
                if viewModel.driverStandings.isEmpty && viewModel.teamStandings.isEmpty {
                    await viewModel.loadStandings()
                }
            }
            .onChange(of: viewModel.selectedYear) { _, _ in
                Task {
                    await viewModel.loadStandings()
                }
            }
            .onChange(of: viewModel.selectedType) { _, _ in
                Task {
                    await viewModel.loadStandings()
                }
            }
        }
    }
}

private struct DriverStandingCardButton: View {
    let standing: DisplayDriverStanding
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                PositionBadge(position: standing.position)

                Rectangle()
                    .fill(Color(hex: standing.teamColour))
                    .frame(width: 5, height: 38)
                    .cornerRadius(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(standing.fullName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(standing.driverAcronym)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }

                    Text(standing.teamName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(String(format: "%.0f", standing.points)) PTS")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.primary)

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

private struct TeamStandingCardButton: View {
    let standing: DisplayTeamStanding
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                PositionBadge(position: standing.position)

                Rectangle()
                    .fill(Color(hex: standing.teamColour))
                    .frame(width: 5, height: 38)
                    .cornerRadius(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(standing.teamName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text("\(String(format: "%.0f", standing.points)) PTS")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.primary)

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

private struct PositionBadge: View {
    let position: Int

    private var badgeColor: Color {
        switch position {
        case 1: return Color(red: 0.95, green: 0.75, blue: 0.1)
        case 2: return Color(red: 0.7, green: 0.7, blue: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.3)
        default: return Color(.tertiaryLabel)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(badgeColor.opacity(position <= 3 ? 0.2 : 0.1))
                .frame(width: 32, height: 32)

            Text("P\(position)")
                .font(.subheadline)
                .bold()
                .foregroundStyle(position <= 3 ? badgeColor : Color.primary)
        }
    }
}
