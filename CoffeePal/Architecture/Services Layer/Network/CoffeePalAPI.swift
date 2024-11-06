//
//  CoffeePalAPI.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

enum CoffeePalAPIError: Error, LocalizedError {
    case invalidURL
    case badRequest
    case decodingError
    
    var errorDescription: String {
        switch self {
        case .invalidURL: "Url is invalid"
        case .badRequest: "Bad request"
        case .decodingError: "Unable to decode response data"
        }
    }
}

protocol CoffeePalAPIProtocol {
    func getOrders() async throws -> [OrderDto]
    func placeOrder(_ orderDto: OrderDto) async throws -> OrderDto?
}

struct CoffeePalAPI: CoffeePalAPIProtocol {
    func getOrders() async throws -> [OrderDto] {
        guard let url = URL(string: Constants.baseURL + Constants.Paths.getOrdersPath) else { throw CoffeePalAPIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else { throw CoffeePalAPIError.badRequest }
        guard let orderDtos = try? JSONDecoder().decode([OrderDto].self, from: data) else { throw CoffeePalAPIError.decodingError }
        return orderDtos
    }
    
    func placeOrder(_ orderDto: OrderDto) async throws -> OrderDto? {
        guard let url = URL(string: Constants.baseURL + Constants.Paths.placeOrderPath) else { throw CoffeePalAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(orderDto)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else { throw CoffeePalAPIError.badRequest }
        let placedOrderDto = try? JSONDecoder().decode(OrderDto.self, from: data)
        return placedOrderDto
    }
}
