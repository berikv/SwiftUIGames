//
//  MineSweeper.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

extension MineSweeper.Board {
    static func empty(size: Int) -> MineSweeper.Board {
        let row = Array<MineSweeper.Cell>(repeating: .unknown(.empty), count: size)
        var board = Array(repeating: row, count: size)
        for rowIndex in board.startIndex..<board.endIndex {
            let row = board[rowIndex]
            for columnIndex in row.startIndex..<row.endIndex {
                if Int.random(in: 0..<8) == 0 {
                    board[rowIndex][columnIndex] = .unknown(.bomb)
                }
            }
        }
        return board
    }
}

struct MineSweeper {
    typealias Board = [[Cell]]

    enum CellBomb { case bomb, empty }
    enum Cell: Equatable {
        case knownEmpty(bombCount: Int)
        case unknown(CellBomb)
        case guessBomb(CellBomb)
        case exploded

        fileprivate var hasBomb: Bool {
            switch self {
            case .unknown(let hasBomb),
                 .guessBomb(let hasBomb): return hasBomb == .bomb
            case .exploded: return true
            case .knownEmpty: return false
            }
        }

        var isBombGuess: Bool {
            switch self {
            case .guessBomb: return true
            default: return false
            }
        }
    }

    enum State: Equatable {
        case playing, won, gameOver
    }

    struct Index: Hashable {
        let row: Int
        let column: Int
        func neighbor(_ direction: Direction, size: Int) -> Index? {
            switch direction {
            case .top: return row <= 0 ? nil : Index(row: row - 1, column: column)
            case .bottom: return row + 1 >= size ? nil : Index(row: row + 1, column: column)
            case .left: return column <= 0 ? nil : Index(row: row, column: column - 1)
            case .right: return column + 1 >= size ? nil : Index(row: row, column: column + 1)
            case .topLeft: return row <= 0 || column <= 0 ? nil : Index(row: row - 1, column: column - 1)
            case .topRight: return row <= 0 || column + 1 >= size ? nil : Index(row: row - 1, column: column + 1)
            case .bottomLeft: return row + 1 >= size || column <= 0 ? nil : Index(row: row + 1, column: column - 1)
            case .bottomRight: return row + 1 >= size || column + 1 >= size ? nil : Index(row: row + 1, column: column + 1)
            }
        }
    }

    enum Direction: CaseIterable { case top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight }

    var board: Board
    var state: State = .playing
    let size = 10

    init() {
        board = .empty(size: size)
    }

    var bombCount: Int {
        board
            .flatMap { $0 }
            .filter { $0.hasBomb }
            .count
    }

    var bombsGuessed: Int {
        board
            .flatMap { $0 }
            .filter { $0.isBombGuess }
            .count
    }

    var didWin: Bool {
        board
            .flatMap { $0 }
            .filter { $0 == .unknown(.empty) || $0 == .exploded }
            .isEmpty
    }

    mutating func guessBomb(row: Int, column: Int) {
        guard state == .playing else { return }

        if case .guessBomb(let hasBomb) = board[row][column] {
            board[row][column] = .unknown(hasBomb)
        } else if case .unknown(let hasBomb) = board[row][column] {
            board[row][column] = .guessBomb(hasBomb)
        }
    }

    mutating func guessEmpty(row: Int, column: Int) {
        guard state == .playing else { return }

        switch board[row][column] {
        case .unknown(.bomb),
             .guessBomb(.bomb):
            state = .gameOver
            board[row][column] = .exploded
            return
        case .knownEmpty,
              .exploded:
            return
        case .unknown(.empty),
             .guessBomb(.empty):
            break
        }

        var alreadyChecked = Set<Index>()
        var toCheck = Set([Index(row: row, column: column)])

        while !toCheck.isEmpty {
            let current = toCheck.removeFirst()
            alreadyChecked.insert(current)

            let bombCount = Direction.allCases
                .compactMap { current.neighbor($0, size: size) }
                .filter { board[$0.row][$0.column].hasBomb }
                .count

            board[current.row][current.column] = .knownEmpty(bombCount: bombCount)

            guard bombCount == 0 else { continue }

            Direction.allCases
                .compactMap { current.neighbor($0, size: size) }
                .filter { board[$0.row][$0.column] == .unknown(.empty) }
                .forEach { toCheck.insert($0) }

            toCheck.subtract(alreadyChecked)
        }

        if didWin {
            state = .won
        }
    }

    mutating func replay() {
        board = .empty(size: size)
        state = .playing
    }
}
