# Investo App - Flowchart Documentation

## Application Flow Diagram

This document contains the complete flow chart for the Investo (StockMaster) application, showing user navigation, data flow, and feature interactions.

## Main Application Flow

```mermaid
flowchart TD
    Start([App Start]) --> Init{Initialize Services}
    Init --> FirebaseInit[Firebase Initialize]
    FirebaseInit --> SharedPrefs[Load SharedPreferences]
    SharedPrefs --> UserDataService[Initialize UserDataService]
    UserDataService --> RealTimeService[Connect RealTimeService]
    RealTimeService --> PortfolioService[Load PortfolioService]
    PortfolioService --> GuideService[Load GuideService]
    GuideService --> AuthGate{Check Authentication}
    
    AuthGate -->|First Time| Onboarding[Onboarding Screen]
    AuthGate -->|Not Authenticated| Login[Login Screen]
    AuthGate -->|Authenticated| LoadUserData[Load User Data from Firestore]
    
    Onboarding --> SetOnboardingFlag[Set onboarding_shown = true]
    SetOnboardingFlag --> Login
    
    Login --> LoginMethods{Login Method}
    LoginMethods -->|Email/Password| EmailLogin[Email Login]
    LoginMethods -->|Google| GoogleLogin[Google Sign In - Coming Soon]
    LoginMethods -->|Apple| AppleLogin[Apple Sign In - Coming Soon]
    LoginMethods -->|New User| Register[Register Screen]
    
    EmailLogin --> CreateUserDoc{User Exists in Firestore?}
    CreateUserDoc -->|No| InitUserData[Initialize User Data<br/>- virtualMoney: ₹10,000<br/>- initialMoney: ₹10,000<br/>- portfolio, watchlist, lessons]
    CreateUserDoc -->|Yes| LoadExistingData[Load Existing User Data]
    InitUserData --> InitializeScore[Initialize User Score for Leaderboard]
    LoadExistingData --> InitializeScore
    InitializeScore --> HomeScreen[Home Screen]
    
    Register --> CreateAccount[Create Firebase Account]
    CreateAccount --> InitUserData
    
    LoadUserData --> HomeScreen
    
    HomeScreen --> BottomNav{User Action}
    
    BottomNav -->|Home Tab| HomeFeatures{Home Features}
    BottomNav -->|Portfolio Tab| PortfolioScreen[Portfolio Screen]
    BottomNav -->|Learn Tab| LearningScreen[Learning Screen]
    BottomNav -->|Profile Tab| ProfileScreen[Profile Screen]
    
    HomeFeatures --> SearchStocks[Search Stocks]
    HomeFeatures --> ViewWatchlist[View Watchlist]
    HomeFeatures --> ViewPortfolio[View Portfolio Summary]
    HomeFeatures --> ViewCarousel[View Market Categories<br/>Top Gainers/Losers/Active]
    HomeFeatures --> ChatBot[Open Chat Bot - Owl Character]
    HomeFeatures --> ViewLeaderboard[View Leaderboard]
    HomeFeatures --> ViewIPO[View IPO Screen]
    HomeFeatures --> ViewPrediction[View Prediction Screen]
    
    SearchStocks --> SelectStock{Select Stock}
    SelectStock --> AddWatchlist[Add to Watchlist]
    SelectStock --> ViewDetails[View Stock Details]
    SelectStock --> BuyStock[Buy Stock]
    SelectStock --> ViewChart[View Enhanced Chart]
    
    AddWatchlist --> SaveWatchlist[Save to UserDataService<br/>Persist to Firestore]
    SaveWatchlist --> HomeScreen
    
    BuyStock --> CheckBalance{Sufficient Balance?}
    CheckBalance -->|Yes| DeductMoney[Deduct from virtualMoney]
    CheckBalance -->|No| ShowError[Show Error Message]
    DeductMoney --> UpdateHoldings[Update Portfolio Holdings]
    UpdateHoldings --> UpdateScore[Update Portfolio Score]
    UpdateScore --> SaveToFirestore[Save to Firestore]
    SaveToFirestore --> HomeScreen
    
    ViewDetails --> StockInfo[Display Stock Info<br/>- Price, Change, Volume<br/>- High/Low, Market Cap, PE]
    StockInfo --> Actions{User Action}
    Actions --> BuyStock
    Actions --> AddWatchlist
    Actions --> ViewChart
    
    ViewChart --> ChartScreen[Enhanced Chart Screen<br/>- Candlestick View<br/>- Technical Indicators]
    ChartScreen --> HomeScreen
    
    PortfolioScreen --> PortfolioFeatures{Portfolio Features}
    PortfolioFeatures --> ViewHoldings[View All Holdings]
    PortfolioFeatures --> ViewHistory[View Trading History]
    PortfolioFeatures --> SellStock[Sell Stock]
    PortfolioFeatures --> ViewReturns[View Profit/Loss]
    
    SellStock --> UpdatePortfolio[Update Portfolio]
    UpdatePortfolio --> AddMoney[Add Money to virtualMoney]
    AddMoney --> UpdateScore
    UpdateScore --> SaveToFirestore
    
    LearningScreen --> LearningCategories{Select Category}
    LearningCategories --> Basics[Basics Category]
    LearningCategories --> News[News Category]
    LearningCategories --> RiskMgmt[Risk Management Category]
    
    Basics --> SelectLesson[Select Lesson]
    News --> SelectLesson
    RiskMgmt --> SelectLesson
    
    SelectLesson --> StartLesson[Start Lesson<br/>Record Start Time]
    StartLesson --> LessonContent[Display Lesson Content]
    LessonContent --> LessonActions{User Action}
    LessonActions --> MarkComplete[Mark as Completed]
    LessonActions --> CloseLesson[Close Lesson]
    
    MarkComplete --> CalculateTime[Calculate Time Spent]
    CalculateTime --> SaveProgress[Save Lesson Progress<br/>Update UserDataService]
    SaveProgress --> UpdateTimeInvested[Update Total Time Invested]
    UpdateTimeInvested --> UpdateFirestore[Update Firestore]
    UpdateFirestore --> LearningScreen
    
    CloseLesson --> SaveTime[Save Time Spent<br/>Without Marking Complete]
    SaveTime --> UpdateFirestore
    
    ProfileScreen --> ProfileFeatures{Profile Features}
    ProfileFeatures --> AccountDetails[Account Details]
    ProfileFeatures --> Settings[Settings]
    ProfileFeatures --> Orders[Orders History]
    ProfileFeatures --> Analytics[Analytics Dashboard]
    ProfileFeatures --> CustomerSupport[Customer Support]
    ProfileFeatures --> AboutUs[About Us]
    ProfileFeatures --> Logout[Logout]
    
    Settings --> SettingsOptions{Settings Options}
    SettingsOptions --> ChangeTheme[Change Theme]
    SettingsOptions --> Notifications[Notification Settings]
    SettingsOptions --> Privacy[Privacy Settings]
    SettingsOptions --> Logout
    
    Logout --> FirebaseLogout[Firebase Sign Out]
    FirebaseLogout --> ClearLocalData[Clear Local Data]
    ClearLocalData --> Login
    
    ChatBot --> ChatScreen[Chat Screen with Owl Character]
    ChatScreen --> SendMessage[Send Message to Backend]
    SendMessage --> ReceiveReply[Receive AI Reply]
    ReceiveReply --> DisplayMessage[Display Message with Owl Avatar]
    DisplayMessage --> ChatScreen
    
    ViewLeaderboard --> LeaderboardScreen[Leaderboard Screen]
    LeaderboardScreen --> FetchUsers[Fetch All Users from Firestore]
    FetchUsers --> CalculateScores[Calculate Scores<br/>Based on Portfolio Value<br/>and Profit/Loss]
    CalculateScores --> SortUsers[Sort by Points<br/>Descending]
    SortUsers --> DisplayRankings[Display Rankings<br/>with User Names, Scores, Levels]
    DisplayRankings --> LeaderboardScreen
    
    ViewIPO --> IPOScreen[IPO Screen]
    IPOScreen --> ViewIPOList[View Available IPOs]
    ViewIPOList --> HomeScreen
    
    ViewPrediction --> PredictionScreen[Prediction Screen]
    PredictionScreen --> ViewPredictions[View Stock Predictions]
    ViewPredictions --> HomeScreen
    
    style Start fill:#4CAF50
    style HomeScreen fill:#FF9500
    style Login fill:#2196F3
    style Register fill:#2196F3
    style LearningScreen fill:#9C27B0
    style PortfolioScreen fill:#F44336
    style ProfileScreen fill:#607D8B
    style ChatScreen fill:#FF9800
    style LeaderboardScreen fill:#00BCD4
```

