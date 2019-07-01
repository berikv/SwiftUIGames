//
//  LinesWelcomeView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-17.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct LinesWelcomeView: View {

    func linesView(for difficulty: Lines.Difficulty) -> LinesView {
        return LinesView(size: difficulty.size,
                         rules: Lines.Rules(difficulty: difficulty))
    }

    var body: some View {
        List {
            ForEach(Lines.Difficulty.allCases.identified(by: \.self)) { difficulty in
                NavigationButton(destination: self.linesView(for: difficulty)) {
                    Text("\(difficulty.size)x\(difficulty.size)")
                }
            }

            NavigationButton(destination: CustomRulesCreatorView(),
                             label: { Text("Custom") })
        }
            .navigationBarTitle(Text("Lines"))
    }
}

struct CustomRulesCreatorView: View {
    @State private var size: Int = 6
    @State private var availableColorCount: Int = 4
    @State private var lineLength: Int = 4
    @State private var addRandomCount: Int = 2

    private var linesView: LinesView {
        let rules = Lines.Rules(
            availableColorsCount: availableColorCount,
            lineLength: lineLength,
            addRandomCount: addRandomCount)

        return LinesView(size: size, rules: rules)
    }

    var body: some View {
        VStack(spacing: 30) {
            Stepper(value: $size, in: 3...20) { Text("Board size (\(size)x\(size))") }
            Stepper(value: $availableColorCount, in: 2...Lines.CellColor.allCases.count) { Text("Colors \(availableColorCount)") }
            Stepper(value: $lineLength, in: 2...8) { Text("Line length \(lineLength)") }
            Stepper(value: $addRandomCount, in: 1...8) { Text("Amount of random to add \(addRandomCount)") }

            NavigationButton(destination: linesView,
                             label: { Text("Play!") })

            Spacer()
        }
            .padding(20)
            .navigationBarTitle(Text("Lines, custom rules"))
    }
}
