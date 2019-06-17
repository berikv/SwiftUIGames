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
                NavigationButton(destination: SnailView()) {
                    Text("Snail")
                }
                NavigationButton(destination: TicTacToeView()) {
                    Text("Tic tac toe")
                }
                NavigationButton(destination: LinesWelcomeView()) {
                    Text("Lines")
                }
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
