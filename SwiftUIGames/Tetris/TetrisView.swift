//
//  TetrisView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-23.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct TetrisView: View {
    @State private var game = Tetris()
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 20) {
            PlayfieldView(game: game)
                .overlay(TetrisGameoverView(state: self.game.state, newGameAction: { self.game.newGame() }))

            ControlsView(rightAction: { self.game.moveRight() },
                         leftAction: { self.game.moveLeft() },
                         rotateRightAction: { self.game.rotateCW() },
                         dropAction: { self.game.drop() })
        }
            .onAppear {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in self.game.tick() }
            }
            .onDisappear {
                self.timer?.invalidate()
                self.timer = nil
        }
    }
}

private struct PlayfieldView: View {
    let game: Tetris
    init(game: Tetris) {
        self.game = game
    }

    var body: some View {
        GridView(rows: Tetris.rows, columns: Tetris.columns, spacing: 2) { (row, column) -> CellView in
            let cell = self.game[TetrisPlayfieldIndex(row: row, column: column)]
            return CellView(cell: cell)
        }
//            .background(Color.gray)
//            .padding(2)
//            .border(Color(0xaaaaaa), width: 2)
    }
}

private struct CellView: View {
    let cell: Tetromino?

    init(cell: Tetromino?) {
        self.cell = cell
    }

    var color: Color {
        switch cell {
        case .i: return Color(0xffd700)
        case .t: return Color(0xb6fcd5)
        case .l: return Color(0xa0db8e)
        case .o: return Color(0x1e84d4)
        case .j: return Color(0x6897bb)
        case .z: return Color(0xff7373)
        case .s: return Color(0x40e0d0)
        case .none: return .clear
        }
    }

    var body: some View {
        Rectangle()
            .foregroundColor(color)
    }
}

private struct ControlsView: View {
    let rightAction: () -> ()
    let leftAction: () -> ()
    let rotateRightAction: () -> ()
    let dropAction: () -> ()
    init(rightAction: @escaping () -> (),
        leftAction: @escaping () -> (),
        rotateRightAction: @escaping () -> (),
        dropAction: @escaping () -> ()) {
        self.rightAction = rightAction
        self.leftAction = leftAction
        self.rotateRightAction = rotateRightAction
        self.dropAction = dropAction
    }

    var body: some View {
        HStack(spacing: 20) {
            Button(action: leftAction) { Text("←") }
            VStack(spacing: 20) {
                Button(action: rotateRightAction) { Text("⃕") }
                Button(action: dropAction) { Text("↓") }
            }
            Button(action: rightAction) { Text("→") }
        }
            .font(.system(size: 50))
    }
}

private struct TetrisGameoverView: View {
    let state: Tetris.State
    let newGameAction: () -> ()

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var backgroundColor: Color { colorScheme == .light ? Color.white : Color.black }

    var body: some View {
        VStack(spacing: 10) {
            Text("GAME OVER")
            Button(action: newGameAction,
                   label: { Text("new game") })
        }
            .padding(20)
            .background(backgroundColor.opacity(0.8))
            .opacity(state == .gameOver ? 1 : 0)
    }
}
