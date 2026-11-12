//
//  MeetingsView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct MeetingsView: View {
    @StateObject private var viewModel = MeetingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Caricamento Meetings...")
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
                                await viewModel.loadMeetings()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if viewModel.filteredMeetings.isEmpty {
                    ContentUnavailableView(
                        "Nessun Gran Premio trovato",
                        systemImage: "flag.slash",
                        description: Text("Nessun meeting corrisponde alla ricerca per il \(String(viewModel.selectedYear)).")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredMeetings) { meeting in
                                NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                                    MeetingCardRowContent(meeting: meeting)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Calendario F1")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Cerca GP, circuito o paese...")
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
                if viewModel.meetings.isEmpty {
                    await viewModel.loadMeetings()
                }
            }
            .onChange(of: viewModel.selectedYear) { _, _ in
                Task {
                    await viewModel.loadMeetings()
                }
            }
        }
    }
}

private struct MeetingCardRowContent: View {
    let meeting: Meeting

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.meetingName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Text("\(meeting.location ?? "N/D"), \(meeting.countryName ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(meeting.circuitShortName ?? "Circuito")
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
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}
