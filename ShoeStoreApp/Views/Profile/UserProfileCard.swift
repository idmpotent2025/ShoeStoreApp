//
//  UserProfileCard.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct UserProfileCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.hasProfile {
                // Profile Picture
                if let pictureURL = viewModel.userPicture, let url = URL(string: pictureURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProfilePlaceholder(name: viewModel.userName)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    ProfilePlaceholder(name: viewModel.userName)
                }

                // User Name
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.text)

                // User Email
                Text(viewModel.userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Profile Data
                if !viewModel.userProfile.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ID Token Claims")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        ForEach(Array(viewModel.userProfile.keys.sorted()), id: \.self) { key in
                            HStack(alignment: .top) {
                                Text("\(key):")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .frame(width: 80, alignment: .leading)

                                Text("\(String(describing: viewModel.userProfile[key] ?? ""))")
                                    .font(.caption2)
                                    .foregroundColor(.theme.text)
                                    .lineLimit(3)

                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            } else {
                // Not Authenticated State
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))

                    Text("Not Authenticated")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("Sign in to view your profile")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct ProfilePlaceholder: View {
    let name: String

    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.theme.primary)
                .frame(width: 100, height: 100)

            Text(initials)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
