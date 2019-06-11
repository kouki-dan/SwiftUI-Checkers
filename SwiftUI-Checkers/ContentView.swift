//
//  ContentView.swift
//  SwiftUI-Checkkers
//
//  Created by Kouki Saito on 2019/06/06.
//  Copyright © 2019 Kouki Saito. All rights reserved.
//

import SwiftUI

enum Piece: Int {
    case red
    case queenRed
    case black
    case queenBlack
}

enum Background {
    case black
    case white
}

struct Square: Identifiable {
    let id = UUID()

    let x: Int
    let y: Int
    let background: Background
    var piece: Piece?
    var selecting: Bool

    mutating func advancePiece() {
        switch piece {
        case .none:
            self.piece = Piece(rawValue: 0)
        case .some(let piece):
            self.piece = Piece(rawValue: piece.rawValue + 1)
        }
    }

    var view: some View {
        let backgroundColor: Color
        let pieceColor: Color?
        let isPromoted: Bool
        let squareBorder: Color

        switch background {
        case .black:
            backgroundColor = .black
        case .white:
            backgroundColor = .gray
        }

        if let piece = piece {
            switch piece {
            case .black:
                pieceColor = .blue
                isPromoted = false
            case .queenBlack:
                pieceColor = .blue
                isPromoted = true
            case .red:
                pieceColor = .red
                isPromoted = false
            case .queenRed:
                pieceColor = .red
                isPromoted = true
            }
        } else {
            pieceColor = nil
            isPromoted = false
        }

        if selecting {
            squareBorder = .yellow
        } else {
            squareBorder = .clear
        }


        return ZStack {
            Rectangle()
                .foregroundColor(backgroundColor)
                .overlay(Rectangle().stroke(squareBorder, lineWidth: 2))
            if pieceColor != nil {
                Circle()
                    .foregroundColor(pieceColor!)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .overlay(Circle().stroke(isPromoted ? Color.white : Color.clear, lineWidth: 2).padding(6))
                    .padding(4)
            }
        }
    }
}

struct Row: Identifiable {
    let id = UUID()
    var row: [Square]

    init(row: [Square]) {
        self.row = row
    }
}

struct Checker {
    var board: [Row]

    init() {
        board = (0..<8).map { y in
            Row(row: (0..<8).map { x in
                if (x + y) % 2 == 0 {
                    return Square(x: x, y: y, background: .white, piece: nil, selecting: false)
                } else {
                    if y <= 2 {
                        return Square(x: x, y: y, background: .black, piece: .black, selecting: false)
                    } else if y <= 4 {
                        return Square(x: x, y: y, background: .black, piece: nil, selecting: false)
                    } else {
                        return Square(x: x, y: y, background: .black, piece: .red, selecting: false)
                    }
                }
            })
        }
    }

    func searchSelectingSquare() -> Square? {
        for y in 0..<8 {
            for x in 0..<8 {
                if board[y].row[x].selecting == true {
                    return board[y].row[x]
                }
            }
        }
        return nil
    }

    mutating func tapped(square: Square) {
        let beforeSelectingSquare = searchSelectingSquare()

        board[square.y].row[square.x].selecting = true

        if let beforeSelectingSquare = beforeSelectingSquare {
            board[beforeSelectingSquare.y].row[beforeSelectingSquare.x].selecting = false
            let beforeSquare = board[beforeSelectingSquare.y].row[beforeSelectingSquare.x]
            let currentSquare = board[square.y].row[square.x]

            // TODO Confirm saure is black (Checkers piece must move on black)

            if beforeSquare.id == currentSquare.id {
                // If before position and current position is same, change piece type
                board[beforeSelectingSquare.y].row[beforeSelectingSquare.x].advancePiece()
            } else if currentSquare.piece == nil && beforeSquare.piece != nil {
                // Move piece to (square.x, square.y)
                // If piece is already placed at this position, do nothing.
                board[beforeSelectingSquare.y].row[beforeSelectingSquare.x].piece = nil
                board[square.y].row[square.x].piece = beforeSquare.piece
            }

            // TODO: Prohivit the move without Checkers rule
            // - must move diagonally forward before promoting
            // - after promoting, can move backward
            // - and the other! (Many rules exist)
            // TODO: Auto-Promote and Auto-Removal any pieces on rule of Checkers
        }
    }

    mutating func longPressed(square: Square) {
        board[square.y].row[square.x].piece = nil
    }
}


struct ContentView : View {
    @State var checker = Checker()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(self.checker.board) { row in
                HStack(spacing: 0) {
                    ForEach(row.row) { square in
                        square.view
                            .tapAction {
                                self.checker.tapped(square: square)
                            }
                            .longPressAction({
                                self.checker.longPressed(square: square)
                            })
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
