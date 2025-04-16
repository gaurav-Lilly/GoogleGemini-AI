//
//  GradientProgressView.swift
//  ChatGenAI
//
//  Created by Gaurav Sharma on 08/02/25.
//

import SwiftUI

struct GradientProgressView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1)
            .foregroundColor(.clear)
            .tint(Color.white)
    }
}

#Preview {
    GradientProgressView()
}
