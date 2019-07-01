//
//  LinesView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

private let cellSpacing: Length = 10

struct LinesView: View {
    var game: State<Lines>

    init(size: Int, rules: Lines.Rules) {
        self.game = State(initialValue: Lines(size: size, rules: rules))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {

            Text("Score \(self.game.value.score)")

            Circle()
                .foregroundColor(game.value.nextColorToPut.color)
                .frame(width: 50, height: 50, alignment: .center)

            BoardView(size: self.game.value.size) { row, column in
                CellView(cell: self.game.value[Lines.LineIndex(row: row, column: column)]) {
                    self.game.value.put(at: Lines.LineIndex(row: row, column: column))
                }
            }
                .aspectRatio(contentMode: .fit)
                .padding(cellSpacing)

            Button(action: { self.game.value.replay() },
                   label: { Text("Replay") })
        }
    }
}

private struct BoardView: View {
    let size: Int
    let createCellHandler: (Int, Int) -> CellView
    init(size: Int, createCellHandler: @escaping (Int, Int) -> CellView) {
        self.size = size
        self.createCellHandler = createCellHandler
    }

    var body: some View {
        VStack(alignment: .center, spacing: cellSpacing) {
            ForEach(0..<self.size) { column in
                HStack(alignment: .center, spacing: cellSpacing) {
                    ForEach(0..<self.size) { row in
                        self.createCellHandler(row, column)
                    }
                }
            }
        }
    }
}

private extension Lines.Cell {
    var color: Color {
        switch self {
        case .empty: return Color(0xCCCCCC)
        case .fill(let color): return color.color
        }
    }
}

private extension Lines.CellColor {
    var color: Color {
        switch self {
        case .blue: return Color(0x0000AA)
        case .green: return Color(0x00AA00)
        case .red: return Color(0xAA0000)
        case .yellow: return Color(0xe5e500)
        case .pink: return Color(0xe55ea2)
        }
    }
}

private struct CellView: View {
    let cell: Lines.Cell
    let didTapHandler: () -> ()

    init(cell: Lines.Cell, didTapHandler: @escaping () -> ()) {
        self.cell = cell
        self.didTapHandler = didTapHandler
    }

    var body: some View {
        Button(
            action: didTapHandler,
            label: { cellContent })
    }

    private var cellContent: some View {
        Rectangle()
            .foregroundColor(Color(0xCCCCCC))
            .overlay(circle)
    }

    private var circle: some View {
        Circle()
            .inset(by: 5)
            .foregroundColor(cell.color)
            .scaleEffect(cell == .empty ? 0 : 1)
            .animation(.basic(curve: .easeInOut))
    }
}

#if DEBUG
struct LinesView_Previews : PreviewProvider {
    static var previews: some View {
        LinesView(size: Lines.Difficulty.easy.size, rules: Lines.Rules(difficulty: .easy))
    }
}
#endif
