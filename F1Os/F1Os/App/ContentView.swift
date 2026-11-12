//
//  ContentView.swift
//  F1Os
//
//  Created by s12 on 30/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .standings

    enum TabItem: Hashable {
        case standings
        case meetings
        case drivers
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            StandingsView()
                .tabItem {
                    Label("Classifica", systemImage: "trophy.fill")
                }
                .tag(TabItem.standings)

            MeetingsView()
                .tabItem {
                    Label("Meetings", systemImage: "flag.checkered")
                }
                .tag(TabItem.meetings)

            DriversView()
                .tabItem {
                    Label("Piloti", systemImage: "person.2.fill")
                }
                .tag(TabItem.drivers)

            SettingsView()
                .tabItem {
                    Label("Impostazioni", systemImage: "gearshape.fill")
                }
                .tag(TabItem.settings)
        }
        .tint(.red)
    }
}

struct PreviewMockDriverStanding: Identifiable {
    let id = UUID()
    let position: Int
    let number: Int
    let fullName: String
    let acronym: String
    let teamName: String
    let teamColour: String
    let points: Int
}

struct PreviewMockTeamStanding: Identifiable {
    let id = UUID()
    let position: Int
    let teamName: String
    let teamColour: String
    let points: Int
}

enum PreviewMockData {
    static let drivers: [Driver] = [
        Driver(driverNumber: 1, broadcastName: "Max Verstappen", fullName: "Max Verstappen", firstName: "Max", lastName: "Verstappen", nameAcronym: "VER", teamName: "Red Bull Racing", teamColour: "3671C6", headshotUrl: nil, countryCode: "NED", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 16, broadcastName: "Charles Leclerc", fullName: "Charles Leclerc", firstName: "Charles", lastName: "Leclerc", nameAcronym: "LEC", teamName: "Ferrari", teamColour: "E8002D", headshotUrl: nil, countryCode: "MON", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 11, broadcastName: "Sergio Perez", fullName: "Sergio Perez", firstName: "Sergio", lastName: "Perez", nameAcronym: "PER", teamName: "Red Bull Racing", teamColour: "3671C6", headshotUrl: nil, countryCode: "MEX", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 55, broadcastName: "Carlos Sainz", fullName: "Carlos Sainz", firstName: "Carlos", lastName: "Sainz", nameAcronym: "SAI", teamName: "Ferrari", teamColour: "E8002D", headshotUrl: nil, countryCode: "ESP", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 4, broadcastName: "Lando Norris", fullName: "Lando Norris", firstName: "Lando", lastName: "Norris", nameAcronym: "NOR", teamName: "McLaren", teamColour: "FF8000", headshotUrl: nil, countryCode: "GBR", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 81, broadcastName: "Oscar Piastri", fullName: "Oscar Piastri", firstName: "Oscar", lastName: "Piastri", nameAcronym: "PIA", teamName: "McLaren", teamColour: "FF8000", headshotUrl: nil, countryCode: "AUS", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 44, broadcastName: "Lewis Hamilton", fullName: "Lewis Hamilton", firstName: "Lewis", lastName: "Hamilton", nameAcronym: "HAM", teamName: "Mercedes", teamColour: "27F4D2", headshotUrl: nil, countryCode: "GBR", meetingKey: nil, sessionKey: nil),
        Driver(driverNumber: 63, broadcastName: "George Russell", fullName: "George Russell", firstName: "George", lastName: "Russell", nameAcronym: "RUS", teamName: "Mercedes", teamColour: "27F4D2", headshotUrl: nil, countryCode: "GBR", meetingKey: nil, sessionKey: nil)
    ]

