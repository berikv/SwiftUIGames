//
//  MineSweeperView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct MineSweeperView : View {
    @State var game = MineSweeper()
    @State var guessBomb = false

    var body: some View {
        VStack {
            if self.game.state != .playing {
                Text(self.game.state == .won ? "You WON!" : "Game over")
            }
            
            Text("Bombs: \(game.bombCount)")
            Text("Marked: \(game.bombsGuessed)")
            Toggle(isOn: $guessBomb, label: {Text(guessBomb ? "Guess bomb" : "Guess empty")})

            GridView(rows: game.size, columns: game.size) { (row, column) in
                CellView(state: self.game.board[row][column], gameOver: self.game.state == .gameOver) {
                    if self.guessBomb {
                        self.game.guessBomb(row: row, column: column)
                    } else {
                        self.game.guessEmpty(row: row, column: column)
                    }
                }
            }
                .padding(20)

            if self.game.state != .playing {
                Button(action: { self.game.replay() },
                       label: { Text("Replay") })
            }
        }
    }
}

private struct CellView: View {
    let state: MineSweeper.Cell
    let gameOver: Bool
    let tapAction: () -> ()
    var text: String {
        switch state {
        case .knownEmpty(0):
            return "e"

        case .knownEmpty(let bombCount):
            return "\(bombCount)"

        case .unknown(let hasBomb):
            if gameOver {
                return hasBomb == .bomb ? "x" : "e"
            }
            return ""

        case .guessBomb(let hasBomb):
            return gameOver && hasBomb == .bomb ? "x" : "?"

        case .exploded:
            return "x"
        }
    }

    var body: some View {
        Button(action: tapAction,
               label: {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .background(Color(0xcccccc))
                    .overlay(Text(text))
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
