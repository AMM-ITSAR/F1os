//
//  PositionDeltaBadge.swift
//  F1Os
//
//  Created by s12 on 06/11/26.
//

import SwiftUI

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
