# Splitza Network Architecture

## Overview

This document outlines the comprehensive network layer built for the Splitza app, following modern iOS development patterns and providing flexibility for future API integration.

## Architecture Components

### 1. NetworkManager (`NetworkManager.swift`)
- **Purpose**: Core networking layer with generic request handling
- **Features**:
  - Generic HTTP client using URLSession and Combine
  - Automatic error mapping and handling
  - Support for all HTTP methods (GET, POST, PUT, DELETE)
  - JSON encoding/decoding with date formatting
  - Request timeout and retry logic
  - Response validation and error categorization

### 2. SplitBillAPIService (`SplitBillAPIService.swift`)
- **Purpose**: Domain-specific API service for split bill operations
- **Features**:
  - RESTful API endpoints for CRUD operations
  - Search functionality with pagination
  - Authentication header injection
  - Request/Response models for type safety
  - Participant payment tracking
  - Bill settlement functionality

### 3. Repository Pattern (`SplitBillRepository.swift`)
- **Purpose**: Data source abstraction layer
- **Features**:
  - Multiple data source support (Local, Remote, Hybrid)
  - Seamless switching between data sources
  - Offline-first architecture with sync capabilities
  - Error handling and fallback mechanisms
  - Background synchronization for hybrid mode

### 4. Configuration Management (`NetworkConfiguration.swift`)
- **Purpose**: Environment and feature flag management
- **Features**:
  - Environment-specific configurations (Dev, Staging, Prod)
  - Network monitoring and connectivity detection
  - Feature flags for enabling/disabling networking
  - API key and header management
  - Development helpers and mock configurations

## Data Flow

```
HistoryViewController → HistoryViewModel → SplitBillRepository → DataSource (Local/Remote) → API/LocalStorage
```

## Usage Examples

### 1. Basic Setup (Current Implementation)
```swift
// Automatically uses configuration to determine data source
let viewModel = HistoryViewModel()
```

### 2. Force Local Data Source
```swift
NetworkConfiguration.shared.disableNetworking()
let viewModel = HistoryViewModel()
```

### 3. Enable Hybrid Mode
```swift
NetworkConfiguration.shared.enableNetworking()
NetworkConfiguration.shared.enableHybridMode()
let viewModel = HistoryViewModel()
```

### 4. Direct API Usage
```swift
let apiService = SplitBillAPIService()
apiService.getAllSplitBills(page: 1, limit: 20)
    .sink(receiveCompletion: { completion in
        // Handle completion
    }, receiveValue: { response in
        // Handle response
    })
    .store(in: &cancellables)
```

## API Endpoints

### Split Bills
- `GET /api/v1/split-bills` - Get all split bills with pagination
- `GET /api/v1/split-bills/{id}` - Get specific split bill
- `GET /api/v1/split-bills/search?query={query}` - Search split bills
- `POST /api/v1/split-bills` - Create new split bill
- `PUT /api/v1/split-bills/{id}` - Update split bill
- `DELETE /api/v1/split-bills/{id}` - Delete split bill
- `PUT /api/v1/split-bills/{id}/settle` - Mark bill as settled
- `PUT /api/v1/split-bills/{billId}/participants/{participantId}/payment` - Update participant payment

### Request/Response Models

#### Create Split Bill Request
```json
{
  "title": "Dinner at Restaurant",
  "totalAmount": 120.50,
  "location": "Downtown Restaurant",
  "participants": [
    {
      "name": "John Doe",
      "email": "john@example.com",
      "amountOwed": 40.17
    }
  ],
  "currency": "USD",
  "description": "Team dinner"
}
```

#### Split Bill Response
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid-string",
      "title": "Dinner at Restaurant",
      "totalAmount": 120.50,
      "date": "2025-08-10T19:30:00.000Z",
      "location": "Downtown Restaurant",
      "participants": [...],
      "currency": "USD",
      "description": "Team dinner",
      "isSettled": false
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100,
    "itemsPerPage": 20
  }
}
```

## Error Handling

### Network Errors
- `invalidURL` - Malformed URL
- `noData` - Empty response
- `decodingError` - JSON parsing failed
- `serverError(Int)` - HTTP error codes
- `networkUnavailable` - No internet connection
- `timeout` - Request timeout
- `unauthorized` - 401 authentication failed
- `forbidden` - 403 access denied
- `notFound` - 404 resource not found

### Repository Errors
- `splitBillNotFound` - Requested bill doesn't exist
- `networkError(Error)` - Wrapped network error
- `cacheError(Error)` - Local storage error
- `syncError(Error)` - Synchronization failed

## Configuration Options

### Environment Variables
```swift
// Set in Info.plist or build configuration
API_KEY = "your-production-api-key"
```

### UserDefaults Keys
- `networking_enabled` - Enable/disable API calls
- `hybrid_mode_enabled` - Use local + remote data
- `auth_token` - User authentication token

## Network Monitoring

The app includes automatic network monitoring:
- Real-time connectivity detection
- Connection type identification (WiFi, Cellular, Ethernet)
- Automatic fallback to local data when offline
- Background sync when connection is restored

## Security Considerations

1. **API Key Management**: Production keys stored securely in Info.plist
2. **Authentication**: Bearer token support with automatic header injection
3. **HTTPS Only**: All production endpoints use secure connections
4. **Request Validation**: Input sanitization and validation
5. **Error Masking**: Sensitive error details not exposed to UI

## Future Enhancements

### Planned Features
1. **Caching Strategy**: Implement intelligent caching with expiration
2. **Offline Queue**: Queue operations when offline, sync when online
3. **Real-time Updates**: WebSocket support for live bill updates
4. **Background Refresh**: Automatic data refresh in background
5. **Conflict Resolution**: Handle concurrent edit conflicts
6. **Analytics**: Network performance and usage tracking

### Testing Strategy
1. **Unit Tests**: Mock network responses for reliable testing
2. **Integration Tests**: Test API contract compliance
3. **Performance Tests**: Network latency and throughput testing
4. **Offline Tests**: Verify offline-first functionality

## Migration Path

### Current State (Demo)
- Local data only with sample data
- Full UI functionality with MVVM architecture

### Phase 1 (API Integration)
- Enable remote data source
- Add authentication flow
- Implement basic CRUD operations

### Phase 2 (Production Ready)
- Add caching and offline support
- Implement conflict resolution
- Add real-time features

### Phase 3 (Advanced Features)
- Analytics and monitoring
- Advanced search capabilities
- Multi-user collaboration features

## Developer Guidelines

### Adding New Endpoints
1. Define request/response models
2. Add endpoint to `SplitBillAPIRequest` enum
3. Implement service method in `SplitBillAPIService`
4. Add repository method for data source abstraction
5. Update ViewModel to use new functionality

### Error Handling Best Practices
1. Always provide user-friendly error messages
2. Implement retry mechanisms for transient failures
3. Use fallback strategies (local data when remote fails)
4. Log errors for debugging without exposing sensitive data

### Configuration Management
1. Use environment-specific configurations
2. Implement feature flags for gradual rollouts
3. Provide development overrides for testing
4. Document all configuration options

This architecture provides a solid foundation for scaling the Splitza app from a local demo to a full-featured, cloud-connected application while maintaining excellent user experience and developer productivity.
