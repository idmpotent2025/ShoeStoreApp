# ShoeStoreApp - iOS Shoe Shopping Application

A complete iOS shopping application built with SwiftUI featuring product browsing, cart management, and Auth0 authentication.

## Features

- **Product Catalog**: Browse 10 different shoes in a beautiful 2-column grid layout
- **Shopping Cart**: Add items, adjust quantities, and manage your cart
- **Order History**: View past orders with status tracking
- **Auth0 Authentication**: Secure login with token display
- **Configurable Branding**: Easy theme and product customization via JSON
- **Nordstrom-Inspired Design**: Professional retail aesthetic

## Requirements

- Xcode 13.0 or later
- iOS 14.0 or later
- Swift 5.5 or later
- Auth0 account (for authentication features)

## Project Structure

```
ShoeStoreApp/
├── ShoeStoreApp/
│   ├── ShoeStoreAppApp.swift          # App entry point
│   ├── Info.plist                      # App configuration
│   ├── Auth0.plist                     # Auth0 credentials
│   │
│   ├── Models/                         # Data models
│   │   ├── Product.swift
│   │   ├── CartItem.swift
│   │   ├── Order.swift
│   │   └── AppConfiguration.swift
│   │
│   ├── ViewModels/                     # Business logic
│   │   ├── ShopViewModel.swift
│   │   ├── CartViewModel.swift
│   │   └── ProfileViewModel.swift
│   │
│   ├── Views/                          # UI components
│   │   ├── ContentView.swift
│   │   ├── ShopView.swift
│   │   ├── ProductTileView.swift
│   │   ├── CartView.swift
│   │   ├── ProfileView.swift
│   │   └── Components/
│   │       └── LoadingView.swift
│   │
│   ├── Services/                       # External integrations
│   │   └── AuthService.swift
│   │
│   ├── Resources/                      # Assets and config
│   │   └── Configuration.json
│   │
│   └── Extensions/                     # Helper extensions
│       └── Color+Theme.swift
│
└── README.md
```

## Setup Instructions

### 1. Create Xcode Project

Since this is a file-based structure, you'll need to create an Xcode project:

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Fill in project details:
   - Product Name: `ShoeStoreApp`
   - Team: Your development team
   - Organization Identifier: `com.shoestore` (or your preference)
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
5. Choose the `ShoeStoreApp` directory as the location
6. Ensure "Create Git repository" is unchecked if desired

### 2. Add Files to Xcode Project

1. In Xcode, right-click on the "ShoeStoreApp" group
2. Select "Add Files to ShoeStoreApp..."
3. Navigate to each directory and add the corresponding `.swift` files
4. Make sure "Copy items if needed" is checked
5. Add `Configuration.json` to the project and ensure it's included in "Copy Bundle Resources" in Build Phases

### 3. Configure Swift Package Dependencies

Add the Auth0.swift package:

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Enter the package URL: `https://github.com/auth0/Auth0.swift`
3. Select version: `2.0.0` or later
4. Click "Add Package"
5. Select "Auth0" library and click "Add Package"

### 4. Set Up Auth0

#### Create Auth0 Application

