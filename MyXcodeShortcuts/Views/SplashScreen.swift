//
//  SplashScreen.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/23/24.
//

import SwiftUI

struct SplashScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }
    
    var appBuild: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1.0"
    }
    
    var copyright: String {
        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
        return copyright ?? "Copyright © 2024 Brent D. Michalski.\nAll rights reserved."
    }

    @State private var isImageVisible = false
    @State private var imageOffset = CGFloat(20)
    @State private var isTextVisible = false
    
    var body: some View {
        VStack {
            // Grouping header texts
            VStack(spacing: 10) {
                Text("Welcome to")
                    .font(.largeTitle)
                Text("Shortcut Cheat Sheets")
                    .font(.largeTitle)
            }
            .multilineTextAlignment(.center)
            .opacity(isTextVisible ? 1 : 0)
            .offset(y: isTextVisible ? 0 : 20)
            .padding(.top, 100)  // Adjust padding as necessary

            // Image in the middle
            Image("AppIconTransparent")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .opacity(isImageVisible ? 1 : 0)
                .offset(y: imageOffset)
                .onAppear {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 1.5)) {
                        isImageVisible = true
                        imageOffset = 0
                    }
                    withAnimation(reduceMotion ? nil : Animation.easeOut(duration: 1.5).delay(0.5)) {
                        isTextVisible = true
                    }
                }

            // Footer texts
            VStack(spacing: 5) {
                Text("Version: \(appVersion)")
                Text("Build: \(appBuild)")
                Text(copyright)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            .font(.caption)
            .opacity(isTextVisible ? 1 : 0)
            .padding(.bottom, 50)  // Adjust padding as necessary
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BlurredBackground())
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreen()
}