    static let meetings: [Meeting] = [
        Meeting(meetingKey: 1229, meetingName: "Bahrain Grand Prix", meetingOfficialName: "Formula 1 Gulf Air Bahrain Grand Prix 2026", location: "Sakhir", countryName: "Bahrain", countryCode: "BAH", circuitShortName: "Sakhir", dateStart: "2026-03-01T00:00:00+00:00", year: 2026),
        Meeting(meetingKey: 1230, meetingName: "Saudi Arabian Grand Prix", meetingOfficialName: "Formula 1 STC Saudi Arabian Grand Prix 2026", location: "Jeddah", countryName: "Saudi Arabia", countryCode: "KSA", circuitShortName: "Jeddah", dateStart: "2026-03-08T00:00:00+00:00", year: 2026),
        Meeting(meetingKey: 1231, meetingName: "Australian Grand Prix", meetingOfficialName: "Formula 1 Rolex Australian Grand Prix 2026", location: "Melbourne", countryName: "Australia", countryCode: "AUS", circuitShortName: "Albert Park", dateStart: "2026-03-22T00:00:00+00:00", year: 2026),
        Meeting(meetingKey: 1232, meetingName: "Japanese Grand Prix", meetingOfficialName: "Formula 1 MSC Cruises Japanese Grand Prix 2026", location: "Suzuka", countryName: "Japan", countryCode: "JPN", circuitShortName: "Suzuka", dateStart: "2026-04-05T00:00:00+00:00", year: 2026),
        Meeting(meetingKey: 1233, meetingName: "Chinese Grand Prix", meetingOfficialName: "Formula 1 Lenovo Chinese Grand Prix 2026", location: "Shanghai", countryName: "China", countryCode: "CHN", circuitShortName: "Shanghai", dateStart: "2026-04-19T00:00:00+00:00", year: 2026)
    ]

    static let driverStandings: [PreviewMockDriverStanding] = [
        PreviewMockDriverStanding(position: 1, number: 1, fullName: "Max Verstappen", acronym: "VER", teamName: "Red Bull Racing", teamColour: "3671C6", points: 57),
        PreviewMockDriverStanding(position: 2, number: 16, fullName: "Charles Leclerc", acronym: "LEC", teamName: "Ferrari", teamColour: "E8002D", points: 36),
        PreviewMockDriverStanding(position: 3, number: 11, fullName: "Sergio Perez", acronym: "PER", teamName: "Red Bull Racing", teamColour: "3671C6", points: 30),
        PreviewMockDriverStanding(position: 4, number: 55, fullName: "Carlos Sainz", acronym: "SAI", teamName: "Ferrari", teamColour: "E8002D", points: 27),
        PreviewMockDriverStanding(position: 5, number: 4, fullName: "Lando Norris", acronym: "NOR", teamName: "McLaren", teamColour: "FF8000", points: 24),
        PreviewMockDriverStanding(position: 6, number: 81, fullName: "Oscar Piastri", acronym: "PIA", teamName: "McLaren", teamColour: "FF8000", points: 18),
        PreviewMockDriverStanding(position: 7, number: 63, fullName: "George Russell", acronym: "RUS", teamName: "Mercedes", teamColour: "27F4D2", points: 14),
        PreviewMockDriverStanding(position: 8, number: 44, fullName: "Lewis Hamilton", acronym: "HAM", teamName: "Mercedes", teamColour: "27F4D2", points: 12)
    ]

    static let teamStandings: [PreviewMockTeamStanding] = [
        PreviewMockTeamStanding(position: 1, teamName: "Red Bull Racing", teamColour: "3671C6", points: 87),
        PreviewMockTeamStanding(position: 2, teamName: "Ferrari", teamColour: "E8002D", points: 63),
        PreviewMockTeamStanding(position: 3, teamName: "McLaren", teamColour: "FF8000", points: 42),
        PreviewMockTeamStanding(position: 4, teamName: "Mercedes", teamColour: "27F4D2", points: 26)
    ]
}

struct MockStandingsTabPreview: View {
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Tipo Classifica", selection: $selectedSegment) {
                        Text("Piloti").tag(0)
                        Text("Costruttori").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if selectedSegment == 0 {
                                ForEach(PreviewMockData.driverStandings) { item in
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(item.position <= 3 ? Color.yellow.opacity(0.2) : Color(.tertiaryLabel).opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            Text("P\(item.position)")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(item.position <= 3 ? .orange : .primary)
                                        }

                                        Rectangle()
                                            .fill(Color(hex: item.teamColour))
                                            .frame(width: 5, height: 38)
                                            .cornerRadius(2.5)

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(item.fullName)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)

                                                Text(item.acronym)
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundStyle(.secondary)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(4)
                                            }

