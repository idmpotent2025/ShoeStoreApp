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
    @Published var selectedCategory: ProductCategory = .dresses {
        didSet {
            saveSelectedCategory()
        }
    }

    private var configuration: AppConfiguration?
    private let categoryKey = "selectedProductCategory"

    init() {
        loadSelectedCategory()
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

    func selectCategory(_ category: ProductCategory) {
        selectedCategory = category
    }

    private func saveSelectedCategory() {
        UserDefaults.standard.set(selectedCategory.rawValue, forKey: categoryKey)
    }

    private func loadSelectedCategory() {
        if let savedCategory = UserDefaults.standard.string(forKey: categoryKey),
           let category = ProductCategory(rawValue: savedCategory) {
            selectedCategory = category
        }
    }

    func refreshProducts() {
        loadProducts()
    }
}
