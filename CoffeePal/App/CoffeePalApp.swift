//
//  CoffeePalApp.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import SwiftUI

@main
struct CoffeePalApp: App {
    @State private var orderAggregate = OrderAggregate.shared
    var body: some Scene {
        WindowGroup {
            OrderListScreen()
                .environment(orderAggregate)
        }
    }
}