                                            Text(item.teamName)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Text("\(item.points) PTS")
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
                                }
                            } else {
                                ForEach(PreviewMockData.teamStandings) { item in
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(item.position <= 3 ? Color.yellow.opacity(0.2) : Color(.tertiaryLabel).opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            Text("P\(item.position)")
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(item.position <= 3 ? .orange : .primary)
                                        }

                                        Rectangle()
                                            .fill(Color(hex: item.teamColour))
                                            .frame(width: 5, height: 38)
                                            .cornerRadius(2.5)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.teamName)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                        }

                                        Spacer()

                                        Text("\(item.points) PTS")
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
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Classifiche F1")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text("2026").bold()
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
    }
}

struct MockMeetingsTabPreview: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(PreviewMockData.meetings, id: \.meetingKey) { meeting in
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(meeting.meetingName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text("\(meeting.location ?? ""), \(meeting.countryName ?? "")")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text(meeting.circuitShortName ?? "")
                                        .font(.caption)
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.15))
                                        .foregroundStyle(.red)
                                        .cornerRadius(6)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .bold()
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Calendario F1")
            .searchable(text: $searchText, prompt: "Cerca GP, circuito o paese...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text("2026").bold()
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
    }
}

struct MockDriversTabPreview: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(PreviewMockData.drivers, id: \.driverNumber) { driver in
                            HStack(spacing: 16) {
                                Rectangle()
                                    .fill(Color(hex: driver.teamColour ?? "000000"))
                                    .frame(width: 6, height: 50)
                                    .cornerRadius(3)

                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.12))
                                        .frame(width: 50, height: 50)

                                    Text(driver.nameAcronym ?? "F1")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(.red)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(driver.fullName ?? "Pilota")
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

                                    Text(driver.teamName ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("#\(driver.driverNumber)")
                                    .font(.title2)
                                    .bold()
                                    .italic()
                                    .foregroundStyle(Color(hex: driver.teamColour ?? "000000"))

                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .bold()
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Piloti F1")
            .searchable(text: $searchText, prompt: "Cerca pilota...")
        }
    }
}

struct MockAppTabView: View {
    @State private var selectedTab: ContentView.TabItem = .standings

    var body: some View {
        TabView(selection: $selectedTab) {
            MockStandingsTabPreview()
                .tabItem {
                    Label("Classifica", systemImage: "trophy.fill")
                }
                .tag(ContentView.TabItem.standings)

            MockMeetingsTabPreview()
                .tabItem {
                    Label("Meetings", systemImage: "flag.checkered")
                }
                .tag(ContentView.TabItem.meetings)

            MockDriversTabPreview()
                .tabItem {
                    Label("Piloti", systemImage: "person.2.fill")
                }
                .tag(ContentView.TabItem.drivers)

            SettingsView()
                .tabItem {
                    Label("Impostazioni", systemImage: "gearshape.fill")
                }
                .tag(ContentView.TabItem.settings)
        }
        .tint(.red)
    }
}

#Preview("App Root - Preview Dati Mock (Light Mode)") {
    MockAppTabView()
}

#Preview("App Root - Preview Dati Mock (Dark Mode)") {
    MockAppTabView()
        .preferredColorScheme(.dark)
}

#Preview("Scheda Classifica (Mock)") {
    MockStandingsTabPreview()
}

#Preview("Scheda Meetings (Mock)") {
    MockMeetingsTabPreview()
}

#Preview("Scheda Piloti (Mock)") {
    MockDriversTabPreview()
}

#Preview("Dettaglio Pilota (Mock)") {
    DriverDetailView(
        driver: PreviewMockData.drivers[0],
        showPastPerformance: true,
        pastPerformances: [
            PastRacePerformance(raceName: "GP Bahrain", gridPosition: 1, finishPosition: 1, points: 26.0),
            PastRacePerformance(raceName: "GP Arabia Saudita", gridPosition: 1, finishPosition: 1, points: 25.0),
            PastRacePerformance(raceName: "GP Australia", gridPosition: 2, finishPosition: 1, points: 25.0)
        ]
    )
}