## Data Flow Diagram

```mermaid
flowchart LR
    User[User Actions] --> LocalStorage[SharedPreferences<br/>Local Cache]
    User --> Firestore[(Firestore Database)]
    
    LocalStorage <--> UserDataService[UserDataService<br/>Singleton]
    Firestore <--> UserDataService
    
    UserDataService --> Services{Services}
    Services --> PortfolioService[PortfolioService]
    Services --> GuideService[GuideService]
    Services --> RealTimeService[RealTimeService]
    
    PortfolioService --> StockData[Stock Data]
    RealTimeService --> WebSocket[WebSocket<br/>Real-time Updates]
    GuideService --> Tips[In-App Tips]
    
    StockData --> UI[UI Components]
    WebSocket --> UI
    Tips --> UI
    
    UI --> User
    
    style Firestore fill:#FF6B6B
    style LocalStorage fill:#4ECDC4
    style UserDataService fill:#FFE66D
    style UI fill:#95E1D3
```

## Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant App
    participant Firebase Auth
    participant Firestore
    participant UserDataService
    
    User->>App: Launch App
    App->>Firebase Auth: Check Auth State
    Firebase Auth-->>App: Not Authenticated
    App->>User: Show Login Screen
    
    User->>App: Enter Credentials
    App->>Firebase Auth: Sign In
    Firebase Auth-->>App: User Authenticated
    
    App->>Firestore: Check User Document
    alt User Document Not Exists
        Firestore-->>App: Document Not Found
        App->>Firestore: Create User Document<br/>(Initial Money, Portfolio, etc.)
    else User Document Exists
        Firestore-->>App: User Data
    end
    
    App->>UserDataService: Load from Remote
    UserDataService->>Firestore: Fetch User Data
    Firestore-->>UserDataService: User Data
    UserDataService->>UserDataService: Save to Local Cache
    UserDataService-->>App: User Data Loaded
    
    App->>App: Initialize User Score
    App->>Firestore: Set Initial Score
    App->>User: Navigate to Home Screen
