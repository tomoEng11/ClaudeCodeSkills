//
//  CalendarViewState.swift
//  FoundationModel
//

import Foundation

@MainActor
@Observable
final class CalendarViewState {
    // UI表示用の派生状態
    private(set) var currentMonth: Date
    private(set) var daysInMonth: [DayData] = []
    private(set) var eventsForSelectedDate: [CalendarEvent] = []
    private(set) var isLoading: Bool = false
    private(set) var selectedDate: Date?

    // ユーザー入力の状態
    var showsOnlyIncomplete: Bool = false {
        didSet {
            updateEventsForSelectedDate()
        }
    }

    private let store: CalendarStore
    private var observationTask: Task<Void, Never>?
    private let calendar = Calendar.current

    init(store: CalendarStore = .shared) {
        self.currentMonth = Date()
        self.store = store

        // 初期化時に当月のデータを準備
        updateDaysInMonth()

        // Storeの状態変更を継続的に監視
        startObservingStore()
    }

    isolated deinit {
        observationTask?.cancel()
    }

    // MARK: - Public Methods

    func onAppear() async {
        await loadCurrentMonth()
    }

    func selectDate(_ date: Date?) {
        selectedDate = date
        updateEventsForSelectedDate()
    }

    func moveToNextMonth() {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else {
            return
        }
        currentMonth = nextMonth
        updateDaysInMonth()
        Task {
            await loadCurrentMonth()
        }
    }

    func moveToPreviousMonth() {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else {
            return
        }
        currentMonth = previousMonth
        updateDaysInMonth()
        Task {
            await loadCurrentMonth()
        }
    }

    func toggleEventCompletion(for eventId: UUID) async {
        guard let event = store.events[eventId] else { return }

        // 楽観的更新
        let newIsCompleted = !event.isCompleted
        optimisticallyUpdateEventCompletion(for: eventId, to: newIsCompleted)

        do {
            try await store.updateCompleted(newIsCompleted, for: eventId)
        } catch {
            print("Failed to update event completion: \(error)")
            updateEventsForSelectedDate()
        }
    }

    func deleteEvent(id: UUID) async {
        do {
            try await store.deleteEvent(id: id)
            updateEventsForSelectedDate()
        } catch {
            print("Failed to delete event: \(error)")
        }
    }

    // MARK: - Private Methods

    private func loadCurrentMonth() async {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await store.loadEvents(from: startOfMonth, to: endOfMonth)
            updateDaysInMonth()
            updateEventsForSelectedDate()
        } catch {
            print("Failed to load events: \(error)")
        }
    }

    private func updateDaysInMonth() {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            daysInMonth = []
            return
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let numberOfDays = range.count

        var days: [DayData] = []

        // 前月の空白
        for _ in 1..<firstWeekday {
            days.append(DayData(date: nil, events: []))
        }

        // 当月の日付
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let eventsForDay = getEvents(for: date)
                days.append(DayData(date: date, events: eventsForDay))
            }
        }

        daysInMonth = days
    }

    private func getEvents(for date: Date) -> [CalendarEvent] {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        return store.events.values.filter { event in
            event.date >= startOfDay && event.date < endOfDay
        }.sorted { $0.date < $1.date }
    }

    private func updateEventsForSelectedDate() {
        guard let selectedDate else {
            eventsForSelectedDate = []
            return
        }

        let events = getEvents(for: selectedDate)

        eventsForSelectedDate = events.filter { event in
            !showsOnlyIncomplete || !event.isCompleted
        }
    }

    private func optimisticallyUpdateEventCompletion(for eventId: UUID, to isCompleted: Bool) {
        if let index = eventsForSelectedDate.firstIndex(where: { $0.id == eventId }) {
            var updatedEvent = eventsForSelectedDate[index]
            updatedEvent.isCompleted = isCompleted
            eventsForSelectedDate[index] = updatedEvent
        }
    }

    /// Storeの状態変更を継続的に監視
    private func startObservingStore() {
        observationTask = Task { @MainActor in
            while !Task.isCancelled {
                _ = withObservationTracking {
                    // Storeの変更を監視
                    _ = store.events
                } onChange: {
                    Task { @MainActor in
                        self.updateDaysInMonth()
                        self.updateEventsForSelectedDate()
                    }
                }

                // 短い待機
                try? await Task.sleep(nanoseconds: 10_000_000) // 0.01秒
            }
        }
    }
}

// MARK: - Supporting Types

struct DayData: Identifiable {
    let id = UUID()
    let date: Date?
    let events: [CalendarEvent]

    var isToday: Bool {
        guard let date else { return false }
        return Calendar.current.isDateInToday(date)
    }

    var hasEvents: Bool {
        !events.isEmpty
    }
}
