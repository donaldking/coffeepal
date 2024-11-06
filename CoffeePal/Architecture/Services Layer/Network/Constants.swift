//
//  Constants.swift
//  CoffeePal
//
//  Created by Mac User on 28/09/2024.
//

import Foundation

struct Constants {
    static var baseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String else { fatalError("Unable to find API_URL key") }
        return url
    }
    
    private init () {}
    
    struct Paths {
        static let getOrdersPath = "/orders"
        static let placeOrderPath = "/orders"
        
        private init () {}
    }
}
