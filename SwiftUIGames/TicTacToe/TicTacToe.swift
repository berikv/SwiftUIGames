//
//  TicTacToe.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

extension TicTacToe.Board {
    var hasNonEmptyCells: Bool {
        self.flatMap { $0 }
            .contains(where: { $0 != .empty })
    }

    var hasEmptyCells: Bool {
        self.flatMap { $0 }
            .contains(where: { $0 == .empty })
    }

    static var empty: TicTacToe.Board {
        let line = Array<TicTacToe.Cell>(repeating: TicTacToe.Cell.empty, count: 3)
        return Array(repeating: line, count: 3)
    }

    var lineIndexes: [[TicTacToe.BoardIndex]] {
        [
            [(0, 0), (0, 1), (0, 2)],
            [(1, 0), (1, 1), (1, 2)],
            [(2, 0), (2, 1), (2, 2)],
            [(0, 0), (1, 0), (2, 0)],
            [(0, 1), (1, 1), (2, 1)],
            [(0, 2), (1, 2), (2, 2)],
            [(0, 0), (1, 1), (2, 2)],
            [(0, 2), (1, 1), (2, 0)],
        ]
    }
}

struct TicTacToe {
    enum Player: CaseIterable {
        case x, o

        static var random: Player {
            return Player.allCases.randomElement()!
        }

        var next: Player {
            switch self {
            case .x: return .o
            case .o: return .x
            }
        }

        var label: String {
            switch self {
            case .x: return "X"
            case .o: return "O"
            }
        }
    }

    enum Cell: Equatable {
        case empty, playedBy(Player)
    }

    enum GameState: Equatable {
        case duece
        case won(by: Player)
        case turn(of: Player)

        var didWin: Bool {
            switch self {
            case .won: return true
            default: return false
            }
        }
    }

    typealias BoardIndex = (row: Int, column: Int)
    typealias Board = [[Cell]]

    private var board: Board = .empty
    private(set) var state: GameState = .turn(of: Player.random)

    var winner: Player? {
        winnerInfo.map { $0.winner }
    }

    var winningLine: [BoardIndex]? {
        winnerInfo.map { $0.line }
    }

    private var winnerInfo: (line: [BoardIndex], winner: Player)? {
        for indexes in board.lineIndexes {
            let line = indexes.map { self.cellAt($0.0, $0.1) }
            switch (line[0], line[1], line[2]) {
            case let (.playedBy(p0), .playedBy(p1), .playedBy(p2))
                where p0 == p1 && p1 == p2:
                return (line: indexes, winner: p0)
            default: continue
            }
        }

        return nil
    }

    mutating func play(_ row: Int, _ column: Int) {
        // Validate
        guard case let .turn(playerWithTurn) = state else {
            return
        }

        guard board[row][column] == .empty else { return }

        // Play
        board[row][column] = .playedBy(playerWithTurn)

        // Update game state
        if let winner = winner {
            state = .won(by: winner)
            return
        }

        guard board.hasEmptyCells else {
            state = .duece
            return
        }

        state = .turn(of: playerWithTurn.next)
    }

    mutating func replay() {
        guard board.hasNonEmptyCells else { return }

        board = .empty

        switch state {
        case let .won(by: player),
             let .turn(of: player):
            state = .turn(of: player.next)
        default:
            state = .turn(of: Player.random)
        }
    }

    func cellAt(_ row: Int, _ column: Int) -> Cell {
        board[row][column]
    }
}
