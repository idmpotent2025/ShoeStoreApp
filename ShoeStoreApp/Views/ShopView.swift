//
//  ShopView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredProducts) { product in
                                ProductTileView(product: product) {
                                    cartViewModel.addToCart(product: product)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle(AppConfiguration.load()?.branding.name ?? "Identity Architect Demo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.selectCategory(category)
                            }) {
                                HStack {
                                    Text(category.displayName)
                                    if viewModel.selectedCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(viewModel.selectedCategory.displayName)
                        }
                        .foregroundColor(.theme.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshProducts()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.theme.primary)
                    }
                }
            }
        }
    }
}
