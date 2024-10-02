//
//  GetOrderUseCase.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

struct GetOrderUseCase: Sendable {
    private var orderRepository: any OrderRepositoryProtocol
    
    init(repository: OrderRepository = OrderRepository(), orders: [Order] = []) {
        self.orderRepository = repository
    }
    
    func execute() async throws -> [Order] {
        do {
            return try await orderRepository.readAll()
        } catch {
            throw error
        }
    }
}
