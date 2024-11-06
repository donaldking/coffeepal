//
//  OrderAggregate.swift
//  CoffeePal
//
//  Created by Mac User on 01/10/2024.
//

import Foundation

enum OrderAggregateState {
    case idle
    case loading
    case done
    case error
}

@Observable
final class OrderAggregate: @unchecked Sendable {
    static let shared = OrderAggregate()
    private(set) var orders: [Order] = []
    private(set) var loadingState: OrderAggregateState = .idle
    private let getOrdersUseCase: GetOrderUseCase
    private let placeOrderUseCase: PlaceOrderUseCase
    
    init(getOrdersUseCase: GetOrderUseCase = GetOrderUseCase(),
         placeOrderUseCase: PlaceOrderUseCase = PlaceOrderUseCase(),
         orders: [Order] = []) {
        self.getOrdersUseCase = getOrdersUseCase
        self.placeOrderUseCase = placeOrderUseCase
        self.orders = orders
    }
    
    func fetchOrders() async {
        loadingState = .loading
        do {
            orders = try await getOrdersUseCase.execute(fromCache: false)
            loadingState = .done
        } catch {
            print(#file, #line, error)
            loadingState = .error
        }
    }
    
    func placeOrder(_ order: Order) async {
        loadingState = .loading
        do {
            if let placedOrder = try await placeOrderUseCase.execute(order) {
                orders.append(placedOrder)
                loadingState = .done
            } else {
                loadingState = .error
            }
        } catch {
            print(#file, #line, error)
            loadingState = .error
        }
    }
}
