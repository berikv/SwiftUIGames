//
//  LinesWelcomeView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-17.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct LinesWelcomeView: View {
    var body: some View {
        List {
            ForEach(Lines.Difficulty.allCases, id: \Lines.Difficulty.self) { difficulty in
                self.navigationLinkFor(difficulty: difficulty)
            }

            NavigationLink(destination: CustomRulesCreatorView(), label: { Text("Custom") })
        }
            .navigationBarTitle(Text("Lines"))
    }

    func navigationLinkFor(difficulty: Lines.Difficulty) -> some View {
        let size = difficulty.rules.size
        let label = { Text("\(size)x\(size)") }
        let linesView = LinesView(rules: difficulty.rules)
        return NavigationLink(destination: linesView, label: label)
    }
}

private struct CustomRulesCreatorView: View {
    @State private var size: Int = 6
    @State private var availableColorCount: Int = 4
    @State private var lineLength: Int = 4
    @State private var addRandomCount: Int = 2

    private var linesView: LinesView {
        let rules = Lines.Rules(
            size: size,
            availableColorsCount: availableColorCount,
            lineLength: lineLength,
            addRandomCount: addRandomCount)

        return LinesView(rules: rules)
    }

    var body: some View {
        Form {
            Stepper(value: $size, in: 3...20) { Text("Board size (\(size)x\(size))") }
            Stepper(value: $availableColorCount, in: 2...Lines.CellColor.allCases.count) { Text("Colors \(availableColorCount)") }
            Stepper(value: $lineLength, in: 2...8) { Text("Line length \(lineLength)") }
            Stepper(value: $addRandomCount, in: 1...8) {
                Text("Amount of random to add \(addRandomCount)")
                    .lineLimit(nil)
            }

            NavigationLink(destination: linesView,
                             label: { Text("Play!") })
        }
            .padding(20)
            .navigationBarTitle(Text("Custom rules"))
    }
}
