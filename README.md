# CoffeePal
CoffeePal is a SwiftUI-based iOS application that enables users to place and view coffee orders. Built on a modular, clean architecture, it separates concerns across multiple domain layers, making the codebase scalable, testable, and maintainable. This README provides an in-depth overview of the architecture, data flow, and design patterns, with code snippets that demonstrate how the app's layers interact.

## Table of Contents
- Architecture Overview
- Domain Layers and Their Responsibilities
  - Presentation Layer
  - Domain Layer
  - Data Layer
  - Service Layer
- Key Components and Patterns
  - Use Cases
  - Aggregate Models
  - Data Transfer Objects (DTOs)
- Data Flow Across Layers
- SwiftUI Observation Framework

### Architecture Overview
CoffeePal is built following Clean Architecture, which enforces a strict separation of concerns by dividing the code into layers. Each layer has well-defined responsibilities, minimizing dependencies between them and creating a flexible and maintainable codebase. The app’s main layers include:

- **Presentation Layer**: Manages the user interface (UI) and user interactions using SwiftUI.
- **Domain Layer**: Contains core business logic, including UseCases and aggregates that manage data consistency.
- **Data Layer**: Handles data fetching, storage, and conversion, including repositories and Data Transfer Objects (DTOs).

### Domain Layers and Their Responsibilities
#### Presentation Layer
The **Presentation Layer** consists of SwiftUI views that display data and handle user interactions. It uses the SwiftUI Observation Framework, introduced in iOS 17, which simplifies state management with the ``Observable`` protocol.

Each view retrieves data through ``UseCases`` and ``aggregates`` in the ``Domain Layer``. By keeping business logic in UseCases, the UI remains focused solely on rendering and responding to user inputs.

**Example: OrderListScreen**

The following trimmed down code snippet shows ``OrderListScreen``, a view responsible for displaying a list of coffee orders. It retrieves data from the ``OrderAggregate``, an object that combines related entities and UseCases.

```Swift
import SwiftUI

struct OrderListScreen: View {
    @Environment(OrderAggregate.self) private var orderAggregate
    var body: some View {
        VStack {
            if orderAggregate.loadingState == .loading {
                ProgressView("Loading Orders...")
            } else if orderAggregate.orders.isEmpty {
                Text("No orders available!")
            } else {
                List(orderAggregate.orders) { order in
                    OrderCellView(order: order)
                }
            }
        }
        .onAppear {
            Task {
                await orderAggregate.fetchOrders()
            }
        }
    }
}
```
- ``OrderListScreen`` interacts with the ``OrderAggregate`` object, which uses UseCases to fetch and manage data.
- The UI automatically updates based on the ``loadingState`` and ``orders`` properties, which are managed in ``OrderAggregate`` and observed by the view.

### Domain Layer
The **Domain Laye**r contains **business logic**. It defines the core rules of the app and holds essential components like UseCases and aggregates:

- **UseCases**: Define individual business tasks, such as placing an order or retrieving order history. UseCases encapsulate logic, ensuring the presentation layer only interacts with well-defined operations.
- **Aggregates**: Aggregate models group related entities and logic to ensure data consistency. They provide a cohesive API for interacting with multiple related models, defined by their **Bounded Context**.

**Example: OrderAggregate**

``OrderAggregate`` coordinates multiple UseCases, managing the retrieval and creation of orders. It encapsulates data and business logic, offering a **unified interface** to the UI. The following is a trimmed down version of the ``OrderAggregate``

```Swift
import SwiftUI
import Observation

@Observable
class OrderAggregate {
    private(set) var orders: [Order] = []
    private(set) var loadingState: LoadingState = .idle
    private let getOrderUseCase: GetOrderUseCase
    private let placeOrderUseCase: PlaceOrderUseCase

    init(getOrderUseCase: GetOrderUseCase, placeOrderUseCase: PlaceOrderUseCase) {
        self.getOrderUseCase = getOrderUseCase
        self.placeOrderUseCase = placeOrderUseCase
    }
    
    func fetchOrders() async {
        loadingState = .loading
        do {
            orders = try await getOrderUseCase.execute()
            loadingState = .done
        } catch {
            loadingState = .error
        }
    }
    
    func placeOrder(order: Order) async {
        loadingState = .loading
        do {
            try await placeOrderUseCase.execute(order: order)
            await fetchOrders() // Refresh after placing an order
        } catch {
            loadingState = .error
        }
    }
}
```
- ``OrderAggregate`` encapsulates UseCases for fetching and placing orders.
The properties are **observed** by SwiftUI views using the SwiftUI ``Observation`` Framework, ensuring seamless updates when data changes.

