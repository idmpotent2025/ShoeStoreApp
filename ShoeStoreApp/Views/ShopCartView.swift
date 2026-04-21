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

    @State private var selectedTab: ShopTab = .products

    enum ShopTab {
        case products
        case cart
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack(spacing: 0) {
                    // Products Tab
                    Button(action: {
                        withAnimation {
                            selectedTab = .products
                        }
                    }) {
                        HStack {
                            Text("Products")
                                .font(.subheadline)
                                .fontWeight(selectedTab == .products ? .semibold : .regular)

                            if shopViewModel.filteredProducts.count > 0 {
                                Text("\(shopViewModel.filteredProducts.count)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.theme.accent)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == .products ? Color(hex: "#707070") : Color(hex: "#B0B0B0"))
                        .foregroundColor(selectedTab == .products ? .white : Color(hex: "#5A5A5A"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTab == .products ? Color.theme.accent : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Cart Tab
                    Button(action: {
                        withAnimation {
                            selectedTab = .cart
                        }
                    }) {
                        HStack {
                            Text("Cart")
                                .font(.subheadline)
                                .fontWeight(selectedTab == .cart ? .semibold : .regular)

                            if cartViewModel.totalItems > 0 {
                                Text("\(cartViewModel.totalItems)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.theme.accent)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == .cart ? Color(hex: "#707070") : Color(hex: "#B0B0B0"))
                        .foregroundColor(selectedTab == .cart ? .white : Color(hex: "#5A5A5A"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTab == .cart ? Color.theme.accent : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)

                Divider()

                // Content based on selected tab
                ScrollView {
                    if selectedTab == .products {
                        VStack(spacing: 16) {
                            // Category Filter
                            CategoryFilterView(selectedCategory: $shopViewModel.selectedCategory)
                                .padding(.horizontal)
                                .padding(.top, 8)

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
                        .padding(.vertical)
                    } else {
                        // Cart Content
                        if cartViewModel.cartItems.isEmpty {
                            EmptyCartView()
                                .padding()
                        } else {
                            VStack(spacing: 16) {
                                // Cart Items
                                ForEach(cartViewModel.cartItems) { item in
                                    ShopCartItemRow(item: item, cartViewModel: cartViewModel)
                                }

                                // Subtotal
                                HStack {
                                    Text("Subtotal")
                                        .font(.headline)
                                    Spacer()
                                    Text(cartViewModel.formattedSubtotal)
                                        .font(.headline)
                                        .foregroundColor(.theme.accent)
                                }
                                .padding()
                                .background(Color.theme.background)
                                .cornerRadius(12)

                                // Checkout Button
                                Button(action: {
                                    cartViewModel.checkout()
                                }) {
                                    HStack {
                                        Image(systemName: "creditcard.fill")
                                        Text("Checkout")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.theme.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }

                                // Order History
                                if !cartViewModel.orderHistory.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Order History")
                                            .font(.headline)
                                            .foregroundColor(.theme.text)

                                        ForEach(cartViewModel.orderHistory.prefix(3)) { order in
                                            ShopOrderHistoryRow(order: order)
                                        }
                                    }
                                    .padding(.top)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color.theme.background.ignoresSafeArea())
        }
        .onAppear {
            shopViewModel.loadProducts()
        }
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: ProductCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selectedCategory == category
                                    ? Color.theme.accent
                                    : Color.gray.opacity(0.1)
                            )
                            .foregroundColor(
                                selectedCategory == category
                                    ? .white
                                    : .gray
                            )
                            .cornerRadius(16)
                    }
                }
            }
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
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
                    .lineLimit(2)

                Text(product.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.theme.accent)
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

// MARK: - Cart Item Row

struct ShopCartItemRow: View {
    let item: CartItem
    @ObservedObject var cartViewModel: CartViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: "bag.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.theme.primary.opacity(0.3))
            }

            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)

                Text(item.product.formattedPrice)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Quantity Controls
            HStack(spacing: 12) {
                Button(action: {
                    cartViewModel.decrementQuantity(item: item)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.theme.accent)
                        .font(.title3)
                }

                Text("\(item.quantity)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 25)

                Button(action: {
                    cartViewModel.incrementQuantity(item: item)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.theme.accent)
                        .font(.title3)
                }

                Button(action: {
                    cartViewModel.removeFromCart(item: item)
                }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color(hex: "#E8E8E8"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Empty Cart View

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("Your cart is empty")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Add items from the products section above")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Order History Row

struct ShopOrderHistoryRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.uuidString.prefix(8))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.theme.text)

                    Text(order.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.formattedTotal)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.theme.accent)

                    Text(order.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
