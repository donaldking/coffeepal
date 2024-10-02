//
//  DefaultOrderRepository.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

protocol OrderRepositoryProtocol: Sendable {
    func readAll() async throws -> [Order]
    func placeOrder(_ order: Order) async throws -> Order
}

actor OrderRepository: OrderRepositoryProtocol {
    private var apiClient: CoffeePalAPIProtocol
    private var orderStore: [Order] = []
    
    init(apiClient: some CoffeePalAPIProtocol = CoffeePalAPI()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public methods
    func readAll() async -> [Order] {
        if !orderStore.isEmpty {
            return orderStore
        } else {
            do {
                let orderDtos = try await fetch()
                orderStore = orderDtos.map { dto in Order(from: dto) }
            } catch {
                print("readAll error: \(error)")
            }
        }
        return orderStore
    }
    
    func placeOrder(_ order: Order) async throws -> Order {
        do {
            let orderDto = try await apiClient.placeOrder(OrderDto(from: order))
            let newOrder = Order(from: orderDto)
            orderStore.append(newOrder)
            return newOrder
        } catch {
            print("OrderRepository error: \(error)")
            throw error
        }
    }
    
    // MARK: - Private methods
    private func fetch() async throws -> [OrderDto] {
        do {
            return try await apiClient.getOrders()
        } catch {
            print(error)
            throw error
        }
    }
}