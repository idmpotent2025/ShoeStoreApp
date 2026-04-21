//
//  ProductTileView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ProductTileView: View {
    let product: Product
    let onAddToCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)

                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.theme.accent)
            }
            .cornerRadius(8)

            // Product Name
            Text(product.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.theme.text)
                .lineLimit(2)
                .frame(height: 36, alignment: .top)

            // Product Price
            Text(product.formattedPrice)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.theme.primary)

            // Product Description
            Text(product.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)

            // Add to Cart Button
            Button(action: onAddToCart) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