```

## Trading Flow

```mermaid
flowchart TD
    User[User on Home Screen] --> SelectStock[Select Stock from Search/Watchlist]
    SelectStock --> ViewDetails[View Stock Details]
    ViewDetails --> Decision{User Decision}
    
    Decision -->|Buy| BuyFlow[Buy Flow]
    Decision -->|Sell| SellFlow[Sell Flow]
    Decision -->|Add to Watchlist| WatchlistFlow[Watchlist Flow]
    
    BuyFlow --> CheckBalance{Check Balance<br/>virtualMoney >= price * quantity}
    CheckBalance -->|Insufficient| ShowError[Show Error:<br/>Insufficient Funds]
    CheckBalance -->|Sufficient| CalculateCost[Calculate Total Cost]
    CalculateCost --> DeductMoney[Deduct from virtualMoney]
    DeductMoney --> UpdateHoldings[Update Holdings<br/>Add Stock to Portfolio]
    UpdateHoldings --> UpdateInvested[Update totalInvested]
    UpdateInvested --> CalculateScore[Calculate Portfolio Score]
    CalculateScore --> SavePortfolio[Save to UserDataService]
    SavePortfolio --> SyncFirestore[Sync to Firestore]
    SyncFirestore --> UpdateLeaderboard[Update Leaderboard Score]
    UpdateLeaderboard --> ShowSuccess[Show Success Message]
    
    SellFlow --> CheckHoldings{Check Holdings<br/>Stock in Portfolio?}
    CheckHoldings -->|Not Found| ShowError2[Show Error:<br/>Stock Not in Portfolio]
    CheckHoldings -->|Found| CheckQuantity{Check Quantity<br/>quantity <= holdings}
    CheckQuantity -->|Insufficient| ShowError3[Show Error:<br/>Insufficient Quantity]
    CheckQuantity -->|Sufficient| CalculateRevenue[Calculate Revenue<br/>price * quantity]
    CalculateRevenue --> AddMoney[Add to virtualMoney]
    AddMoney --> UpdateHoldings2[Update Holdings<br/>Remove/Reduce Stock]
    UpdateHoldings2 --> CalculateScore
    CalculateScore --> SavePortfolio
    SavePortfolio --> SyncFirestore
    SyncFirestore --> UpdateLeaderboard
    UpdateLeaderboard --> ShowSuccess
    
    WatchlistFlow --> CheckWatchlist{Stock in Watchlist?}
    CheckWatchlist -->|Yes| RemoveWatchlist[Remove from Watchlist]
    CheckWatchlist -->|No| AddWatchlist[Add to Watchlist]
    RemoveWatchlist --> SaveWatchlist[Save to UserDataService]
    AddWatchlist --> SaveWatchlist
    SaveWatchlist --> SyncWatchlist[Sync to Firestore]
    SyncWatchlist --> UpdateUI[Update UI]
    
    ShowError --> ViewDetails
    ShowError2 --> ViewDetails
    ShowError3 --> ViewDetails
    ShowSuccess --> HomeScreen[Return to Home Screen]
    UpdateUI --> HomeScreen
