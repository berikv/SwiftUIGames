//
//  Matrix.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-07-07.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

struct Matrix<Element> {
    private var storage = [Element]()
    let rowCount: Int
    let columnCount: Int

    init(repeating: Element, rowCount: Int, columnCount: Int) {
        self.storage = Array(repeating: repeating, count: rowCount * columnCount)
        self.rowCount = rowCount
        self.columnCount = columnCount
    }

    init(rowCount: Int, columnCount: Int, makeElement: (Int, Int) -> Element) {
        self.storage = Array<Element>()
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.storage.reserveCapacity(columnCount * rowCount)
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                storage.append(makeElement(row, column))
            }
        }
    }

    subscript(row: Int, column: Int) -> Element {
        get { storage[row * columnCount + column] }
        set { storage[row * columnCount + column] = newValue }
    }

    var rows: [[Element]] {
        (0..<rowCount).map { row in
            (0..<columnCount).map { column in self[row, column] }
        }
    }

    func map<T>(handler: (Element) -> T) -> Matrix<T> {
        Matrix<T>(rowCount: rowCount, columnCount: columnCount) { (row, column) -> T in
            handler(self[row, column])
        }
    }

    func count(where condition: (Element) -> Bool) -> Int {
        var counter = 0
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                if condition(self[row, column]) { counter += 1 }
            }
        }
        return counter
    }
}
