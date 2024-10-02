//
//  OrderCellView.swift
//  CoffeePal
//
//  Created by Mac User on 17/10/2024.
//

import SwiftUI

struct OrderCellView: View {
    let order: Order
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.name).accessibilityIdentifier("orderNameText")
                    .bold()
                Text("\(order.coffeeName) (\(order.size.rawValue))")
                    .accessibilityIdentifier("orderNameAndSizeText")
                    .opacity(0.5)
            }
            Spacer()
            Text("\(order.total.formatted(.currency(code: "GBP")))")
        }
    }
}

#Preview {
    let order = Order(id: 1, name: "Jane Doe", coffeeName: "Mocha", total: 3.99, size: .large)
    return OrderCellView(order: order)
}
