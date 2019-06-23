//
//  Titres.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-21.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

private let width = 10
private let height = 20

enum Shape: CaseIterable { case i, t, l, o, j, z, s
    static func random() -> Shape { Shape.allCases.randomElement()! }
}

struct FieldIndex: Equatable {
    var row: Int
    var column: Int
}

struct Piece {
    let shape: Shape
    var indexes: [FieldIndex]

    static func random() -> Piece { Piece(shape: Shape.random()) }

    init(shape: Shape) {
        self.shape = shape

        switch shape {
        case .i:
            self.indexes = [
                FieldIndex(row: 0, column: 3),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
                FieldIndex(row: 0, column: 6),
            ]
        case .t:
            self.indexes = [
                FieldIndex(row: 0, column: 3),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
                FieldIndex(row: 1, column: 4),
            ]
        case .o:
            self.indexes = [
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
                FieldIndex(row: 1, column: 4),
                FieldIndex(row: 1, column: 5),
            ]
        case .l:
            self.indexes = [
                FieldIndex(row: 0, column: 3),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
                FieldIndex(row: 1, column: 3),
            ]
        case .j:
            self.indexes = [
                FieldIndex(row: 0, column: 3),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
                FieldIndex(row: 1, column: 5),
            ]
        case .s:
            self.indexes = [
                FieldIndex(row: 1, column: 3),
                FieldIndex(row: 1, column: 4),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 0, column: 5),
            ]
        case .z:
            self.indexes = [
                FieldIndex(row: 0, column: 3),
                FieldIndex(row: 0, column: 4),
                FieldIndex(row: 1, column: 4),
                FieldIndex(row: 1, column: 5),
            ]
        }
    }

    private init(shape: Shape, indexes: [FieldIndex]) {
        self.shape = shape
        self.indexes = indexes
    }

    func byMovingDown() -> Piece {
        Piece(shape: shape, indexes: indexes.map { index in FieldIndex(row: index.row + 1, column: index.column) })
    }

    @discardableResult
    mutating func translate(row: Int = 0, column: Int = 0, validate: ([FieldIndex]) -> Bool) -> Bool {
        let newIndexes = indexes.map { index in
            FieldIndex(row: index.row + row,
                       column: index.column + column)
        }

        if validate(newIndexes) {
            self.indexes = newIndexes
            return true
        }
        return false
    }

    mutating func byRotatingLeft() -> Piece {
        return self
    }
}

typealias Field = [[Shape?]]
extension Field {
    subscript(_ index: FieldIndex) -> Shape? {
        get {
            guard index.row < self.endIndex && index.row >= 0 else { return nil }
            let row = self[index.row]
            guard index.column < row.endIndex && index.column >= 0 else { return nil }
            return self[index.row][index.column]
        }
        set {
            guard index.row < self.endIndex && index.row >= 0 else { fatalError() }
            let row = self[index.row]
            guard index.column < row.endIndex && index.column >= 0 else { fatalError() }
            self[index.row][index.column] = newValue
        }
    }
}

struct Titres {
    var field: Field {
        _field.enumerated().map { (arg0) -> [Shape?] in
            let (rowIndex, element) = arg0
            return element.enumerated().map { (arg1) -> Shape? in
                let (columnIndex, cell) = arg1
                let index = FieldIndex(row: rowIndex, column: columnIndex)
                if cell == nil && currentPiece.indexes.contains(index) {
                    return currentPiece.shape
                }
                return cell
            }
        }
    }

    private var _field: [[Shape?]] = {
        let row = Array(repeating: Optional<Shape>(nil), count: width)
        return Array(repeating: row, count: height)
    }()

    var currentPiece: Piece
    var nextPiece: Piece

    init() {
        currentPiece = Piece.random()
        nextPiece = Piece.random()
    }

    mutating func drop() {
        while true {
            let next = currentPiece.byMovingDown()
            guard validPosition(for: next) else { break }
            currentPiece = next
        }
    }

    mutating func rotateLeft() { // CCW
        currentPiece = currentPiece.byRotatingLeft()
    }

    private func isValidNewPosition(_ indexes: [FieldIndex]) -> Bool {
        indexes.reduce(true) { (result, index) -> Bool in
            return result
                && index.row < _field.endIndex
                && index.row >= 0
                && index.column < _field[0].endIndex
                && index.column >= 0
                && _field[index] == nil
        }
    }

    mutating func moveLeft () {
        currentPiece.translate(column: -1, validate: isValidNewPosition)
    }

    mutating func moveRight () {
        currentPiece.translate(column: 1, validate: isValidNewPosition)
    }

    mutating func tick() {
        guard currentPiece.translate(row: 1, validate: isValidNewPosition) else {
            handlePieceLock()
            return
        }
    }

    private mutating func handlePieceLock() {
        // Delay 500ms
        currentPiece.indexes.forEach { index in _field[index] = currentPiece.shape }
        removeFilledRows()
        guard validPosition(for: nextPiece) else {
            print("Game over")
            return
        }
        currentPiece = nextPiece
        nextPiece = Piece.random()
    }

    private mutating func removeFilledRows() {
        for rowIndex in 0..<_field.endIndex {
            let row = _field[rowIndex]
            guard !row.contains(nil) else { continue }

            for rowIndex in (1...rowIndex).reversed() {
                _field[rowIndex] = _field[rowIndex - 1]
            }
        }
    }

    private func validPosition(for piece: Piece) -> Bool {
        fitsWithoutOverlap(piece) && aboveBottom(piece)
    }

    private func fitsWithoutOverlap(_ piece: Piece) -> Bool {
        !piece.indexes.contains { (index) -> Bool in _field[index] != nil }
    }

    private func aboveBottom(_ piece: Piece) -> Bool {
        !piece.indexes.contains { (index) -> Bool in index.row >= field.endIndex }
    }

}