1. Go to [auth0.com](https://auth0.com) and sign up or log in
2. Navigate to **Applications** → **Applications**
3. Click **Create Application**
4. Choose:
   - Name: `ShoeStoreApp`
   - Application Type: **Native**
5. Click **Create**

#### Configure Auth0 Application

1. In your Auth0 application settings, find your:
   - **Domain** (e.g., `your-tenant.auth0.com`)
   - **Client ID** (e.g., `abc123xyz789...`)

2. Configure **Allowed Callback URLs**:
   ```
   com.shoestore.app://YOUR_AUTH0_DOMAIN/ios/com.shoestore.app/callback
   ```
   Replace `YOUR_AUTH0_DOMAIN` with your actual Auth0 domain (e.g., `your-tenant.auth0.com`)

3. Configure **Allowed Logout URLs**:
   ```
   com.shoestore.app://YOUR_AUTH0_DOMAIN/ios/com.shoestore.app
   ```

4. Click **Save Changes**

#### Update Auth0.plist

1. Open `ShoeStoreApp/Auth0.plist`
2. Replace placeholders with your actual values:
   ```xml
   <key>ClientId</key>
   <string>YOUR_ACTUAL_CLIENT_ID</string>
   <key>Domain</key>
   <string>your-tenant.auth0.com</string>
   ```

#### Update Info.plist (if needed)

The Info.plist is already configured with the URL scheme `$(PRODUCT_BUNDLE_IDENTIFIER)`. If you used a different bundle identifier than `com.shoestore.app`, update the callback URLs in Auth0 accordingly.

### 5. Build and Run

1. Select a simulator (iPhone 14 Pro recommended)
2. Click **Product** → **Run** (or press ⌘R)
3. Wait for the build to complete
4. The app should launch in the simulator

## Using the App

### Shop Screen (Landing Page)

- Browse 10 shoes in a 2-column scrollable grid
- Each tile shows:
  - Product image (placeholder)
  - Name and price
  - Short description
  - "Add to Cart" button
- Tap "Add to Cart" to add items to your cart
- Notice the cart badge increment on the Cart tab

### Cart Screen

**Current Cart Section:**
- View all items in your cart
- Use +/- buttons to adjust quantities
- Tap trash icon to remove items
- See real-time subtotal calculation
- Tap "Checkout" to complete purchase (mock - creates order)

**Order History Section:**
- View past orders with dates and totals
- See order status (Delivered, Shipped, etc.)
- Mock data is pre-loaded for demonstration

### Profile Screen

**Not Logged In:**
- Shows lock icon and "Sign in" prompt
- Tap "Login with Auth0" to authenticate

**Logged In:**
- Shows user profile information
- Displays authentication tokens:
  - ID Token (tap to expand/collapse)
  - Access Token (tap to expand/collapse)
  - Refresh Token (tap to expand/collapse)
- Tap "Logout" to sign out

## Customization

### Change Theme Colors

Edit `ShoeStoreApp/Resources/Configuration.json`:

```json
{
  "branding": {
    "name": "YourStoreName",
    "primaryColor": "#003057",
    "accentColor": "#0055A6",
    "backgroundColor": "#F7F7F7"
  }
}
```

Supported color formats: `#RGB`, `#RRGGBB`, `#AARRGGBB`

### Add/Modify Products

Edit the `products` array in `Configuration.json`:

```json
{
  "id": "unique_id",
  "name": "Product Name",
  "price": 99.99,
  "description": "Short description",
  "imageUrl": "image_name"
}
```

Currently uses SF Symbols for images. To add custom images:
1. Add images to `Assets.xcassets`
2. Update `imageUrl` to match asset name
3. Modify `ProductTileView.swift` to load custom images instead of SF Symbols

## Architecture

### MVVM Pattern

- **Models**: Data structures (Product, CartItem, Order)
- **Views**: SwiftUI views (ShopView, CartView, ProfileView)
- **ViewModels**: Business logic and state management

### State Management

- `@StateObject`: View model lifecycle management
- `@EnvironmentObject`: Shared cart state across views
- `@Published`: Reactive UI updates

### Configuration System

- JSON-based configuration loaded at runtime
- Dynamic theming via Color extensions
- Easily switch between brand configurations

## Troubleshooting

### Auth0 Login Not Working

1. Verify Auth0.plist has correct ClientId and Domain
2. Check callback URLs in Auth0 dashboard match bundle ID
3. Ensure Auth0.swift package is properly installed
4. Look for errors in Xcode console during login attempt

### Products Not Showing

1. Verify Configuration.json is in the project
2. Check Configuration.json is in "Copy Bundle Resources" (Build Phases)
3. Validate JSON syntax (use a JSON validator)
4. Check Xcode console for loading errors

### Build Errors

1. Ensure iOS Deployment Target is set to 14.0 or later
2. Verify all Swift files are added to the target
3. Clean build folder: **Product** → **Clean Build Folder** (⇧⌘K)
4. Restart Xcode if issues persist

### Cart Badge Not Updating

- The cart badge uses `@EnvironmentObject` - ensure CartViewModel is injected in ContentView
- Verify `.badge()` modifier is supported (iOS 15+, will gracefully degrade on iOS 14)

## Technical Notes

- **Minimum iOS Version**: 14.0 (for LazyVGrid, TabView features)
- **Auth0 SDK Version**: 2.x
- **No Backend Required**: All cart and order data is stored in-memory
- **No Persistence**: Cart clears on app restart (can add UserDefaults/CoreData)
- **Mock Data**: Order history uses generated mock data

## Future Enhancements

Potential improvements:
- [ ] Persistent cart storage (UserDefaults/CoreData)
- [ ] Real product images
- [ ] Product detail view
- [ ] Search and filter functionality
- [ ] Favorites/wishlist
- [ ] Payment integration (Stripe, Apple Pay)
- [ ] Backend API integration
- [ ] Push notifications for order updates
- [ ] Multiple themes/brand configurations

## License

This project is provided as-is for educational and demonstration purposes.

## Support

For issues related to:
- **Auth0 Setup**: Check [Auth0 Documentation](https://auth0.com/docs/quickstart/native/ios-swift)
- **SwiftUI**: Check [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- **Xcode**: Check [Apple Developer Documentation](https://developer.apple.com/documentation/)

## Credits

Built with:
- SwiftUI
- Auth0.swift SDK
- SF Symbols for icons
