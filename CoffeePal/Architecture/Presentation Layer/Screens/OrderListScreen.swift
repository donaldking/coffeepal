//
//  OrderListScreen.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import SwiftUI

struct OrderListScreen: View {
    @Environment(OrderAggregate.self) private var orderAggregate
    @State private var url =
        Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String

    var body: some View {
        NavigationStack {
            VStack {
                if orderAggregate.loadingState == .loading {
                    VStack(alignment: .center) {
                        Spacer()
                        ProgressView()
                    }
                }
                if orderAggregate.loadingState == .done
                    && orderAggregate.orders.isEmpty
                {
                    VStack(alignment: .center) {
                        Spacer()
                        Text("No orders available!").accessibilityIdentifier(
                            "noOrdersText")
                        Spacer()
                    }
                } else {
                    List(orderAggregate.orders) { order in
                        OrderCellView(order: order)
                    }
                }
                Spacer()
            }
            .onAppear {
                Task {
                    await orderAggregate.fetchOrders()
                }
            }
            Text(url ?? "none")
            .navigationTitle("Coffee Orders")
        }
    }
}

#Preview {
    OrderListScreen().environment(OrderAggregate())
}
