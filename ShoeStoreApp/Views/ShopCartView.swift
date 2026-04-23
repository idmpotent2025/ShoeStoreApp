//
//  ShopCartView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ShopCartView: View {
    @StateObject private var shopViewModel = ShopViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showCart = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // Brand Header with Cart - One Line
                        HStack(spacing: 12) {
                            Text(shopViewModel.brandLabel)
                                .font(shopViewModel.brandFontStyle.font(size: 24, weight: .bold))
                                .foregroundColor(.theme.text)

                            Spacer()

                            // Cart Icon
                            Button(action: {
                                showCart = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 28))
                                        .foregroundColor(.black)

                                    if cartViewModel.totalItems > 0 {
                                        Text("\(cartViewModel.totalItems)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(minWidth: 18, minHeight: 18)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 10, y: -8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        // Products Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(shopViewModel.filteredProducts) { product in
                                ProductCard(product: product) {
                                    cartViewModel.addToCart(product: product)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .sheet(isPresented: $showCart) {
                CartView()
                    .environmentObject(cartViewModel)
            }
        }
        .onAppear {
            shopViewModel.loadProducts()
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let onAddToCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            Image(product.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 140)
                .clipped()
                .cornerRadius(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )

            // Product Info
            HStack(alignment: .center, spacing: 8) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
                    .lineLimit(1)

                Spacer()

                Text(product.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
            }

            // Add to Cart Button
            Button(action: onAddToCart) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add")
                        .fontWeight(.medium)
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color(hex: "#E8E8E8"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
