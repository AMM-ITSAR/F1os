//
//  MeetingDetailView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct MeetingDetailView: View {
    @StateObject private var viewModel: MeetingDetailViewModel
    @State private var isSessionPickerExpanded: Bool = false
    @State private var isSectionPickerExpanded: Bool = false
    @State private var selectedDriverDetail: DriverSessionPosition? = nil

    init(meeting: Meeting) {
        _viewModel = StateObject(wrappedValue: MeetingDetailViewModel(meeting: meeting))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Caricamento Dettagli...")
                    .controlSize(.large)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        MeetingHeaderCard(meeting: viewModel.meeting)

                        VStack(spacing: 10) {
                            if !viewModel.sessions.isEmpty {
                                DisclosureGroup(
                                    isExpanded: $isSessionPickerExpanded,
                                    content: {
                                        VStack(spacing: 4) {
                                            Divider()
                                                .overlay(Color.primary.opacity(0.15))
                                                .padding(.vertical, 4)

                                            ForEach(viewModel.sessions, id: \.sessionKey) { session in
                                                Button {
                                                    viewModel.selectedSession = session
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        isSessionPickerExpanded = false
                                                    }
                                                    Task {
                                                        await viewModel.loadSessionDetails(sessionKey: session.sessionKey)
                                                    }
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "timer")
                                                            .foregroundStyle(viewModel.selectedSession?.sessionKey == session.sessionKey ? .red : .primary)

                                                        Text(session.sessionName ?? "Sessione")
                                                            .font(.subheadline)
                                                            .bold(viewModel.selectedSession?.sessionKey == session.sessionKey)
                                                            .foregroundStyle(viewModel.selectedSession?.sessionKey == session.sessionKey ? .red : .primary)

                                                        Spacer()

                                                        if viewModel.selectedSession?.sessionKey == session.sessionKey {
                                                            Image(systemName: "checkmark")
                                                                .font(.caption)
                                                                .bold()
                                                                .foregroundStyle(.red)
                                                        }
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 4)
                                                }
                                            }
                                        }
                                    },
                                    label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "flag.checkered.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.red)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Sessione")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                Text(viewModel.selectedSession?.sessionName ?? "Seleziona Sessione")
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundStyle(.primary)
                                            }

                                            Spacer()
                                        }
                                    }
                                )
                                .tint(.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                            }

                            DisclosureGroup(
                                isExpanded: $isSectionPickerExpanded,
                                content: {
                                    VStack(spacing: 4) {
                                        Divider()
                                            .overlay(Color.primary.opacity(0.15))
                                            .padding(.vertical, 4)

                                        ForEach(MeetingDetailSection.allCases) { section in
                                            Button {
                                                viewModel.selectedSection = section
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    isSectionPickerExpanded = false
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: section.iconName)
                                                        .foregroundStyle(viewModel.selectedSection == section ? .red : .primary)
                                                        .frame(width: 24)

                                                    Text(section.rawValue)
                                                        .font(.subheadline)
                                                        .bold(viewModel.selectedSection == section)
                                                        .foregroundStyle(viewModel.selectedSection == section ? .red : .primary)

                                                    Spacer()

                                                    if viewModel.selectedSection == section {
                                                        Image(systemName: "checkmark")
                                                            .font(.caption)
                                                            .bold()
                                                            .foregroundStyle(.red)
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                },
                                label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: viewModel.selectedSection.iconName)
                                            .font(.title3)
                                            .foregroundStyle(.red)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Visualizzazione")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(viewModel.selectedSection.rawValue)
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(.primary)
                                        }

                                        Spacer()
                                    }
                                }
                            )
                            .tint(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }

                        VStack(spacing: 10) {
                            switch viewModel.selectedSection {
                            case .positions:
                                PositionsListView(positions: viewModel.driversPosition) { driver in
                                    selectedDriverDetail = driver
                                }
                            case .pitStops:
                                PitStopsListView(pitStops: viewModel.pitStops, driverMap: viewModel.driverMap)
                            case .stints:
                                TyreStintsListView(stints: viewModel.stints, driverMap: viewModel.driverMap)
                            case .weather:
                                WeatherDetailCard(weather: viewModel.weather)
                            case .raceControl:
                                RaceControlListView(messages: viewModel.raceControlMessages)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle(viewModel.meeting.circuitShortName ?? "Dettaglio GP")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDriverDetail) { driverPos in
            DriverSessionDetailSheet(
                driverPosition: driverPos,
                pitStops: viewModel.pitStops.filter { $0.driverNumber == driverPos.driverNumber },
                stints: viewModel.stints.filter { $0.driverNumber == driverPos.driverNumber },
                raceControlMessages: viewModel.raceControlMessages.filter { msg in
                    msg.driverNumber == driverPos.driverNumber ||
                    (msg.message ?? "").lowercased().contains(driverPos.acronym.lowercased())
                }
            )
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}

private struct MeetingHeaderCard: View {
    let meeting: Meeting

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meeting.meetingName)
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)

            HStack {
                Label(meeting.location ?? "N/D", systemImage: "mappin.and.ellipse")
                Spacer()
                Label(meeting.countryName ?? "", systemImage: "globe")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

private struct PositionsListView: View {
    let positions: [DriverSessionPosition]
    let onSelectDriver: (DriverSessionPosition) -> Void

    var body: some View {
        if positions.isEmpty {
            ContentUnavailableView("Nessun dato posizione", systemImage: "flag.slash")
        } else {
            LazyVStack(spacing: 8) {
                ForEach(positions) { item in
                    Button {
                        onSelectDriver(item)
                    } label: {
                        HStack(spacing: 10) {
                            Text("P\(item.position)")
                                .font(.headline)
                                .bold()
                                .frame(width: 34, alignment: .leading)
                                .foregroundStyle(.primary)

                            Rectangle()
                                .fill(Color(hex: item.teamColour))
                                .frame(width: 4, height: 36)
                                .cornerRadius(2)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(item.fullName)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)

                                    Text(item.acronym)
                                        .font(.caption2)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(4)
                                }

                                Text(item.teamName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if let delta = item.positionDelta {
                                PositionDeltaBadge(delta: delta)
                            }

                            if item.pointsEarned > 0 {
                                Text("+\(String(format: "%.0f", item.pointsEarned)) PTS")
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.yellow.opacity(0.2))
                                    .foregroundStyle(.orange)
                                    .cornerRadius(6)
                            }

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct DriverSessionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let driverPosition: DriverSessionPosition
    let pitStops: [PitStop]
    let stints: [TyreStint]
    let raceControlMessages: [RaceControlMessage]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: driverPosition.teamColour).opacity(0.2))
                                    .frame(width: 54, height: 54)

                                Text("#\(driverPosition.driverNumber)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(Color(hex: driverPosition.teamColour))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(driverPosition.fullName)
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(.primary)

                                    Text(driverPosition.acronym)
                                        .font(.caption)
                                        .bold()
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(4)
                                }

                                Text(driverPosition.teamName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }

                        Divider()
                            .overlay(Color.primary.opacity(0.12))

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Posizione Finale")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("P\(driverPosition.position)")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            if let grid = driverPosition.gridPosition {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Griglia Partenza")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text("P\(grid)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }

                                Spacer()
                            }

                            if let delta = driverPosition.positionDelta {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Variazione")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    PositionDeltaBadge(delta: delta)
                                }

                                Spacer()
                            }

                            if driverPosition.pointsEarned > 0 {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Punti Gara")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text("+\(String(format: "%.0f", driverPosition.pointsEarned)) PTS")
                                        .font(.headline)
                                        .bold()
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(14)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Dinamica Posizioni & Sorpassi", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: 12) {
                            if let delta = driverPosition.positionDelta {
                                if delta > 0 {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrowtriangle.up.fill")
                                            .foregroundStyle(.green)
                                        Text("Il pilota ha guadagnato \(delta) posizion\(delta == 1 ? "e" : "i") rispetto alla griglia iniziale.")
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                    }
                                } else if delta < 0 {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .foregroundStyle(.red)
                                        Text("Il pilota ha perso \(abs(delta)) posizion\(abs(delta) == 1 ? "e" : "i") rispetto alla griglia iniziale.")
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "equal")
                                            .foregroundStyle(.secondary)
                                        Text("Il pilota ha mantenuto la posizione di partenza durante l'evento.")
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            } else {
                                Text("Nessun dato di partenza registrato per il confronto.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Strategia Gomme (\(stints.count))", systemImage: "circle.hexagongrid.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if stints.isEmpty {
                            Text("Nessun dato mescole disponibile per questo pilota.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(stints) { stint in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(stint.compoundColor)
                                            .frame(width: 14, height: 14)
                                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Stint \(stint.stintNumber ?? 1) - \(stint.compound ?? "Mescola N/D")")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(.primary)
                                            if let age = stint.tyreAgeAtStart {
                                                Text("Giri gomma all'avvio: \(age)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()

                                        if let start = stint.lapsStart, let end = stint.lapsEnd {
                                            Text("Giri \(start) - \(end)")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pit Stop (\(pitStops.count))", systemImage: "wrench.and.screwdriver.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if pitStops.isEmpty {
                            Text("Nessun pit stop effettuato durante questa sessione.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(pitStops) { pit in
                                    HStack {
                                        Text("Giro \(pit.lapNumber ?? 0)")
                                            .font(.caption)
                                            .bold()
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red.opacity(0.12))
                                            .foregroundStyle(.red)
                                            .cornerRadius(6)

                                        Spacer()

                                        if let duration = pit.pitDuration {
                                            Text(String(format: "%.2f s", duration))
                                                .font(.headline)
                                                .bold()
                                                .foregroundStyle(.primary)
                                        } else {
                                            Text("N/D")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Eventi & Segnalazioni Direzione Gara (\(raceControlMessages.count))", systemImage: "exclamationmark.shield.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if raceControlMessages.isEmpty {
                            Text("Nessun evento o investigazione registrata per questo pilota.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(raceControlMessages) { msg in
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(msg.flagColor)
                                            .frame(width: 12, height: 12)
                                            .padding(.top, 4)

                                        VStack(alignment: .leading, spacing: 4) {
                                            if let lap = msg.lapNumber {
                                                Text("Giro \(lap)")
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundStyle(.secondary)
                                            }
                                            Text(msg.message ?? "Segnalazione")
                                                .font(.subheadline)
                                                .foregroundStyle(.primary)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
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
            .navigationTitle("Dettaglio Pilota")
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

private struct PitStopsListView: View {
    let pitStops: [PitStop]
    let driverMap: [Int: Driver]

    @State private var selectedLap: Int = 0
    @State private var isLapPickerExpanded: Bool = false

    private var availableLaps: [Int] {
        let laps = pitStops.compactMap { $0.lapNumber }
        return Array(Set(laps)).sorted()
    }

    private var filteredPitStops: [PitStop] {
        if selectedLap == 0 {
            return pitStops
        }
        return pitStops.filter { $0.lapNumber == selectedLap }
    }

    var body: some View {
        if pitStops.isEmpty {
            ContentUnavailableView("Nessun Pit Stop registrato", systemImage: "wrench.and.screwdriver")
        } else {
            VStack(spacing: 10) {
                DisclosureGroup(
                    isExpanded: $isLapPickerExpanded,
                    content: {
                        VStack(spacing: 4) {
                            Divider()
                                .overlay(Color.primary.opacity(0.15))
                                .padding(.vertical, 4)

                            Picker("Giro", selection: $selectedLap) {
                                Text("Tutti i giri").tag(0)
                                ForEach(availableLaps, id: \.self) { lap in
                                    Text("Giro \(lap)").tag(lap)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)

                            Button("Conferma") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isLapPickerExpanded = false
                                }
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.red)
                            .padding(.vertical, 6)
                        }
                    },
                    label: {
                        HStack(spacing: 10) {
                            Image(systemName: "number.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Filtra Giro")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(selectedLap == 0 ? "Tutti i giri" : "Giro \(selectedLap)")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }

                            Spacer()
                        }
                    }
                )
                .tint(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                if filteredPitStops.isEmpty {
                    ContentUnavailableView(
                        "Nessun Pit Stop trovato",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Nessun pit stop effettuato nel giro selezionato.")
                    )
                    .padding(.top, 16)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredPitStops) { pit in
                            let driver = driverMap[pit.driverNumber]
                            HStack(spacing: 12) {
                                Text("Giro \(pit.lapNumber ?? 0)")
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.12))
                                    .foregroundStyle(.red)
                                    .cornerRadius(6)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(driver?.fullName ?? "Pilota #\(pit.driverNumber)")
                                        .font(.subheadline)
                                        .bold()
                                    Text(driver?.teamName ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if let duration = pit.pitDuration {
                                    Text(String(format: "%.2f s", duration))
                                        .font(.headline)
                                        .bold()
                                        .foregroundStyle(.primary)
                                } else {
                                    Text("N/D")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

private struct TyreStintsListView: View {
    let stints: [TyreStint]
    let driverMap: [Int: Driver]

    @State private var selectedCompound: TyreCompoundFilter = .all
    @State private var isCompoundPickerExpanded: Bool = false

    private enum TyreCompoundFilter: String, CaseIterable, Identifiable {
        case all = "Tutti i composti"
        case soft = "Soft"
        case medium = "Medium"
        case hard = "Hard"
        case intermediate = "Intermedie"
        case wet = "Bagnato"

        var id: String { self.rawValue }

        var color: Color {
            switch self {
            case .all: return .gray
            case .soft: return .red
            case .medium: return .yellow
            case .hard: return .white
            case .intermediate: return .green
            case .wet: return .blue
            }
        }
    }

    private var filteredStints: [TyreStint] {
        if selectedCompound == .all {
            return stints
        }
        return stints.filter { stint in
            guard let compound = stint.compound?.uppercased() else { return false }
            switch selectedCompound {
            case .all: return true
            case .soft: return compound == "SOFT"
            case .medium: return compound == "MEDIUM"
            case .hard: return compound == "HARD"
            case .intermediate: return compound == "INTERMEDIATE"
            case .wet: return compound == "WET"
            }
        }
    }

    var body: some View {
        if stints.isEmpty {
            ContentUnavailableView("Nessun dato mescole disponibile", systemImage: "circle.hexagongrid")
        } else {
            VStack(spacing: 10) {
                DisclosureGroup(
                    isExpanded: $isCompoundPickerExpanded,
                    content: {
                        VStack(spacing: 4) {
                            Divider()
                                .overlay(Color.primary.opacity(0.15))
                                .padding(.vertical, 4)

                            ForEach(TyreCompoundFilter.allCases) { comp in
                                Button {
                                    selectedCompound = comp
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isCompoundPickerExpanded = false
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(comp.color)
                                            .frame(width: 12, height: 12)
                                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))

                                        Text(comp.rawValue)
                                            .font(.subheadline)
                                            .bold(selectedCompound == comp)
                                            .foregroundStyle(selectedCompound == comp ? .red : .primary)

                                        Spacer()

                                        if selectedCompound == comp {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .bold()
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    },
                    label: {
                        HStack(spacing: 10) {
                            Image(systemName: "circle.hexagongrid.fill")
                                .font(.title3)
                                .foregroundStyle(.red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Filtra Mescola")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(selectedCompound.rawValue)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }

                            Spacer()
                        }
                    }
                )
                .tint(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                if filteredStints.isEmpty {
                    ContentUnavailableView(
                        "Nessuno stint trovato",
                        systemImage: "circle.hexagongrid",
                        description: Text("Nessun pilota ha utilizzato la mescola selezionata.")
                    )
                    .padding(.top, 16)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredStints) { stint in
                            let driver = driverMap[stint.driverNumber]
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(stint.compoundColor)
                                    .frame(width: 16, height: 16)
                                    .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(driver?.fullName ?? "Pilota #\(stint.driverNumber)")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Stint \(stint.stintNumber ?? 1) • \(stint.compound ?? "Mescola N/D")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    if let start = stint.lapsStart, let end = stint.lapsEnd {
                                        Text("Giri \(start) - \(end)")
                                            .font(.caption)
                                            .bold()
                                    }
                                    if let age = stint.tyreAgeAtStart {
                                        Text("Giri gomma: \(age)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

private struct WeatherDetailCard: View {
    let weather: WeatherData?

    var body: some View {
        if let weather = weather {
            VStack(spacing: 14) {
                HStack {
                    WeatherMetricItem(title: "Temp. Aria", value: String(format: "%.1f °C", weather.airTemperature ?? 0), icon: "thermometer.medium")
                    Spacer()
                    WeatherMetricItem(title: "Temp. Pista", value: String(format: "%.1f °C", weather.trackTemperature ?? 0), icon: "road.lanes")
                }

                Divider()

                HStack {
                    WeatherMetricItem(title: "Umidità", value: String(format: "%.0f %%", weather.humidity ?? 0), icon: "humidity")
                    Spacer()
                    WeatherMetricItem(title: "Vento", value: String(format: "%.1f km/h", weather.windSpeed ?? 0), icon: "wind")
                }

                if let rain = weather.rainfall, rain > 0 {
                    HStack {
                        Image(systemName: "cloud.rain.fill")
                            .foregroundStyle(.blue)
                        Text("Pioggia segnalata in pista")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        } else {
            ContentUnavailableView("Dati meteo non disponibili", systemImage: "cloud.slash")
        }
    }
}

private struct WeatherMetricItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .bold()
            }
        }
    }
}

private struct RaceControlListView: View {
    let messages: [RaceControlMessage]

    @State private var selectedCategory: RaceControlFilterCategory = .all
    @State private var selectedLap: Int = 0
    @State private var isCategoryExpanded: Bool = false
    @State private var isLapPickerExpanded: Bool = false

    private enum RaceControlFilterCategory: String, CaseIterable, Identifiable {
        case all = "Tutti i Messaggi"
        case flags = "Bandiere"
        case penalties = "Penalità & Indagini"
        case safetyCar = "Safety Car / VSC"
        case drs = "DRS"

        var id: String { self.rawValue }

        var icon: String {
            switch self {
            case .all: return "list.bullet.rectangle"
            case .flags: return "flag.fill"
            case .penalties: return "exclamationmark.triangle.fill"
            case .safetyCar: return "car.side.fill"
            case .drs: return "bolt.fill"
            }
        }
    }

    private var availableLaps: [Int] {
        let laps = messages.compactMap { $0.lapNumber }
        let uniqueLaps = Array(Set(laps)).sorted()
        return uniqueLaps
    }

    private var filteredMessages: [RaceControlMessage] {
        messages.filter { msg in
            let messageText = (msg.message ?? "").lowercased()
            let categoryText = (msg.category ?? "").lowercased()

            let categoryMatch: Bool
            switch selectedCategory {
            case .all:
                categoryMatch = true
            case .flags:
                categoryMatch = msg.flag != nil || categoryText.contains("flag")
            case .penalties:
                categoryMatch = categoryText.contains("penalty") || messageText.contains("investigat") || messageText.contains("penalty") || messageText.contains("noted") || messageText.contains("offence") || messageText.contains("time penalty") || messageText.contains("reprimand")
            case .safetyCar:
                categoryMatch = categoryText.contains("safetycar") || messageText.contains("safety car") || messageText.contains("vsc") || messageText.contains("virtual safety car")
            case .drs:
                categoryMatch = categoryText.contains("drs") || messageText.contains("drs")
            }

            let lapMatch: Bool
            if selectedLap == 0 {
                lapMatch = true
            } else {
                lapMatch = (msg.lapNumber == selectedLap)
            }

            return categoryMatch && lapMatch
        }
    }

    var body: some View {
        if messages.isEmpty {
            ContentUnavailableView("Nessuna segnalazione della Direzione Gara", systemImage: "shield.slash")
        } else {
            VStack(spacing: 10) {
                DisclosureGroup(
                    isExpanded: $isCategoryExpanded,
                    content: {
                        VStack(spacing: 4) {
                            Divider()
                                .overlay(Color.primary.opacity(0.15))
                                .padding(.vertical, 4)

                            ForEach(RaceControlFilterCategory.allCases) { cat in
                                Button {
                                    selectedCategory = cat
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isCategoryExpanded = false
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: cat.icon)
                                            .foregroundStyle(selectedCategory == cat ? .red : .primary)
                                            .frame(width: 24)

                                        Text(cat.rawValue)
                                            .font(.subheadline)
                                            .bold(selectedCategory == cat)
                                            .foregroundStyle(selectedCategory == cat ? .red : .primary)

                                        Spacer()

                                        if selectedCategory == cat {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .bold()
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    },
                    label: {
                        HStack(spacing: 10) {
                            Image(systemName: selectedCategory.icon)
                                .font(.title3)
                                .foregroundStyle(.red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Filtra Categoria")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(selectedCategory.rawValue)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }

                            Spacer()
                        }
                    }
                )
                .tint(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                DisclosureGroup(
                    isExpanded: $isLapPickerExpanded,
                    content: {
                        VStack(spacing: 4) {
                            Divider()
                                .overlay(Color.primary.opacity(0.15))
                                .padding(.vertical, 4)

                            Picker("Giro", selection: $selectedLap) {
                                Text("Tutti i giri").tag(0)
                                ForEach(availableLaps, id: \.self) { lap in
                                    Text("Giro \(lap)").tag(lap)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)

                            Button("Conferma") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isLapPickerExpanded = false
                                }
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.red)
                            .padding(.vertical, 6)
                        }
                    },
                    label: {
                        HStack(spacing: 10) {
                            Image(systemName: "number.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Filtra Giro")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(selectedLap == 0 ? "Tutti i giri" : "Giro \(selectedLap)")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }

                            Spacer()
                        }
                    }
                )
                .tint(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                if filteredMessages.isEmpty {
                    ContentUnavailableView(
                        "Nessun messaggio trovato",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("Nessuna segnalazione corrisponde ai filtri impostati.")
                    )
                    .padding(.top, 16)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredMessages) { msg in
                            RaceControlRow(msg: msg)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

private struct RaceControlRow: View {
    let msg: RaceControlMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(msg.flagColor)
                .frame(width: 12, height: 12)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                if let lap = msg.lapNumber {
                    Text("Giro \(lap)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.secondary)
                }
                Text(msg.message ?? "Segnalazione")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}
