//
//  CalendarView.swift
//  FoundationModel
//

import SwiftUI

struct CalendarView: View {
    @State private var state = CalendarViewState()

    private let calendar = Calendar.current
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月の選択ヘッダー
                monthHeader

                Divider()

                // 曜日ヘッダー
                weekdayHeader

                // カレンダーグリッド
                calendarGrid

                Divider()
                    .padding(.top)

                // 選択された日付のイベントリスト
                eventsList
            }
            .navigationTitle("カレンダー")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: イベント作成画面へ
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await state.onAppear()
            }
        }
    }

    // MARK: - View Components

    private var monthHeader: some View {
        HStack {
            Button {
                state.moveToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            Text(monthYearText)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                state.moveToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .padding()
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(state.daysInMonth) { dayData in
                DayCell(
                    dayData: dayData,
                    isSelected: isSelected(dayData.date),
                    onTap: {
                        state.selectDate(dayData.date)
                    }
                )
            }
        }
        .padding(.horizontal)
    }

    private var eventsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let selectedDate = state.selectedDate {
                // ヘッダー
                HStack {
                    Text(formatDate(selectedDate))
                        .font(.headline)

                    Spacer()

                    Toggle("未完了のみ", isOn: $state.showsOnlyIncomplete)
                        .font(.caption)
                }
                .padding()

                // イベントリスト
                if state.eventsForSelectedDate.isEmpty {
                    VStack {
                        Text("イベントがありません")
                            .foregroundStyle(.secondary)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(state.eventsForSelectedDate) { event in
                            EventRow(
                                event: event,
                                onToggleCompletion: {
                                    Task {
                                        await state.toggleEventCompletion(for: event.id)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await state.deleteEvent(id: event.id)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            } else {
                VStack {
                    Text("日付を選択してください")
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                }
            }
        }
    }

    // MARK: - Helper Methods

    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: state.currentMonth)
    }

    private func isSelected(_ date: Date?) -> Bool {
        guard let date, let selectedDate = state.selectedDate else {
            return false
        }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let dayData: DayData
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let date = dayData.date {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 16))
                        .fontWeight(dayData.isToday ? .bold : .regular)
                        .foregroundStyle(isSelected ? .white : (dayData.isToday ? .blue : .primary))

                    // イベントインジケーター
                    if dayData.hasEvents {
                        Circle()
                            .fill(isSelected ? .white : .blue)
                            .frame(width: 4, height: 4)
                    } else {
                        Spacer()
                            .frame(height: 4)
                    }
                } else {
                    Text("")
                        .frame(height: 4)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(dayData.isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(dayData.date == nil)
    }
}

// MARK: - Event Row

struct EventRow: View {
    let event: CalendarEvent
    let onToggleCompletion: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 完了チェックボックス
            Button {
                onToggleCompletion()
            } label: {
                Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(event.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .strikethrough(event.isCompleted)
                    .foregroundStyle(event.isCompleted ? .secondary : .primary)

                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(formatTime(event.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
}
