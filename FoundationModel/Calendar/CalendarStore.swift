//
//  CalendarStore.swift
//  FoundationModel
//

import Foundation

@MainActor
@Observable
final class CalendarStore {
    // シングルトンパターン
    static let shared: CalendarStore = .init()

    // 全イベントのキャッシュ（Single Source of Truth）
    private(set) var events: [UUID: CalendarEvent] = [:]

    private init() {}

    // MARK: - Public Methods

    /// 指定した日付範囲のイベントをロード
    func loadEvents(from startDate: Date, to endDate: Date) async throws {
        let fetchedEvents = try await CalendarRepository.fetchEvents(from: startDate, to: endDate)

        // イベントをキャッシュに追加
        for event in fetchedEvents {
            events[event.id] = event
        }
    }

    /// 特定のイベントをロード
    func loadEvent(for id: UUID) async throws {
        if let event = try await CalendarRepository.fetchEvent(for: id) {
            events[event.id] = event
        } else {
            events.removeValue(forKey: id)
        }
    }

    /// 新しいイベントを作成
    func createEvent(_ event: CalendarEvent) async throws {
        try await CalendarRepository.createEvent(event)
        events[event.id] = event
    }

    /// イベントを更新
    func updateEvent(_ event: CalendarEvent) async throws {
        try await CalendarRepository.updateEvent(event)
        events[event.id] = event
    }

    /// イベントを削除
    func deleteEvent(id: UUID) async throws {
        try await CalendarRepository.deleteEvent(id: id)
        events.removeValue(forKey: id)
    }

    /// イベントの完了状態を更新
    func updateCompleted(_ isCompleted: Bool, for id: UUID) async throws {
        try await CalendarRepository.updateCompleted(isCompleted, for: id)
        events[id]?.isCompleted = isCompleted
    }
}
