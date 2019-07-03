//
//  ContentView.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TicTacToeView()) { Text("Tic tac toe") }
                NavigationLink(destination: LinesWelcomeView()) { Text("Lines") }
                NavigationLink(destination: SnakeView()) { Text("Snake") }
                NavigationLink(destination: TetrisView()) { Text("Tetris") }
                NavigationLink(destination: MineSweeperView()) { Text("Mine sweeper") }
            }
                .navigationBarTitle(Text("Games"))
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
