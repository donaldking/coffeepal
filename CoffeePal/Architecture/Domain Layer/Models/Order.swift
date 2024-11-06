//
//  Order.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

/**
 API Endpoints
 1. GET  https://island-bramble.glitch.me/test/orders
 2. POST https://island-bramble.glitch.me/test/orders
    Body:
     {
     "name": "John Doe",
     "coffeeName": "Hot Coffee",
     "total": 4.50,
     "size": "Medium"
     }
 3. DELETE: https://island-bramble.glitch.me/test/orders/:id
 4. PUT: https://island-bramble.glitch.me/test/orders/:id
    Body:
     {
     "name": "John Doe Edit",
     "coffeeName": "Hot Coffee Edit",
     "total": 2.50,
     "size": "Small"
     }
**/

enum CoffeeSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

struct Order: Identifiable, Sendable {
    private(set) var id: Int?
    private(set) var name: String
    private(set) var coffeeName: String
    private(set) var total: Float
    private(set) var size: CoffeeSize
}

// MARK: - Extensions
extension Order {
    init(from dto: OrderDto) {
        self.id = dto.id ?? 0
        self.name = dto.name ?? ""
        self.coffeeName = dto.coffeeName ?? ""
        self.total = dto.total ?? 0.0
        self.size = CoffeeSize(rawValue: dto.size ?? "small") ?? .small
    }
}
