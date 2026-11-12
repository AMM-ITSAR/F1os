//
//  DriverDetailView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct PastRacePerformance: Identifiable {
    let id = UUID()
    let raceName: String
    let gridPosition: Int
    let finishPosition: Int
    let points: Double

    var positionDelta: Int {
        gridPosition - finishPosition
    }
}

struct DriverDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let driver: Driver
    let showPastPerformance: Bool
    var pastPerformances: [PastRacePerformance] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: driver.teamColour).opacity(0.25))
                                    .frame(width: 64, height: 64)

                                Text("#\(driver.driverNumber)")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color(hex: driver.teamColour))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(driver.fullName ?? driver.broadcastName ?? "Pilota")
                                        .font(.title2)
                                        .bold()
                                        .foregroundStyle(.primary)

                                    if let acronym = driver.nameAcronym {
                                        Text(acronym)
                                            .font(.caption)
                                            .bold()
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
                        }

                        Divider()
                            .overlay(Color.primary.opacity(0.12))

                        HStack {
                            DriverStatBadge(title: "Nazionalità", value: driver.countryCode ?? "N/D")
                            Spacer()
                            DriverStatBadge(title: "Numero", value: "#\(driver.driverNumber)")
                            Spacer()
                            DriverStatBadge(title: "Acronimo", value: driver.nameAcronym ?? "N/D")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(14)

                    if showPastPerformance && !pastPerformances.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Performance Passate")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            VStack(spacing: 8) {
                                ForEach(pastPerformances) { perf in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(perf.raceName)
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(.primary)
                                            Text("Griglia: P\(perf.gridPosition) → Arrivo: P\(perf.finishPosition)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        PositionDeltaBadge(delta: perf.positionDelta)

                                        if perf.points > 0 {
                                            Text("+\(Int(perf.points)) PTS")
                                                .font(.caption)
                                                .bold()
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 3)
                                                .background(Color.yellow.opacity(0.2))
                                                .foregroundStyle(.orange)
                                                .cornerRadius(6)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(driver.nameAcronym ?? "Dettaglio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

private struct DriverStatBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.primary)
        }
    }
}

private struct PositionDeltaBadge: View {
    let delta: Int

    var body: some View {
        HStack(spacing: 2) {
            if delta > 0 {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.caption2)
                Text("+\(delta)")
                    .font(.caption)
                    .bold()
            } else if delta < 0 {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption2)
                Text("\(delta)")
                    .font(.caption)
                    .bold()
            } else {
                Image(systemName: "minus")
                    .font(.caption2)
                Text("0")
                    .font(.caption)
                    .bold()
            }
        }
        .foregroundStyle(deltaColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(deltaColor.opacity(0.12))
        .cornerRadius(6)
    }

    private var deltaColor: Color {
        if delta > 0 {
            return .green
        } else if delta < 0 {
            return .red
        } else {
            return .secondary
        }
    }
}
