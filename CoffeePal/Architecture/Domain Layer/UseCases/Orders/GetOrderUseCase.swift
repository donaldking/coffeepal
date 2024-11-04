//
//  GetOrderUseCase.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

struct GetOrderUseCase: Sendable {
    private var orderRepository: any OrderRepositoryProtocol
    
    init(repository: some OrderRepository = OrderRepository(), orders: [Order] = []) {
        self.orderRepository = repository
    }
    
    func execute(fromCache cache: Bool = false) async throws -> [Order] {
        do {
            if cache {
                return try await orderRepository.readAll()
            } else {
                return try await orderRepository.fetchAll()
            }
        } catch {
            throw error
        }
    }
}
