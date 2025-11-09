//
//  CalculatorView.swift
//  FoundationModel
//

import SwiftUI

/// 電卓のメインView
struct CalculatorView: View {
    @State private var viewState = CalculatorViewState()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Spacer()

                // ディスプレイ部分
                CalculatorDisplayView(
                    expressionText: viewState.expressionText,
                    resultText: viewState.displayText
                )
                .padding(.horizontal)
                .padding(.bottom, 20)

                // ボタングリッド
                CalculatorButtonGrid(
                    onButtonTap: { viewState.handleButtonTap($0) },
                    buttonSize: calculateButtonSize(geometry: geometry)
                )
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }

    private func calculateButtonSize(geometry: GeometryProxy) -> CGFloat {
        let spacing: CGFloat = 12
        let horizontalPadding: CGFloat = 32
        let availableWidth = geometry.size.width - horizontalPadding - (spacing * 3)
        return availableWidth / 4
    }
}

/// ディスプレイビュー
private struct CalculatorDisplayView: View {
    let expressionText: String
    let resultText: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 計算式を表示
            if !expressionText.isEmpty {
                Text(expressionText)
                    .font(.system(size: 30, weight: .regular, design: .default))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // 結果を表示
            Text(resultText)
                .font(.system(size: 80, weight: .light, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(minHeight: 120)
    }
}

/// ボタングリッド
private struct CalculatorButtonGrid: View {
    let onButtonTap: (CalculatorButtonType) -> Void
    let buttonSize: CGFloat

    var body: some View {
        VStack(spacing: 12) {
            // 1行目: AC, ±, %, ÷
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "AC",
                    type: .clear,
                    buttonSize: buttonSize,
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "±",
                    type: .toggleSign,
                    buttonSize: buttonSize,
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "%",
                    type: .percent,
                    buttonSize: buttonSize,
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "÷",
                    type: .operation(.divide),
                    buttonSize: buttonSize,
                    backgroundColor: .orange,
                    onTap: onButtonTap
                )
            }

            // 2行目: 7, 8, 9, ×
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "7",
                    type: .digit("7"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "8",
                    type: .digit("8"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "9",
                    type: .digit("9"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "×",
                    type: .operation(.multiply),
                    buttonSize: buttonSize,
                    backgroundColor: .orange,
                    onTap: onButtonTap
                )
            }

            // 3行目: 4, 5, 6, −
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "4",
                    type: .digit("4"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "5",
                    type: .digit("5"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "6",
                    type: .digit("6"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "−",
                    type: .operation(.subtract),
                    buttonSize: buttonSize,
                    backgroundColor: .orange,
                    onTap: onButtonTap
                )
            }

            // 4行目: 1, 2, 3, +
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "1",
                    type: .digit("1"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "2",
                    type: .digit("2"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "3",
                    type: .digit("3"),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "+",
                    type: .operation(.add),
                    buttonSize: buttonSize,
                    backgroundColor: .orange,
                    onTap: onButtonTap
                )
            }

            // 5行目: 0, ., =
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "0",
                    type: .digit("0"),
                    buttonSize: buttonSize * 2 + 12,
                    backgroundColor: Color(white: 0.2),
                    isWide: true,
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: ".",
                    type: .digit("."),
                    buttonSize: buttonSize,
                    backgroundColor: Color(white: 0.2),
                    onTap: onButtonTap
                )
                CalculatorButton(
                    title: "=",
                    type: .equals,
                    buttonSize: buttonSize,
                    backgroundColor: .orange,
                    onTap: onButtonTap
                )
            }
        }
    }
}

/// 電卓ボタン
private struct CalculatorButton: View {
    let title: String
    let type: CalculatorButtonType
    let buttonSize: CGFloat
    var backgroundColor: Color = Color(white: 0.3)
    var isWide: Bool = false
    let onTap: (CalculatorButtonType) -> Void

    private var buttonHeight: CGFloat {
        isWide ? (buttonSize - 12) / 2 : buttonSize
    }

    var body: some View {
        Button {
            onTap(type)
        } label: {
            Text(title)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: buttonSize, height: buttonHeight)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    CalculatorView()
}
