//
//  Shortcut.swift
//  MyXcodeFaves
//
//  Created by Brent Michalski on 3/13/24.
//

import SwiftUI
import SwiftData

@Model
class Shortcut {
    var keyCombo: String = ""
    var details: String = ""
    var category: Category?
    var status: Status = Status.none
    /// Position among sibling shortcuts within the same `Category` - lets the user drag to
    /// reorder instead of always showing alphabetized by `details`.
    var order: Int = 0

    init(keyCombo: String, details: String, status: Status = Status.none, category: Category? = nil, order: Int = 0) {
        self.keyCombo = keyCombo.localizedLowercase
        self.details = details
        self.status = status
        self.order = order

        if let category = category {
            self.category = category
        }
    }

    func matchesStatus(_ currentStatusInt: Int) -> Bool {
        let currentStatus = Status(rawValue: currentStatusInt)
        
        switch currentStatus {
            case .none:
                // If the filter is set to .none, all shortcuts should be shown.
                return self.status != .hidden
            case .favorite:
                // If the filter is set to .favorite, only show favorites.
                return self.status == .favorite
            case .hidden:
                // "Showing Hidden" mode is for managing hidden items, so it
                // shows everything (including non-hidden shortcuts), not just
                // the hidden ones.
                return true
        }
    }

}

// TODO: This is a hack for importing the JSON at the moment
//  Caused by the @Model macro
class ShortcutX: Codable {
    enum CodingKeys: CodingKey {
        case keyCombo, details
    }
    
    var keyCombo: String = ""
    var details: String = ""
    weak var category: CategoryX?
    
    init(keyCombo: String, details: String, category: CategoryX? = nil) {
        self.keyCombo = keyCombo
        self.details = details
        
        if let category = category {
            self.category = category
        }
    }
    
    // Conform to Codable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        keyCombo = try values.decodeIfPresent(String.self, forKey: .keyCombo) ?? ""
        details = try values.decodeIfPresent(String.self, forKey: .details) ?? ""
    }
    
    // Conform to Codable
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCombo, forKey: .keyCombo)
    }
}
