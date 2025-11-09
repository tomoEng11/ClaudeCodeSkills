//
//  CalculatorViewState.swift
//  FoundationModel
//
//  Created by Claude Code
//

import Foundation

/// 電卓のボタンタイプ
enum CalculatorButtonType {
    case digit(String)
    case operation(CalculatorOperation)
    case equals
    case clear
    case toggleSign
    case percent
}

/// 電卓Viewの状態を管理するViewState
@Observable
@MainActor
final class CalculatorViewState {

    // MARK: - Public Properties

    private(set) var displayText: String = "0"
    private(set) var expressionText: String = ""

    // MARK: - Private Properties

    private let store: CalculatorStore

    // MARK: - Initialization

    nonisolated init(store: CalculatorStore) {
        self.store = store
    }

    convenience init() {
        self.init(store: CalculatorStore())
    }

    // MARK: - Public Methods

    /// ボタンタップを処理
    func handleButtonTap(_ buttonType: CalculatorButtonType) {
        switch buttonType {
        case .digit(let digit):
            displayText = store.inputNumber(digit, currentDisplay: displayText)
            expressionText = store.getExpression()

        case .operation(let operation):
            displayText = store.inputOperation(operation, currentDisplay: displayText)
            expressionText = store.getExpression()

        case .equals:
            displayText = store.inputEquals(currentDisplay: displayText)
            expressionText = store.getExpression()

        case .clear:
            displayText = store.clear()
            expressionText = ""

        case .toggleSign:
            displayText = store.toggleSign(currentDisplay: displayText)
            expressionText = store.getExpression()

        case .percent:
            displayText = store.percent(currentDisplay: displayText)
            expressionText = store.getExpression()
        }
    }
}
