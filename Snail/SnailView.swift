//
//  SnailView.swift
//  Snail
//
//  Created by Berik Visschers on 2019-06-15.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

extension Color {
    init(_ value: Int) {
        let red = Double(value >> 16 & 0xff) / 255.0
        let green = Double(value >> 8 & 0xff) / 255.0
        let blue = Double(value & 0xff) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension Color {
    static let snail = Color(0x212d23)
    static let food = Color(0x212d23)
    static let background = Color(0x7ea082)
}

struct SnailView: View {

    let spacing: Length = 2
    let cellSize: Length = 10

    var movesPerSecond: Double { 10 + 0.1 * Double(game.score) }

    @State private var game = Snail()
    @State var lastMove: Direction = .right
    @State var timer: Timer?

    func playMoveAfterTimeout() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1 / movesPerSecond, repeats: false) { _ in
            self.playMove(self.lastMove)
        }
    }

    func playMove(_ direction: Direction) {
        game.doMove(direction)
        lastMove = direction
        playMoveAfterTimeout()
    }

    func replay() {
        lastMove = .right
        game = Snail()
    }

    func colorForCellAt(_ x: Int, _ y: Int) -> Color {
        let position = Position(x: x, y: y)
        if game.snake.contains(position) { return .snail }
        if game.foodPosition == position { return .food }
        return .background
    }

    fileprivate func cellView(_ x: Int, _ y: Int) -> some View {
        return Rectangle().foregroundColor(self.colorForCellAt(x, y))
    }

    fileprivate func gameView() -> some View {
        HStack(spacing: self.spacing) {
            ForEach(0..<self.game.size.width) { x in
                VStack(spacing: self.spacing) {
                    ForEach(0..<self.game.size.height) { y in
                        self.cellView(x, y)
                    }
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            Button(action: self.replay, label: { Text("Replay") })

            Text("Score \(game.score)")

            gameView()
                .aspectRatio(contentMode: .fit)
                .padding(spacing)
                .background(Color.background)

            ControlsView(
                upAction: { self.playMove(.up) },
                downAction: { self.playMove(.down) },
                leftAction: { self.playMove(.left) },
                rightAction: { self.playMove(.right) })
                .onAppear { self.playMoveAfterTimeout() }
        }
    }
}

struct ControlsView: View {
    let upAction: () -> ()
    let downAction: () -> ()
    let leftAction: () -> ()
    let rightAction: () -> ()

    var body: some View {
        VStack(alignment: .center) {
            Button(action: self.upAction, label: { Text("↑").bold() })
            HStack() {
                Button(action: self.leftAction, label: { Text("←").bold() })
                Spacer()
                Button(action: self.rightAction, label: { Text("→").bold() })
            }
            Button(action: self.downAction, label: { Text("↓").bold() })
        }
            .aspectRatio(1, contentMode: .fit)
            .font(.system(size: 55))
            .foregroundColor(.snail)
    }
}

#if DEBUG
struct SnailView_Previews : PreviewProvider {
    static var previews: some View {
        SnailView()
    }
}
#endif
