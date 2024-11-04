//
//  PlaceOrderUseCase.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

struct PlaceOrderUseCase: Sendable {
    private var orderRepository: any OrderRepositoryProtocol
    
    init(orderRepository: some OrderRepositoryProtocol = OrderRepository()) {
        self.orderRepository = orderRepository
    }
    
    func execute(_ order: Order) async throws -> Order? {
        do {
            return try await orderRepository.placeOrder(order)
        } catch {
            throw error
        }
    }
}