### Data Layer
The **Data Layer** interacts with external data sources, such as network APIs, and manages data persistence. This layer includes:

- **Repositories**: Provide an abstraction for data access, handling communication with data sources.
- **DTOs**: Represent raw data from external sources, transformed into domain models for the Domain Layer.

**Example: OrderRepository**
``OrderRepository`` handles the retrieval and storage of order data. It conforms to ``OrderRepositoryProtocol`` to maintain flexibility, allowing for mock implementations during testing.

```Swift
import Foundation

actor OrderRepository: OrderRepositoryProtocol {
    private var orderStore: [OrderDto] = []
    private let apiClient: CoffeePalAPIProtocol

    init(apiClient: CoffeePalAPIProtocol) {
        self.apiClient = apiClient
    }

    func fetchOrders() async throws -> [Order] {
        let dtos = try await apiClient.getOrders()
        return dtos.map { Order(from: $0) } // Convert DTOs to domain models
    }
}
```
- The repository fetches ``OrderDto`` objects from ``apiClient`` and converts them to ``Order`` domain models.
- ``OrderRepositoryProtocol`` defines the repository’s interface, enabling dependency injection and mock testing.

### Key Components and Patterns
#### Use Cases
**UseCases** encapsulate individual business processes, managing application logic and ensuring separation of concerns. Each UseCase focuses on a single responsibility, enhancing code readability and testability.

**Example: PlaceOrderUseCase**
The ``PlaceOrderUseCase`` manages the process of placing an order. It calls the ``OrderRepository`` to store the order data, encapsulating the logic within a single responsibility.

```Swift
struct PlaceOrderUseCase {
    private let orderRepository: OrderRepositoryProtocol

    init(orderRepository: OrderRepositoryProtocol) {
        self.orderRepository = orderRepository
    }
    
    func execute(order: Order) async throws {
        try await orderRepository.placeOrder(order: order)
    }
}
```
### Aggregate Models
Aggregate models, such as ``OrderAggregate``, group related entities and manage complex data relationships. Aggregates help maintain data consistency by providing a clean API that centralizes business logic.

### Data Transfer Objects (DTOs)
**DTOs** isolate the raw data format returned by APIs, transforming it into domain models. This keeps the Domain Layer independent from external data structures, making it more resilient to changes in the data source.

**Example: OrderDto**
The **OrderDto** represents an order as returned by an API. It’s transformed into an Order domain model before reaching the Domain Layer.

```Swift
struct OrderDto: Codable, Sendable {
    let id: UUID
    let name: String
    let coffeeName: String
    let total: Double
    let size: String
}

extension Order {
    init(from dto: OrderDto) {
        self.id = dto.id
        self.name = dto.name
        self.coffeeName = dto.coffeeName
        self.total = dto.total
        self.size = CoffeeSize(rawValue: dto.size) ?? .medium
    }
}
```

### Data Flow Across Layers
Data flows unidirectionally through the app, promoting modularity:
1. **Data Layer**: Repositories fetch data from APIs or databases, represented by DTOs.
2. **Domain Layer**: DTOs are converted into domain models and passed through UseCases for business logic.
3. **Presentation Layer**: SwiftUI views retrieve data from aggregates and UseCases, observing state changes to update the UI.

This structure ensures that each layer is independent, following the **Single Responsibility Principle**.

### SwiftUI Observation Framework
CoffeePal utilizes the SwiftUI Observation Framework with the ``Observable`` protocol, available from iOS 17, for state management:

- ``@State``: For managing simple, view-local state.
- ``Observable``: Simplifies observing changes in shared data without @StateObject or @ObservedObject, directly notifying SwiftUI views when data changes.
- ``@Environment``: Injects shared data objects across the view hierarchy, such as aggregates, allowing for clean dependency management.

**Example: Using ``Observable``**
The ``OrderAggregate`` class conforms to ``Observable``, allowing properties to automatically trigger updates in SwiftUI views.

```Swift
@Observable
class OrderAggregate {
    private(set) var orders: [Order] = []
    private(set) var loadingState: LoadingState = .idle
    // Functions for fetching and managing orders
}
```

In the UI:

```Swift
struct OrderListScreen: View {
    @Environment(OrderAggregate.self) private var orderAggregate

    var body: some View {
        // The UI automatically responds to changes in orderAggregate
    }
}
```

### Benefits of Using ``Observable``
- **Reduced Boilerplate**: Removes the need for ``@ObservedObject`` or ``@StateObject``, simplifying code.
- **Automatic Updates**: Changes in properties trigger **automatic** UI updates.
- **Cleaner Dependency Management**: Allows easy injection of shared data across the view hierarchy with ``@Environment``.
