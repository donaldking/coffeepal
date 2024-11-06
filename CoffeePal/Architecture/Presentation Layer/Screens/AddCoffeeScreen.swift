//
//  AddCoffeeScreen.swift
//  CoffeePal
//
//  Created by Don King on 05/11/2024.
//

import SwiftUI

struct AddCoffeeScreen: View {
    @Environment(OrderAggregate.self) private var orderAggregate
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var coffeeName: String = ""
    @State private var price: String = ""
    @State private var size: CoffeeSize = .medium
    
    var body: some View {
        Form {
            TextField("Name", text: $name).accessibilityIdentifier("name")
            TextField("Coffee Name", text: $coffeeName).accessibilityIdentifier("coffeeName")
            TextField("Price", text: $price).accessibilityIdentifier("price")
            Picker("Size", selection: $size) {
                ForEach(CoffeeSize.allCases, id: \.rawValue) { size in
                    Text(size.rawValue).tag(size)
                }
            }.pickerStyle(.segmented)
            Button("Place Order") {
                let order = Order(id: 1, name: name, coffeeName: coffeeName, total: Float(price) ?? 0, size: size)
                Task {
                    await orderAggregate.placeOrder(order)
                    dismiss()
                }
            }.accessibilityIdentifier("placeOrderButton")
                .centerHorizontally()
        }
    }
}

#Preview {
    AddCoffeeScreen().environment(OrderAggregate())
}