```

## Learning Center Flow

```mermaid
flowchart TD
    User[User on Learning Screen] --> SelectCategory[Select Category<br/>Basics/News/Risk Mgmt]
    SelectCategory --> CategoryLessons[Display Lessons in Category]
    CategoryLessons --> SelectLesson[User Selects Lesson]
    SelectLesson --> StartLesson[Start Lesson<br/>Record Start Time]
    StartLesson --> DisplayContent[Display Lesson Content<br/>in Bottom Sheet]
    DisplayContent --> UserInteractions{User Interactions}
    
    UserInteractions -->|Read Content| ContinueReading[Continue Reading]
    UserInteractions -->|Mark Complete| MarkComplete[Mark as Completed]
    UserInteractions -->|Close| CloseLesson[Close Lesson]
    
    ContinueReading --> DisplayContent
    
    MarkComplete --> CalculateTime[Calculate Time Spent<br/>Current Time - Start Time]
    CalculateTime --> UpdateLesson[Update Lesson Progress<br/>Set isCompleted = true<br/>Set timeSpent]
    UpdateLesson --> SaveProgress[Save to UserDataService]
    SaveProgress --> UpdateTotalTime[Update Total Time Invested]
    UpdateTotalTime --> SyncFirestore[Sync to Firestore]
    SyncFirestore --> UpdateUI[Update UI<br/>Show Completed Status]
    UpdateUI --> CategoryLessons
    
    CloseLesson --> SaveTimeOnly[Save Time Spent<br/>Without Marking Complete]
    SaveTimeOnly --> SyncFirestore2[Sync to Firestore]
    SyncFirestore2 --> CategoryLessons
    
    style StartLesson fill:#4CAF50
    style MarkComplete fill:#FF9800
    style SyncFirestore fill:#2196F3
