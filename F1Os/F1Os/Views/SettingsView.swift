//
//  SettingsView.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ContentUnavailableView(
                        "Sezione in Arrivo",
                        systemImage: "gearshape.2.fill",
                        description: Text("Le opzioni di personalizzazione, preferenze notifiche e unità di misura saranno disponibili nei prossimi aggiornamenti.")
                    )
                }
            }
            .navigationTitle("Impostazioni")
        }
    }
}
