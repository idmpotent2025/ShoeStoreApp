//
//  ShopViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class ShopViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = true
    @Published var selectedCategory: ProductCategory = .dresses
    @Published var brandLabel: String = "Shoe Store"
    @Published var brandFontStyle: BrandFontStyle = .system

    private var configuration: AppConfiguration?
    private let preferencesManager = PreferencesManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to PreferencesManager for category, brand label, and font style
        preferencesManager.$selectedCategory
            .assign(to: &$selectedCategory)

        preferencesManager.$brandLabel
            .assign(to: &$brandLabel)

        preferencesManager.$brandFontStyle
            .assign(to: &$brandFontStyle)

        loadProducts()
    }

    func loadProducts() {
        isLoading = true

        if let config = AppConfiguration.load() {
            self.configuration = config
            self.products = config.products
        } else {
            print("Failed to load products from configuration")
            self.products = []
        }

        isLoading = false
    }

    var filteredProducts: [Product] {
        return products.filter { $0.category == selectedCategory }
    }

    func refreshProducts() {
        loadProducts()
    }
}
