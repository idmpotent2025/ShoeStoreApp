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

    @State private var isProductsExpanded = true
    @State private var isCartExpanded = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Products Section
                    AccordionSection(
                        title: "Products",
                        badge: "\(shopViewModel.filteredProducts.count)",
                        isExpanded: $isProductsExpanded
                    ) {
                        VStack(spacing: 16) {
                            // Category Filter
                            CategoryFilterView(selectedCategory: $shopViewModel.selectedCategory)
                                .padding(.horizontal)

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
                    }

                    // Cart Section
                    AccordionSection(
                        title: "Cart",
                        badge: "\(cartViewModel.totalItems)",
                        isExpanded: $isCartExpanded
                    ) {
                        Group {
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
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.theme.background.ignoresSafeArea())
        }
        .onAppear {
            shopViewModel.loadProducts()
        }
    }
}

// MARK: - Accordion Section

struct AccordionSection<Content: View>: View {
    let title: String
    let badge: String
    @Binding var isExpanded: Bool
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.text)

                    if !badge.isEmpty && badge != "0" {
                        Text(badge)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.theme.accent)
                            .cornerRadius(10)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.theme.accent)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding()
                .background(Color.white)
            }
            .buttonStyle(PlainButtonStyle())

            // Content
            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
        }
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: ProductCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? Color.theme.accent
                                    : Color.gray.opacity(0.15)
                            )
                            .foregroundColor(
                                selectedCategory == category
                                    ? .white
                                    : .theme.text
                            )
                            .cornerRadius(20)
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)

                Image(systemName: "bag.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.theme.primary.opacity(0.3))
            }

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
        .background(Color.white)
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
        .background(Color.white)
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
