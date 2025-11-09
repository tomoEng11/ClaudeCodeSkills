//
//  ContentView.swift
//  FoundationModel
//
//  Created by 井本　智博 on 2025/11/09.
//

import SwiftUI

/// アプリのメインコンテンツビュー（タブバー）
struct ContentView: View {
    var body: some View {
        TabView {
            Tab {
                CalculatorView()
            } label: {
                Label("電卓", systemImage: "plus.forwardslash.minus")
            }
            Tab {
                CalendarView()
            } label: {
                Label("カレンダー", systemImage: "calendar")
            }
            
        }
    }
}

#Preview {
    ContentView()
}
