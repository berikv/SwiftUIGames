//
//  GridView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct GridView<Cell: View>: View {
    typealias CellBuilder = (_ row: Int, _ column: Int) -> Cell
    let rows: Int
    let columns: Int
    let spacing: Length
    let cellBuilder: CellBuilder
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignMent: VerticalAlignment

    init(rows: Int,
         columns: Int,
         spacing: Length = 2,
         horizontalAlignment: HorizontalAlignment = .center,
         verticalAlignMent: VerticalAlignment = .center,
         cellBuilder: @escaping CellBuilder) {
        self.rows = rows
        self.columns = columns
        self.spacing = spacing
        self.cellBuilder = cellBuilder
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignMent = verticalAlignMent
    }

    private func cellSize(inFrame size: CGSize) -> Length {
        let cellHeight = Length(size.height - spacing * Length(rows)) / Length(rows)
        let cellWidth = Length(size.width - spacing * Length(columns)) / Length(columns)
        let cellSize = min(cellHeight, cellWidth).rounded(.down)
        return max(cellSize, 0)
    }

    private func cellPositionInGrid(index: Int, size: CGSize) -> Length {
        let cellSize = self.cellSize(inFrame: size)
        let halfCellSize = cellSize / 2
        let allCellsSize = Length(index) * cellSize
        let space = Length(index) * spacing
        return halfCellSize + allCellsSize + space
    }

    private func cellOffsetX(index: Int, size: CGSize) -> Length {
        let position = cellPositionInGrid(index: index, size: size)
        let remainderWidth = size.width - frameSize(size: size).width

        switch horizontalAlignment {
        case .leading:
            return position
        case .center:
            return position + (remainderWidth / 2).rounded(.down)
        case .trailing:
            return position + remainderWidth
        default:
            return position + (remainderWidth / 2).rounded(.down)
        }
    }

    private func cellOffsetY(index: Int, size: CGSize) -> Length {
        let position = cellPositionInGrid(index: index, size: size)
        let remainderHeight = size.height - frameSize(size: size).height

        switch verticalAlignMent {
        case .top:
            return position
        case .center:
            return position + (remainderHeight / 2).rounded(.down)
        case .bottom:
            return position + remainderHeight
        default:
            return position + (remainderHeight / 2).rounded(.down)
        }
    }

    private func cellAt(row: Int, column: Int, size: CGSize) -> some View {
        self.cellBuilder(row, column)
            .frame(width: self.cellSize(inFrame: size),
                   height: self.cellSize(inFrame: size),
                   alignment: .center)
            .position(x: self.cellOffsetX(index: column, size: size),
                      y: self.cellOffsetY(index: row, size: size))
    }

    private func frameSize(size: CGSize) -> CGSize {
        let cellSize = self.cellSize(inFrame: size)
        return CGSize(width: cellSize * Length(columns) + spacing * Length(columns - 1),
                      height: cellSize * Length(rows) + spacing * Length(rows - 1))
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.rows) { row in
                ForEach(0..<self.columns) { column in
                    self.cellAt(row: row, column: column, size: geometry.size)
                }
            }
//                .frame(width: self.frameSize(size: geometry.size).width,
//                       height: self.frameSize(size: geometry.size).height,
//                       alignment: .center)
        }
    }
}
