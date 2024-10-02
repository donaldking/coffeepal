//
//  OrderDto.swift
//  CoffeePal
//
//  Created by Mac User on 27/09/2024.
//

import Foundation

struct OrderDto: Codable, Sendable {
    private(set) var id: Int?
    private(set) var name: String?
    private(set) var coffeeName: String?
    private(set) var total: Float?
    private(set) var size: String?
}

extension OrderDto {
    init(from order: Order) {
        self.id = order.id
        self.name = order.name
        self.coffeeName = order.coffeeName
        self.total = order.total
        self.size = order.size.rawValue
    }
}
