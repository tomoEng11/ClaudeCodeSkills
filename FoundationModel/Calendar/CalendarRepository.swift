//
//  CalendarRepository.swift
//  FoundationModel
//

import Foundation

enum CalendarRepository {
    /// 指定した日付範囲のイベントを取得
    static func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        return await Backend.shared.getEvents(from: startDate, to: endDate)
    }

    /// 特定のイベントを取得
    static func fetchEvent(for id: UUID) async throws -> CalendarEvent? {
        try await Task.sleep(nanoseconds: 50_000_000)
        return await Backend.shared.getEvent(for: id)
    }

    /// イベントを作成
    static func createEvent(_ event: CalendarEvent) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        await Backend.shared.createEvent(event)
    }

    /// イベントを更新
    static func updateEvent(_ event: CalendarEvent) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        await Backend.shared.updateEvent(event)
    }

    /// イベントを削除
    static func deleteEvent(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        await Backend.shared.deleteEvent(id: id)
    }

    /// イベントの完了状態を更新
    static func updateCompleted(_ isCompleted: Bool, for id: UUID) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        await Backend.shared.updateCompleted(isCompleted, for: id)
    }

    // MARK: - Backend Simulation

    private actor Backend {
        static let shared = Backend()
        private var storage: [UUID: CalendarEvent] = [:]

        init() {
            // サンプルデータを追加
            let calendar = Calendar.current
            let today = Date()

            let sampleEvents = [
                CalendarEvent(
                    title: "チーム会議",
                    date: calendar.date(byAdding: .day, value: 0, to: today)!,
                    notes: "週次進捗確認"
                ),
                CalendarEvent(
                    title: "プロジェクトレビュー",
                    date: calendar.date(byAdding: .day, value: 2, to: today)!,
                    notes: "Q4成果物の確認"
                ),
                CalendarEvent(
                    title: "デザインミーティング",
                    date: calendar.date(byAdding: .day, value: 5, to: today)!,
                    notes: "新機能のUI/UX検討",
                    isCompleted: true
                )
            ]

            for event in sampleEvents {
                storage[event.id] = event
            }
        }

        func getEvents(from startDate: Date, to endDate: Date) -> [CalendarEvent] {
            storage.values.filter { event in
                event.date >= startDate && event.date <= endDate
            }.sorted { $0.date < $1.date }
        }

        func getEvent(for id: UUID) -> CalendarEvent? {
            storage[id]
        }

        func createEvent(_ event: CalendarEvent) {
            storage[event.id] = event
        }

        func updateEvent(_ event: CalendarEvent) {
            storage[event.id] = event
        }

        func deleteEvent(id: UUID) {
            storage.removeValue(forKey: id)
        }

        func updateCompleted(_ isCompleted: Bool, for id: UUID) {
            storage[id]?.isCompleted = isCompleted
        }
    }
}
