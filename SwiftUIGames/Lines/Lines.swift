//
//  Lines.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import Foundation

enum LinesCell: Equatable {
    enum CellColor: CaseIterable {
        case red, blue, yellow, green, pink
    }

    case empty
    case fill(CellColor)
}

struct LineIndex: Hashable {
    let row: Int
    let column: Int
}

enum Difficulty: CaseIterable {
    case small, medium, big, huge

    var size: Int {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .big: return 10
        case .huge: return 12
        }
    }
}

struct Rules {
    let availableColorsCount: Int
    let lineLength: Int
    let addRandomCount: Int

    init(availableColorsCount: Int, lineLength: Int, addRandomCount: Int) {
        self.availableColorsCount = availableColorsCount
        self.lineLength = lineLength
        self.addRandomCount = addRandomCount
    }

    init(difficulty: Difficulty) {
        switch difficulty {
        case .small: self.availableColorsCount = 4
        case .medium: self.availableColorsCount = 4
        case .big: self.availableColorsCount = 4
        case .huge: self.availableColorsCount = 4
        }

        switch difficulty {
        case .small: self.lineLength = 3
        case .medium: self.lineLength = 4
        case .big: self.lineLength = 4
        case .huge: self.lineLength = 5
        }

        switch difficulty {
        case .small: self.addRandomCount = 1
        case .medium: self.addRandomCount = 1
        case .big: self.addRandomCount = 2
        case .huge: self.addRandomCount = 3
        }
    }
}

struct Lines {
    let size: Int
    let rules: Rules

    private(set) var nextColorToPut: LinesCell.CellColor
    private(set) var score: Int = 0

    private var board: [[LinesCell]]

    init(size: Int, rules: Rules) {
        self.size = size
        self.rules = rules
        
        let row = Array(repeating: LinesCell.empty, count: size)
        board = Array(repeating: row, count: size)

        nextColorToPut = .blue
        nextColorToPut = randomColor()
        addRandom()
    }

    subscript(_ index: LineIndex) -> LinesCell {
        get { board[index.column][index.row] }
        set { board[index.column][index.row] = newValue }
    }

    mutating func replay() {
        let row = Array(repeating: LinesCell.empty, count: size)
        board = Array(repeating: row, count: size)
        nextColorToPut = randomColor()
        score = 0
        addRandom()
    }

    mutating func put(at index: LineIndex) {
        guard self[index] == .empty else { return }
        self[index] = .fill(nextColorToPut)
        nextColorToPut = randomColor()

        let noChange = clearColoredLines(withLength: rules.lineLength)

        if noChange {
            addRandom()
            clearColoredLines(withLength: rules.lineLength)
        }
    }

    private func randomColor() -> LinesCell.CellColor {
        let colors = Array(LinesCell.CellColor.allCases[0..<rules.availableColorsCount])
        return colors.randomElement()!
    }

    @discardableResult
    private mutating func clearColoredLines(withLength length: Int) -> Bool {
        var toBeCleared = Set<LineIndex>()

        for line in lines {
            var matchColor: LinesCell.CellColor?
            var matchingLine = [LineIndex]()

            for cellIndex in line {
                switch (self[cellIndex], matchingLine.isEmpty) {
                case (.empty, true):
                    continue

                case (.fill(matchColor), false):
                    matchingLine.append(cellIndex)

                case (.fill(let c), true):
                    matchingLine.append(cellIndex)
                    matchColor = c

                case (.fill(let c), false):
                    if matchingLine.count >= length {
                        toBeCleared.formUnion(matchingLine)
                    }
                    matchingLine = [cellIndex]
                    matchColor = c

                case (.empty, false):
                    if matchingLine.count >= length {
                        toBeCleared.formUnion(matchingLine)
                    }
                    matchingLine.removeAll()
                    matchColor = nil
                }
            }

            if matchingLine.count >= length {
                toBeCleared.formUnion(matchingLine)
            }
        }
        
        for index in toBeCleared {
            self[index] = .empty
        }

        score += toBeCleared.count
        return toBeCleared.isEmpty
    }

    private mutating func addRandom() {
        (0..<rules.addRandomCount).forEach { _ in
            let emptyCells = allIndexes.filter { index in self[index] == .empty }
            guard let randomEmptyCell = emptyCells.randomElement() else { return }
            self[randomEmptyCell] = .fill(randomColor())
        }
    }

    private lazy var allIndexes: [LineIndex] = {
        (0..<size).flatMap { row in
            (0..<size).map { column in
                LineIndex(row: row, column: column)
            }
        }
    }()

    private lazy var lines: [[LineIndex]] = {
        let horizontals = (0..<size).map { column in
            (0..<size).map { row in
                LineIndex(row: row, column: column)
            }
        }

        let verticals = (0..<size).map { row in
            (0..<size).map { column in
                LineIndex(row: row, column: column)
            }
        }

        var diagonals = [[LineIndex]]()
        for k in 0...(size * 2 - 2) {
            var diagonalDesc = [LineIndex]()
            var diagonalAsc = [LineIndex]()

            for j in 0...k {
                let i = k - j
                if i < size && j < size {
                    diagonalAsc.append(LineIndex(row: j, column: i))
                    diagonalDesc.append(LineIndex(row: j, column: size - i - 1))
                }
            }
            diagonals.append(diagonalDesc)
            diagonals.append(diagonalAsc)
        }

        return horizontals + verticals + diagonals
    }()
}
