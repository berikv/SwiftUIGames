//
//  TitresView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-23.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct TitresView: View {
    @State private var game = Titres()
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            FieldView(field: game.field)

            ControlsView(turnAction: { self.game.rotateLeft() },
                         dropAction: { self.game.drop() },
                         leftAction: { self.game.moveLeft() },
                         rightAction: { self.game.moveRight() })

            Spacer()
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 40)
        }
            .onAppear {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.game.tick() }
            }
            .onDisappear { // This is not called..
                self.timer?.invalidate()
                self.timer = nil
        }
    }
}

private struct FieldView: View {
    let field: Field
    init(field: Field) {
        self.field = field
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(field.identified(by: \.self)) { row in
                HStack(spacing: 2) {
                    ForEach(row.identified(by: \.self)) { cell in
                        CellView(cell: cell)
                    }
                }
            }
        }
            .border(Color(0xaaaaaa), width: 2)
    }
}

private struct CellView: View {
    let cell: Shape?

    init(cell: Shape?) {
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
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(color)
    }
}

private struct ControlsView: View {
    let turnAction: () -> ()
    let dropAction: () -> ()
    let leftAction: () -> ()
    let rightAction: () -> ()
    init(turnAction: @escaping () -> (),
         dropAction: @escaping () -> (),
         leftAction: @escaping () -> (),
         rightAction: @escaping () -> ()) {
        self.turnAction = turnAction
        self.dropAction = dropAction
        self.leftAction = leftAction
        self.rightAction = rightAction
    }

    var body: some View {
        HStack(spacing: 20) {
//            Button(action: turnAction) { Text("🔄") }
            Button(action: leftAction) { Text("⬅") }
            Button(action: dropAction) { Text("⬇") }
            Button(action: rightAction) { Text("➡") }
        }
            .font(.system(size: 50))
    }
}
