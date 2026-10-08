//
//  Route.swift
//  MyXcodeShortcuts
//
//  Typed navigation destinations, registered separately via navigationDestination(for: Route.self)
//  on each tab's own NavigationStack (Shortcuts tab handles .categorySelection/.pdfPreview, Settings
//  tab handles .help). Lets every push in the app go through NavigationLink(value:), instead of
//  mixing that with NavigationLink(destination:) pushes and magic-string routes, which Apple
//  explicitly warns causes real problems when combined in one navigation hierarchy.
//

import Foundation

enum Route: Hashable {
    case categorySelection(Shortcut)
    case pdfPreview(Data)
    case help
}
