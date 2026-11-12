//
//  DriversView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct DriversView: View {
    @StateObject private var viewModel = DriversViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Caricamento Piloti...")
                        .controlSize(.large)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Riprova") {
                            Task {
                                await viewModel.loadDrivers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if viewModel.filteredDrivers.isEmpty {
                    ContentUnavailableView(
                        "Nessun pilota trovato",
                        systemImage: "person.slash",
                        description: Text("Nessun pilota corrisponde a \"\(viewModel.searchText)\"")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredDrivers) { driver in
                                DriverCardButton(driver: driver) {
                                    // Riservato per la futura schermata di dettaglio pilota
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Piloti F1")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Cerca pilota, numero o team...")
            .task {
                if viewModel.drivers.isEmpty {
                    await viewModel.loadDrivers()
                }
            }
        }
    }
}

private struct DriverCardButton: View {
    let driver: Driver
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color(hex: driver.teamColour))
                    .frame(width: 6, height: 50)
                    .cornerRadius(3)

                if let urlString = driver.headshotUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .background(Circle().fill(Color(.systemGray6)))
                        case .failure, .empty:
                            FallbackDriverAvatar(acronym: driver.nameAcronym ?? "F1")
                        @unknown default:
                            FallbackDriverAvatar(acronym: driver.nameAcronym ?? "F1")
                        }
                    }
                } else {
                    FallbackDriverAvatar(acronym: driver.nameAcronym ?? "F1")
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(driver.fullName ?? driver.broadcastName ?? "Pilota")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if let acronym = driver.nameAcronym {
                            Text(acronym)
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }

                    Text(driver.teamName ?? "Scuderia Sconosciuta")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("#\(driver.driverNumber)")
                    .font(.title2)
                    .bold()
                    .italic()
                    .foregroundStyle(Color(hex: driver.teamColour))

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

private struct FallbackDriverAvatar: View {
    let acronym: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.12))
                .frame(width: 50, height: 50)

            Text(acronym)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.red)
        }
    }
}
