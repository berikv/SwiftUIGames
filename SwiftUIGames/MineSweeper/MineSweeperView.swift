//
//  MineSweeperView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

private let numberOfBombs = 10
private let size = 10

struct MineSweeperView : View {
    @State private var game = MineSweeper(size: size, numberOfBombs: numberOfBombs)
    @State private var guessBomb = false

    var body: some View {
        VStack {
            if self.game.state == .gameOver(didWin: true) {
                Text("You WON!")
            }

            if self.game.state == .gameOver(didWin: false) {
                Text("Game over")
            }
            
            Text("Bombs: \(game.bombCount)")
            Text("Marked: \(game.bombsMarked)")
            Toggle(isOn: $guessBomb, label: {Text(guessBomb ? "Guess bomb" : "Guess empty")})

            GridView(rows: game.size, columns: game.size) { (row, column) in
                CellView(viewModel: self.game.cellStatusAt(row: row, column: column)) {
                    if self.guessBomb {
                        self.game.markBomb(row: row, column: column)
                    } else {
                        self.game.explore(row: row, column: column)
                    }
                }
            }
                .padding(20)

            if self.game.state != .playing {
                Button(action: { self.game = MineSweeper(size: size, numberOfBombs: numberOfBombs) },
                       label: { Text("Replay") })
            }
        }
    }
}

private struct CellView: View {
    let viewModel: MineSweeper.CellStatus
    let tapAction: () -> ()

    var text: String {
        switch viewModel {
        case .bomb: return "x"
        case .empty: return "e"
        case .emptyWithBombCount(let bombCount): return "\(bombCount)"
        case .exploded: return "X"
        case .mark: return "?"
        case .unknown: return ""
        }
    }

    var image: Image {
        switch viewModel {
        case .unknown: return Image(systemName: "app.fill")
        case .empty: return Image(systemName: "app")
        case .emptyWithBombCount(let bombCount): return Image(systemName: "\(bombCount).square")
        case .mark: return Image(systemName: "questionmark")
        case .bomb: return Image(systemName: "dot.circle")
        case .exploded: return Image(systemName: "xmark.circle")
        }
    }

    var body: some View {
        Button(action: tapAction,
               label: {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .background(Color(0xcccccc))
                    .overlay(image)
        })
    }
}

#if DEBUG
struct MineSweeperView_Previews : PreviewProvider {
    static var previews: some View {
        MineSweeperView()
    }
}
#endif