```

## Leaderboard Flow

```mermaid
flowchart TD
    User[User Opens Leaderboard] --> FetchUsers[Fetch All Users from Firestore]
    FetchUsers --> ProcessUsers[Process Each User]
    
    ProcessUsers --> CheckData{User Data<br/>Available?}
    CheckData -->|Complete| CalculateMetrics[Calculate Metrics]
    CheckData -->|Incomplete| UseDefaults[Use Default Values<br/>portfolioValue: 0<br/>points: 0<br/>username: 'Unknown']
    
    CalculateMetrics --> GetPortfolioValue[Get Portfolio Value<br/>from currentPrices]
    GetPortfolioValue --> GetProfitLoss[Calculate Profit/Loss<br/>portfolioValue - initialMoney]
    GetProfitLoss --> GetReturnPercent[Calculate Return %<br/>(profitLoss / initialMoney) * 100]
    GetReturnPercent --> CalculatePoints[Calculate Points<br/>portfolioValue + profitLoss<br/>* multiplier]
    CalculatePoints --> GetLevel[Calculate Level<br/>Based on Points]
    
    UseDefaults --> AddUser[Add User to List]
    CalculatePoints --> AddUser
    GetLevel --> AddUser
    
    AddUser --> MoreUsers{More Users?}
    MoreUsers -->|Yes| ProcessUsers
    MoreUsers -->|No| SortUsers[Sort Users<br/>1. By Points (Descending)<br/>2. By Username (Ascending)]
    
    SortUsers --> DisplayLeaderboard[Display Leaderboard]
    DisplayLeaderboard --> ShowTop3[Show Top 3 on Podium]
    DisplayLeaderboard --> ShowList[Show Remaining Users in List]
    
    ShowTop3 --> UpdateUI[Update UI with Rankings]
    ShowList --> UpdateUI
    
    style FetchUsers fill:#2196F3
    style CalculatePoints fill:#FF9800
    style DisplayLeaderboard fill:#4CAF50
```

## Real-time Data Flow

```mermaid
flowchart LR
    RealTimeService[RealTimeService] --> WebSocket[WebSocket Connection<br/>to Finnhub API]
    WebSocket --> ReceiveData[Receive Real-time<br/>Stock Data]
    ReceiveData --> ParseData[Parse Stock Prices]
    ParseData --> UpdateLocalData[Update Local Stock Data]
    UpdateLocalData --> NotifyListeners[Notify UI Listeners]
    NotifyListeners --> UpdateUI[Update UI Components]
    UpdateUI --> UpdatePortfolio[Update Portfolio Value]
    UpdatePortfolio --> UpdateScore[Update Leaderboard Score]
    UpdateScore --> SyncFirestore[Sync to Firestore]
    
    style WebSocket fill:#9C27B0
    style UpdateUI fill:#4CAF50
    style SyncFirestore fill:#F44336
```

## Key Features Summary

### 1. **Authentication & User Management**
   - Firebase Authentication (Email/Password)
   - User registration and login
   - Onboarding for first-time users
   - User data persistence (SharedPreferences + Firestore)

### 2. **Stock Trading**
   - Real-time stock data via WebSocket
   - Stock search and filtering
   - Buy/Sell functionality with virtual money (₹10,000 initial)
   - Portfolio management
   - Watchlist management
   - Stock charts and technical analysis

### 3. **Learning Center**
   - Three categories: Basics, News, Risk Management
   - Lesson tracking with time spent
   - Progress persistence
   - Completion tracking

### 4. **Leaderboard**
   - Global rankings based on portfolio performance
   - Score calculation from portfolio value and profit/loss
   - Level system based on points
   - Real-time updates

### 5. **AI Chatbot**
   - Owl character integration
   - Stock market guidance
   - Backend API integration

### 6. **Profile & Settings**
   - Account management
   - Settings configuration
   - Trading history
   - Analytics dashboard
   - Customer support

### 7. **Additional Features**
   - IPO screen
   - Prediction screen
   - In-app tips with owl character
   - Real-time market updates

## Data Persistence

- **Local Storage**: SharedPreferences for offline access
- **Remote Storage**: Firestore for cloud sync
- **Real-time Updates**: WebSocket for live stock prices
- **User Isolation**: Each user's data is isolated and secure

## Security

- Firebase Authentication for user verification
- Firestore security rules for data access control
- User can only modify their own data
- Leaderboard allows read access for all authenticated users





