
import Foundation

public struct Position: Hashable {
    public var x: Int
    public var y: Int

    static func +(lhs: Position, rhs: (x: Int, y: Int)) -> Position {
        return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

public struct Size: Hashable {
    public var width: Int
    public var height: Int
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public enum Direction {
    case up, down, left, right
}

public enum SnailError: Error {
    case invalidMove
}

public enum SnailStatus {
    case playing
    case won
    case lost
}

public struct Snail {
    public typealias Move = Direction

    public let size: Size

    public private(set) var status = SnailStatus.playing
    public private(set) var snake: [Position]
    public private(set) var foodPosition: Position

    public var head: Position { return snake.last! }
    public var score: Int { return snake.count }

    private let allPositions: Set<Position>

    public init(size: Size = Size(width: 25, height: 25)) {
        self.size = size
        self.snake = [Position(x: 2, y: 2), Position(x: 3, y: 2), Position(x: 4, y: 2)]
        self.foodPosition = Position(x: 0, y: 0)

        if let allPositions = Cache.allPositions[size] {
            self.allPositions = allPositions
        } else {
            var allPositions = Set<Position>()
            (0 ..< size.width).forEach { x in
                (0 ..< size.height).forEach { y in
                    allPositions.insert(Position(x: x, y: y))
                }
            }
            self.allPositions = allPositions
            Cache.allPositions[size] = allPositions
        }

        selectFoodPosition()
    }

    private func positionAfter(_ move: Move) -> Position? {
        let newPosition: Position
        switch move {
        case .up:    newPosition = head + (x:  0, y: -1)
        case .down:  newPosition = head + (x:  0, y:  1)
        case .right: newPosition = head + (x:  1, y:  0)
        case .left:  newPosition = head + (x: -1, y:  0)
        }

        if     newPosition.x < 0
            || newPosition.y < 0
            || newPosition.x >= size.width
            || newPosition.y >= size.height {
            return nil
        }

        return newPosition
    }

    public mutating func doMove(_ move: Direction)  {
        if status != .playing {
            return
        }

        guard let newPosition = positionAfter(move),
            !snake.contains(newPosition) else {
                let didWin = snake.count == size.width * size.height
                self.status = didWin ? .won : .lost
                return
        }

        self.snake.append(newPosition)

        if newPosition == foodPosition {
            self.selectFoodPosition()
        } else {
            self.snake.removeFirst()
        }
    }

    private mutating func selectFoodPosition() {
        let possibleFoodPositions = allPositions.subtracting(snake)
        foodPosition = possibleFoodPositions.randomElement()!
    }
}

private class Cache {
    static var allPositions = [Size: Set<Position>]()
}
