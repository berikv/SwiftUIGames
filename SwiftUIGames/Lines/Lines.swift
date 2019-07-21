//
//  Lines.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

struct Lines {
    enum CellColor: CaseIterable {
        case red, blue, yellow, green, pink
    }

    enum Cell: Equatable {
        case empty
        case fill(CellColor)
    }

    struct LineIndex: Hashable {
        let row: Int
        let column: Int
    }

    enum Difficulty: CaseIterable {
        case easy, medium, hard, veryHard
        var rules: Rules { Rules(difficulty: self) }
    }

    struct Rules {
        let size: Int
        let availableColorsCount: Int
        let lineLength: Int
        let addRandomCount: Int

        init(size: Int,
             availableColorsCount: Int,
             lineLength: Int,
             addRandomCount: Int) {
            self.size = size
            self.availableColorsCount = availableColorsCount
            self.lineLength = lineLength
            self.addRandomCount = addRandomCount
        }

        init(difficulty: Difficulty) {
            switch difficulty {
            case .easy:
                self.size = 4
                self.lineLength = 3
                self.availableColorsCount = 3
                self.addRandomCount = 1
            case .medium:
                self.size = 6
                self.lineLength = 4
                self.availableColorsCount = 4
                self.addRandomCount = 1
            case .hard:
                self.size = 8
                self.lineLength = 4
                self.availableColorsCount = 4
                self.addRandomCount = 2
            case .veryHard:
                self.size = 10
                self.lineLength = 5
                self.availableColorsCount = 5
                self.addRandomCount = 3
            }
        }
    }

    let rules: Rules

    private(set) var nextColorToPut: CellColor
    private(set) var score: Int = 0

    private var board: [[Cell]]

    init(difficulty: Difficulty) {
        self.init(rules: difficulty.rules)
    }

    init(rules: Rules) {
        self.rules = rules
        
        let row = Array(repeating: Cell.empty, count: rules.size)
        board = Array(repeating: row, count: rules.size)

        nextColorToPut = .blue
        nextColorToPut = randomColor()
        addRandom()
    }

    subscript(_ index: LineIndex) -> Cell {
        get { board[index.column][index.row] }
        set { board[index.column][index.row] = newValue }
    }

    mutating func replay() {
        let row = Array(repeating: Cell.empty, count: rules.size)
        board = Array(repeating: row, count: rules.size)
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

    private func randomColor() -> CellColor {
        let colors = Array(CellColor.allCases[0..<rules.availableColorsCount])
        return colors.randomElement()!
    }

    @discardableResult
    private mutating func clearColoredLines(withLength length: Int) -> Bool {
        var toBeCleared = Set<LineIndex>()

        for line in lines {
            var matchColor: CellColor?
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
        (0..<rules.size).flatMap { row in
            (0..<rules.size).map { column in
                LineIndex(row: row, column: column)
            }
        }
    }()

    private lazy var lines: [[LineIndex]] = {
        let horizontals = (0..<rules.size).map { column in
            (0..<rules.size).map { row in
                LineIndex(row: row, column: column)
            }
        }

        let verticals = (0..<rules.size).map { row in
            (0..<rules.size).map { column in
                LineIndex(row: row, column: column)
            }
        }

        var diagonals = [[LineIndex]]()
        for k in 0...(rules.size * 2 - 2) {
            var diagonalDesc = [LineIndex]()
            var diagonalAsc = [LineIndex]()

            for j in 0...k {
                let i = k - j
                if i < rules.size && j < rules.size {
                    diagonalAsc.append(LineIndex(row: j, column: i))
                    diagonalDesc.append(LineIndex(row: j, column: rules.size - i - 1))
                }
            }
            diagonals.append(diagonalDesc)
            diagonals.append(diagonalAsc)
        }

        return horizontals + verticals + diagonals
    }()
}
