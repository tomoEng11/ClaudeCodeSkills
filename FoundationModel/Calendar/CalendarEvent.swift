//
//  CalendarEvent.swift
//  FoundationModel
//

import Foundation

struct CalendarEvent: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var notes: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        notes: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
