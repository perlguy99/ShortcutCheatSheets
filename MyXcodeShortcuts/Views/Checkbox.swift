//
//  Checkbox.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/1/24.
//

import SwiftUI

struct Checkbox: View {
    @Binding var state: Status
    
    var body: some View {
        Button(accessibilityLabel, systemImage: symbolName, action: buttonTap)
            .labelStyle(.iconOnly)
            .buttonStyle(RoundedRectButtonStyle(checkboxState: state))
    }

    private var symbolName: String {
        switch state {
        case .none: "star"
        case .favorite: "star.fill"
        case .hidden: "eye.slash"
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .none: "Mark as favorite"
        case .favorite: "Remove from favorites"
        case .hidden: "Hidden"
        }
    }

    // Tap only toggles favorite on/off. Hiding (and un-hiding) happens via the
    // swipe action instead, so a stray tap can never make a row silently vanish -
    // including on an already-hidden row, where a tap must stay a no-op rather
    // than un-hiding it as a side effect of favoriting.
    func buttonTap() {
        switch state {
        case .favorite:
            state = .none
        case .none:
            state = .favorite
        case .hidden:
            break
        }
    }
}

private struct CheckboxPreviewRow: View {
    @State var favorite: Status = .favorite
    @State var hidden: Status = .hidden
    @State var none: Status = .none

    var body: some View {
        VStack {
            Checkbox(state: $none)
            Checkbox(state: $favorite)
            Checkbox(state: $hidden)
        }
    }
}

#Preview {
    CheckboxPreviewRow()
}

#Preview {
    CheckboxPreviewRow()
        .preferredColorScheme(.dark)
}

