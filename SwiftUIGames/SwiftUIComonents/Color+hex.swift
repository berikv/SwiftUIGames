//
//  Color+hex.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-30.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

extension Color {
    init(_ value: Int) {
        let red = Double(value >> 16 & 0xff) / 255.0
        let green = Double(value >> 8 & 0xff) / 255.0
        let blue = Double(value & 0xff) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
