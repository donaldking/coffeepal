//
//  DefaultOrderRepository.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

protocol OrderRepositoryProtocol: Sendable {
    func readAll() async throws -> [Order]
    func fetchAll() async throws -> [Order]
    func placeOrder(_ order: Order) async throws -> Order?
}

actor OrderRepository: OrderRepositoryProtocol {
    private var apiClient: CoffeePalAPIProtocol
    private var orderStore: [Order] = []
    
    init(apiClient: some CoffeePalAPIProtocol = CoffeePalAPI()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public methods
    func readAll() async -> [Order] {
        return orderStore
    }
    
    func placeOrder(_ order: Order) async throws -> Order? {
        do {
            if let orderDto = try await apiClient.placeOrder(OrderDto(from: order)) {
                let newOrder = Order(from: orderDto)
                orderStore.append(newOrder)
            }
        } catch {
            print("OrderRepository error: \(error)")
            throw error
        }
        return nil
    }
    
    func fetchAll() async throws -> [Order] {
        do {
            let orderDtos = try await apiClient.getOrders()
            orderStore = orderDtos.map { dto in Order(from: dto) }
            return orderStore
        } catch {
            throw error
        }
    }
}
