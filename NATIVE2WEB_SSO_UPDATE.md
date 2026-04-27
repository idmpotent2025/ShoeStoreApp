# Native2Web SSO Update Guide

## Changes Made

The webapp has been refactored with new URL structure. The Native2Web SSO endpoint has been moved:

**Old URL**: `https://your-domain.vercel.app/sso?sessionToken=TOKEN`
**New URL**: `https://your-domain.vercel.app/flows/native2web/sso?sessionToken=TOKEN`

## Updated Files

### 1. `AdvancedFlowsViewModel.swift`

**Changes**:
- Updated `initiateNative2WebSSO()` method to use new URL path: `/flows/native2web/sso`
- Added session token as query parameter
- Added documentation for integrating with real Auth0 tokens

**Before**:
```swift
let webURL = URL(string: "https://demo.identityarchitect.app/portal")
```

**After**:
```swift
let baseURL = "https://demo.identityarchitect.app"
let webURL = URL(string: "\(baseURL)/flows/native2web/sso?sessionToken=\(sessionToken)")
```

### 2. `AdvancedFlowsView.swift`

**Changes**:
- Updated button action to actually open the URL in Safari
- Added separate "End Session" button
- Now uses `UIApplication.shared.open()` to launch the webapp

**Before**:
```swift
Button(action: {
    // In a real implementation, this would open ASWebAuthenticationSession
    viewModel.endSSOSession()
})
```

**After**:
```swift
Button(action: {
    if UIApplication.shared.canOpenURL(ssoSession.webPortalURL) {
        UIApplication.shared.open(ssoSession.webPortalURL)
    }
})
```

## Configuration Required

### For Local Testing

Update the base URL in `AdvancedFlowsViewModel.swift` line ~98:

```swift
let baseURL = "http://localhost:3000"  // For local webapp testing
```

### For Production

Update the base URL to your Vercel deployment:

```swift
let baseURL = "https://your-app.vercel.app"
```

Or retrieve from configuration file:

```swift
let baseURL = Bundle.main.object(forInfoDictionaryKey: "WebAppBaseURL") as? String ?? "https://demo.identityarchitect.app"
```

## Integration with Real Auth0 Tokens

Currently, the implementation uses a UUID placeholder for the session token. To use real Auth0 authentication:

### Step 1: Inject AuthService

Update `AdvancedFlowsViewModel` to accept `AuthService`:

```swift
class AdvancedFlowsViewModel: ObservableObject {
    private let authService: AuthService  // Add this

    init(qrCodeService: QRCodeService, authService: AuthService) {
        self.qrCodeService = qrCodeService
        self.authService = authService  // Add this
    }
}
```

### Step 2: Use Real Tokens

Replace the UUID placeholder with actual Auth0 tokens:

```swift
func initiateNative2WebSSO() {
    isLoading = true
    errorMessage = nil

    // Check if user is authenticated
    guard authService.isAuthenticated else {
        errorMessage = "User must be authenticated first"
        isLoading = false
        return
    }

    // Use actual Auth0 token (access token preferred)
    guard let sessionToken = authService.accessToken ?? authService.idToken else {
        errorMessage = "No authentication token available"
        isLoading = false
        return
    }

    let baseURL = "https://your-app.vercel.app"
    guard let webURL = URL(string: "\(baseURL)/flows/native2web/sso?sessionToken=\(sessionToken)") else {
        errorMessage = "Invalid URL"
        isLoading = false
        return
    }

    ssoSession = SSOSession(
        sessionToken: sessionToken,
        webPortalURL: webURL,
        createdAt: Date(),
        isActive: true
    )

    isLoading = false
}
```

### Step 3: Update View Initialization

Wherever `AdvancedFlowsViewModel` is initialized, pass the `AuthService`:

```swift
@StateObject private var viewModel = AdvancedFlowsViewModel(
    qrCodeService: QRCodeService(),
    authService: authService  // Pass from parent view
)
```

## How It Works

### Flow Diagram

```
1. User authenticates in iOS app
   ↓
2. iOS app receives Auth0 tokens
   (access_token, id_token)
   ↓
3. User taps "Native2WebSSO" in Advanced Flows
   ↓
4. iOS app generates SSO URL with token
   https://your-app.vercel.app/flows/native2web/sso?sessionToken=eyJhbG...
   ↓
5. User taps "Open Web Portal with SSO"
   ↓
6. Safari opens with the URL
   ↓
7. Webapp receives token in URL parameter
   ↓
8. Webapp validates JWT using Auth0 JWKS
   ↓
9. Webapp creates session and redirects to /shop
   ↓
10. User is automatically logged into webapp
```

## Security Considerations

### Token Exposure in URL

**Issue**: Session tokens are visible in browser history when passed as URL parameters.

**Webapp Mitigation**:
- Token is immediately removed from URL using `window.history.replaceState()`
- Short token lifetime (5-10 minutes recommended)
- Single-use token (implement nonce/jti tracking)

**Alternative Approach**: Use POST method with deep linking:
1. iOS app registers custom URL scheme (e.g., `shoestore://`)
2. Webapp opens `shoestore://token-exchange?code=SHORT_CODE`
3. iOS app exchanges short code for session via POST request
4. No token in URL

### Token Validation

The webapp validates tokens using:
1. JWT signature verification (Auth0 JWKS)
2. Issuer validation (must be from your Auth0 tenant)
3. Audience validation (must match expected client ID)
4. Expiration check (token must not be expired)
5. Rate limiting (3 requests per minute per IP)

## Testing

### Manual Testing

1. **Local Testing**:
   ```bash
   # Start webapp locally
   cd auth0-xchannel-flows-webapp
   npm run dev

   # Update iOS app baseURL to http://localhost:3000
   # Run iOS app in simulator
   # Trigger Native2Web SSO
   ```

2. **Production Testing**:
   - Deploy webapp to Vercel
   - Update iOS app baseURL to your Vercel URL
   - Test on physical device

### Test Cases

- [ ] URL opens in Safari with correct path
- [ ] Token appears in URL (before replacement)
- [ ] Webapp displays "Exchanging Token..." loading state
- [ ] Invalid token shows error message
- [ ] Expired token shows error message
- [ ] Valid token redirects to /shop
- [ ] User profile displayed correctly

## Troubleshooting

### URL Not Opening

**Issue**: Button tap doesn't open Safari

**Solution**: Verify URL scheme is HTTP/HTTPS:
```swift
print("URL:", ssoSession.webPortalURL)  // Debug
```

### Token Validation Fails

**Issue**: Webapp shows "Invalid token"

**Possible Causes**:
1. Token is from different Auth0 tenant
2. Token audience doesn't match
3. Token expired
4. JWKS endpoint not accessible

**Solution**: Check webapp logs and verify Auth0 configuration matches

### Session Not Created

**Issue**: Token validates but user not logged in

**Solution**: Verify webapp creates session cookie in exchange endpoint

## Additional Resources

- [Webapp Native2Web Flow Documentation](../auth0-xchannel-flows-webapp/src/app/flows/native2web/README.md)
- [JWT Validation Implementation](../auth0-xchannel-flows-webapp/src/lib/shared/auth/validation/jwt.ts)
- [Auth0 Token Exchange Docs](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#token-exchange)
