//
//  BackgroundBlob.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 5/6/24.
//

import SwiftUI

protocol SelfCreatingView: View {
    init()
}

struct BackgroundBlob: View {
    @State private var rotationAmount = 0.0
    let alignment: Alignment = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing].randomElement()!
    let color: Color = [.appBaseBlue, .orange, .yellow].randomElement()!
    
    var body: some View {
        Ellipse()
            .fill(color)
            .frame(width: .random(in: 200...500), height: .random(in: 200...500))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .offset(x: .random(in: -400...400), y: .random(in: -400...400))
            .rotationEffect(.degrees(rotationAmount))
            .motionAnimation(.linear(duration: .random(in: 10...20)).repeatForever(), value: rotationAmount)
            .onAppear {
                rotationAmount = .random(in: -360...360)
            }
            .blur(radius: 75.0)
    }
}


//#Preview {
//    SplashScreen()
//}


struct BlurredBackground: SelfCreatingView {
    var body: some View {
        ZStack {
            ForEach(0..<15) { _ in
                BackgroundBlob()
            }
        }
        .background(.appBaseBlue)
    }
}


