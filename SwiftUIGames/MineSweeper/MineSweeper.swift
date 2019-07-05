//
//  MineSweeper.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

private struct InternalCell {
    enum CellHasBomb: Equatable {
        case bomb(exploded: Bool)
        case noBomb(neighborBombs: Int)
    }

    var hasBomb: CellHasBomb
    var isCovered: Bool
    var isMarked: Bool
}

private enum Direction: CaseIterable {
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

private struct Index: Hashable {
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

struct MineSweeper {

    enum CellStatus: Equatable {
        case empty
        case emptyWithBombCount(Int)
        case unknown
        case bomb
        case mark
        case exploded
    }

    enum State: Equatable {
        case playing
        case gameOver(didWin: Bool)
    }

    let size: Int
    let numberOfBombs: Int

    private var bombField: Matrix<InternalCell>

    init(size: Int, numberOfBombs: Int) {
        self.size = size
        self.numberOfBombs = numberOfBombs

        let cell = InternalCell(
            hasBomb: .noBomb(neighborBombs: 0),
            isCovered: true,
            isMarked: false)

        bombField = Matrix(repeating: cell, rowCount: size, columnCount: size)

        let allIndexes = (0..<size).flatMap { row in
            (0..<size).map { column in Index(row: row, column: column) }
        }

        let bombIndexes = allIndexes.shuffled().prefix(numberOfBombs)

        bombIndexes.forEach { index in
            bombField[index.row, index.column].hasBomb = .bomb(exploded: false)
            Direction.allCases
                .compactMap { direction -> Index? in index.neighbor(direction, size: size) }
                .forEach { neighbor in
                    if case .noBomb(let neighborBombs) = bombField[neighbor.row, neighbor.column].hasBomb {
                        bombField[neighbor.row, neighbor.column].hasBomb = .noBomb(neighborBombs: neighborBombs + 1)
                    }
            }
        }
    }

    var state: State {
        if bombField.count(where: { $0.hasBomb == .bomb(exploded: true) }) > 0 {
            return .gameOver(didWin: false)
        } else if bombField.count(where: { $0.isCovered && $0.hasBomb != .bomb(exploded: false) }) == 0 {
            return .gameOver(didWin: true)
        } else {
            return .playing
        }
    }

    var bombCount: Int {
        bombField.count { $0.hasBomb == .bomb(exploded: true) || $0.hasBomb == .bomb(exploded: false) }
    }

    var bombsMarked: Int {
        bombField.count { $0.isMarked }
    }

    func cellStatusAt(row: Int, column: Int) -> CellStatus {
        let cell = bombField[row, column]
        if cell.hasBomb == .bomb(exploded: true) {
            return .exploded
        }

        if cell.isCovered && state == .playing {
            return cell.isMarked ? .mark : .unknown
        }

        switch cell.hasBomb {
        case .noBomb(neighborBombs: 0): return .empty
        case .noBomb(let neighborBombs): return .emptyWithBombCount(neighborBombs)
        case .bomb: return .bomb
        }
    }

    mutating func markBomb(row: Int, column: Int) {
        guard state == .playing else { return }
        guard bombField[row, column].isCovered else { return }
        bombField[row, column].isMarked.toggle()
    }

    mutating func explore(row: Int, column: Int) {
        guard state == .playing else { return }
        guard !bombField[row, column].isMarked else {
            bombField[row, column].isMarked.toggle()
            return
        }

        switch bombField[row, column].hasBomb {
        case .bomb: bombField[row, column].hasBomb = .bomb(exploded: true)
        case .noBomb: expandExplore(startIndex: Index(row: row, column: column))
        }
    }

    fileprivate mutating func expandExplore(startIndex: Index) {
        var toCheck = Set<Index>([startIndex])
        var alreadyChecked = Set<Index>()

        while !toCheck.isEmpty {
            let current = toCheck.removeFirst()
            alreadyChecked.insert(current)

            bombField[current.row, current.column].isCovered = false

            guard case .noBomb(0) = bombField[current.row, current.column].hasBomb else { continue }

            Direction.allCases
                .compactMap { current.neighbor($0, size: size) }
                .filter { bombField[$0.row, $0.column].isCovered }
                .forEach { toCheck.insert($0) }

            toCheck.subtract(alreadyChecked)
        }
    }
}
