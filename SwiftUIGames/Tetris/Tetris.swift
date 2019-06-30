//
//  Tetris.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-21.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

struct TetrisPlayfieldIndex: Equatable {
    let row: Int
    let column: Int
}

typealias TetrisPlayfield = [[Tetromino?]]
extension TetrisPlayfield {
    static let rows = 20
    static let columns = 10

    static var empty: TetrisPlayfield {
        let row = Array<Tetromino?>(repeating: nil, count: columns)
        return Array(repeating: row, count: rows)
    }

    subscript(_ index: TetrisPlayfieldIndex) -> Tetromino? {
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

struct Tetris {
    enum State {
        case playing
        case gameOver
    }

    static var rows: Int { TetrisPlayfield.rows }
    static var columns: Int { TetrisPlayfield.columns}

    private(set) var currentTetromino = Tetromino.random()
    private(set) var nextTetromino = Tetromino.random()

    private var currentPosition = TetrominoPosition()
    private var playfield: [[Tetromino?]] = .empty

    subscript(_ index: TetrisPlayfieldIndex) -> Tetromino? {
        if currentTetromino.playfieldIndexes(at: currentPosition).contains(index) {
            return currentTetromino
        } else {
            return playfield[index]
        }
    }

    private(set) var state: State = .playing

    // MARK: - Game logic

    mutating func newGame() {
        playfield = .empty
        currentPosition = TetrominoPosition()
        currentTetromino = Tetromino.random()
        nextTetromino = Tetromino.random()
        state = .playing
    }

    mutating func tick() {
        guard state == .playing else { return }
        let newPosition = currentPosition.translate(rowOffset: 1)
        guard isValidPosition(newPosition) else {
            handleTetrominoLock()
            return
        }
        currentPosition = newPosition
    }

    // MARK: - Controls

    mutating func moveLeft() {
        guard state == .playing else { return }
        let newPosition = currentPosition.translate(columnOffset: -1)
        guard isValidPosition(newPosition) else { return }
        currentPosition = newPosition
    }

    mutating func moveRight() {
        guard state == .playing else { return }
        let newPosition = currentPosition.translate(columnOffset: 1)
        guard isValidPosition(newPosition) else { return }
        currentPosition = newPosition
    }

    mutating func rotateCW() {
        guard state == .playing else { return }
        let newPosition = currentPosition.rotateCW()
        guard isValidPosition(newPosition) else { return }
        currentPosition = newPosition
    }

    mutating func drop() {
        guard state == .playing else { return }
        var dropPosition = currentPosition
        for offset in 1..<Tetris.rows {
            let newPosition = currentPosition.translate(rowOffset: offset, columnOffset: 0)
            guard isValidPosition(newPosition) else { break }
            dropPosition = newPosition
        }

        currentPosition = dropPosition
    }

    // MARK: - Internals

    private mutating func handleTetrominoLock() {
        _lockCurrentTetromino()
        _removeCompletedRows()
        _addTetromino()
    }

    private mutating func _lockCurrentTetromino() {
        for index in currentTetromino.playfieldIndexes(at: currentPosition) {
            playfield[index] = currentTetromino
        }
    }

    private mutating func _removeCompletedRows() {
        for rowIndex in 0..<playfield.endIndex {
            let row = playfield[rowIndex]
            guard !row.contains(nil) else { continue }

            for rowIndex in (1...rowIndex).reversed() {
                playfield[rowIndex] = playfield[rowIndex - 1]
            }
        }
    }

    private mutating func _addTetromino() {
        let newPosition = TetrominoPosition()
        currentTetromino = nextTetromino

        guard isValidPosition(newPosition, for: nextTetromino) else {
            if isValidPosition(newPosition.translate(rowOffset: -1)) {
                currentPosition = newPosition.translate(rowOffset: -1)
            } else {
                currentPosition = newPosition.translate(rowOffset: -2)
            }

            state = .gameOver
            return
        }

        currentPosition = newPosition

        nextTetromino = Tetromino.random()
    }

    private func isValidPosition(_ position: TetrominoPosition, for tetromino: Tetromino? = nil) -> Bool {
        let indexes = (tetromino ?? currentTetromino).playfieldIndexes(at: position)
        return !indexes.contains { (index) -> Bool in
            return index.row >= Tetris.rows
                || index.row < 0
                || index.column >= Tetris.columns
                || index.column < 0
                || playfield[index] != nil
        }
    }
}
