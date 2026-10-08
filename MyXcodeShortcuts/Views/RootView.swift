//
//  RootView.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 5/6/24.
//

import SwiftUI

struct RootView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            if isActive {
                MainTabView()
            } else {
                SplashScreen()
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 1.0)) {
                isActive = true
            }
        }
    }
}

#Preview {
    RootView(isActive: .constant(true))
}
