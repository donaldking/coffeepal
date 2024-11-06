//
//  View+Extensions.swift
//  CoffeePal
//
//  Created by Don King on 05/11/2024.
//

import SwiftUI

extension View {
    public func centerHorizontally() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
}
