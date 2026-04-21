//
//  CartView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showCheckoutAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        // Current Cart Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Cart")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.text)
                                .padding(.horizontal)

                            if cartViewModel.cartItems.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("Your cart is empty")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(cartViewModel.cartItems) { item in
                                    CartItemRow(item: item)
                                }

                                // Subtotal
                                HStack {
                                    Text("Subtotal")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(cartViewModel.formattedSubtotal)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.theme.primary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)

                                // Checkout Button
                                Button(action: {
                                    showCheckoutAlert = true
                                }) {
                                    Text("Checkout")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.theme.accent)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Order History Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Order History")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.text)
                                .padding(.horizontal)

                            if cartViewModel.orderHistory.isEmpty {
                                Text("No previous orders")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(cartViewModel.orderHistory) { order in
                                    OrderHistoryRow(order: order)
                                }
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.large)
            .alert("Checkout", isPresented: $showCheckoutAlert) {
                Button("OK") {
                    cartViewModel.checkout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Order placed successfully! Total: \(cartViewModel.formattedSubtotal)")
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Product Image
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.theme.accent)
            }
            .cornerRadius(8)

            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.theme.text)

                Text(item.product.formattedPrice)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.theme.primary)

                HStack(spacing: 12) {
                    // Quantity Controls
                    HStack(spacing: 8) {
                        Button(action: {
                            cartViewModel.decrementQuantity(item: item)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.theme.accent)
                                .font(.system(size: 24))
                        }

                        Text("\(item.quantity)")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(minWidth: 30)

                        Button(action: {
                            cartViewModel.incrementQuantity(item: item)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.theme.accent)
                                .font(.system(size: 24))
                        }
                    }

                    Spacer()

                    // Subtotal
                    Text("$\(String(format: "%.2f", item.subtotal))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.theme.primary)
                }
            }

            // Remove Button
            Button(action: {
                cartViewModel.removeFromCart(item: item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct OrderHistoryRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order #\(order.id.uuidString.prefix(8))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.theme.text)

                Spacer()

                Text(order.status.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status))
                    .cornerRadius(6)
            }

            Text(order.formattedDate)
                .font(.system(size: 12))
                .foregroundColor(.gray)

            HStack {
                Text("\(order.items.count) item(s)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Spacer()

                Text(order.formattedTotal)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.theme.primary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func statusColor(for status: Order.OrderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .processing:
            return .blue
        case .shipped:
            return .purple
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
}
