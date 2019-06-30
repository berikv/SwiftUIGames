//
//  Tetromino.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-29.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import Foundation

struct TetrominoPosition {
    var rotation: Int
    var rowOffset: Int
    var columnOffset: Int

    init() {
        self.rotation = 0
        self.rowOffset = 0
        self.columnOffset = 3
    }

    private init(rotation: Int, rowOffset: Int, columnOffset: Int) {
        self.rotation = rotation
        self.rowOffset = rowOffset
        self.columnOffset = columnOffset
    }

    func rotateCW() -> TetrominoPosition {
        TetrominoPosition(
            rotation: rotation + 1,
            rowOffset: rowOffset,
            columnOffset: columnOffset)
    }

    func translate(rowOffset: Int = 0, columnOffset: Int = 0) -> TetrominoPosition {
        TetrominoPosition(
            rotation: self.rotation,
            rowOffset: self.rowOffset + rowOffset,
            columnOffset: self.columnOffset + columnOffset)
    }
}

enum Tetromino: CaseIterable {
    case i, t, l, o, j, z, s

    static func random() -> Tetromino { Tetromino.allCases.randomElement()! }

    func playfieldIndexes(at position: TetrominoPosition) -> [TetrisPlayfieldIndex] {
        return indexes[position.rotation % indexes.endIndex]
            .map { index in
                TetrisPlayfieldIndex(row: index.row + position.rowOffset,
                           column: index.column + position.columnOffset)
        }
    }

    private var indexes: [[TetrisPlayfieldIndex]] {
        switch self {
        case .i: return indexesI
        case .t: return indexesT
        case .o: return indexesO
        case .l: return indexesL
        case .j: return indexesJ
        case .s: return indexesS
        case .z: return indexesZ
        }
    }
}

private let indexesI = [
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 0, column: 3),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 2),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 2),
        TetrisPlayfieldIndex(row: 2, column: 2),
    ]
]

private let indexesT = [
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
    [
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 0),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
]

private let indexesO = [
    [
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ]
]

private let indexesL = [
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 0),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 0),
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
    [
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 0),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
]

private let indexesJ = [
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 0),
    ],
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 1, column: 0),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 1),
        TetrisPlayfieldIndex(row: -1, column: 2),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
]

private let indexesS = [
    [
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 0),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
]

private let indexesZ = [
    [
        TetrisPlayfieldIndex(row: 0, column: 0),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 1),
        TetrisPlayfieldIndex(row: 1, column: 2),
    ],
    [
        TetrisPlayfieldIndex(row: -1, column: 2),
        TetrisPlayfieldIndex(row: 0, column: 1),
        TetrisPlayfieldIndex(row: 0, column: 2),
        TetrisPlayfieldIndex(row: 1, column: 1),
    ],
]
