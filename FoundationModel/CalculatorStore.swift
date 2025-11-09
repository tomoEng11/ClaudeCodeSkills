//
//  CalculatorStore.swift
//  FoundationModel
//
//  Created by Claude Code
//

import Foundation

/// 電卓の演算子
enum CalculatorOperation: String {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case none = ""
}

/// 電卓のビジネスロジックを担当するStore
@MainActor
final class CalculatorStore {

    // MARK: - Private Properties

    private var currentValue: Double = 0
    private var previousValue: Double = 0
    private var currentOperation: CalculatorOperation = .none
    private var isNewInput: Bool = true
    private var expressionString: String = ""

    // MARK: - Public Methods

    /// 現在の計算式を取得
    func getExpression() -> String {
        return expressionString
    }

    /// 数字入力を処理
    func inputNumber(_ number: String, currentDisplay: String) -> String {
        if isNewInput {
            isNewInput = false
            return number == "." ? "0." : number
        }

        // 小数点の重複チェック
        if number == "." && currentDisplay.contains(".") {
            return currentDisplay
        }

        // 0の重複を防ぐ
        if currentDisplay == "0" && number != "." {
            return number
        }

        return currentDisplay + number
    }

    /// 演算子入力を処理
    func inputOperation(_ operation: CalculatorOperation, currentDisplay: String) -> String {
        let displayValue = Double(currentDisplay) ?? 0

        // 前の演算がある場合は計算を実行
        if !isNewInput && currentOperation != .none {
            let result = performCalculation(previousValue, displayValue, currentOperation)
            previousValue = result
            currentValue = result
            currentOperation = operation
            isNewInput = true
            expressionString = formatResult(result) + " " + operation.rawValue
            return formatResult(result)
        }

        previousValue = displayValue
        currentValue = displayValue
        currentOperation = operation
        isNewInput = true
        expressionString = currentDisplay + " " + operation.rawValue

        return currentDisplay
    }

    /// 等号(=)を処理
    func inputEquals(currentDisplay: String) -> String {
        let displayValue = Double(currentDisplay) ?? 0

        if currentOperation == .none {
            expressionString = ""
            return currentDisplay
        }

        let result = performCalculation(previousValue, displayValue, currentOperation)
        expressionString = expressionString + " " + currentDisplay
        currentValue = result
        previousValue = 0
        currentOperation = .none
        isNewInput = true

        return formatResult(result)
    }

    /// クリア(AC)を処理
    func clear() -> String {
        currentValue = 0
        previousValue = 0
        currentOperation = .none
        isNewInput = true
        expressionString = ""
        return "0"
    }

    /// 符号反転(±)を処理
    func toggleSign(currentDisplay: String) -> String {
        guard var value = Double(currentDisplay), value != 0 else {
            return currentDisplay
        }

        value *= -1
        return formatResult(value)
    }

    /// パーセント(%)を処理
    func percent(currentDisplay: String) -> String {
        guard let value = Double(currentDisplay) else {
            return currentDisplay
        }

        let result = value / 100
        return formatResult(result)
    }

    // MARK: - Private Methods

    private func performCalculation(_ left: Double, _ right: Double, _ operation: CalculatorOperation) -> Double {
        switch operation {
        case .add:
            return left + right
        case .subtract:
            return left - right
        case .multiply:
            return left * right
        case .divide:
            return right != 0 ? left / right : 0
        case .none:
            return right
        }
    }

    private func formatResult(_ value: Double) -> String {
        // 整数の場合は小数点を表示しない
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }

        // 小数の場合は不要な0を削除
        let formatted = String(format: "%.8f", value)
        let trimmed = formatted.replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        return trimmed
    }
}
