# 🚀 StomSocketIOS

🔹 StomSocketIOS is a ⚡ lightweight Swift 📦 that provides a 🌐 WebSocket client using 📱 WKWebView to interact with 🔄 STOMP-based WebSocket servers. It enables ⏳ real-time communication between an 📲 iOS app and a WebSocket server with 🎯 easy message handling.

## ✨ Features
- 🔗 Establish WebSocket connections using 📜 STOMP protocol.
- 📡 Subscribe to 📌 topics for real-time 🔄 data updates.
- 📤 Send & 📥 receive messages via WebSocket.
- 🔄 Handle connection & ❌ disconnection events.
- 🖥 Uses WKWebView to manage WebSocket interactions efficiently.

## 📥 Installation

### 🛠 Swift Package Manager (SPM)
To integrate `StomSocketIOS` into your 🏗 Xcode project, follow these 📜 steps:

1️⃣ Open your 🏗 Xcode project.
2️⃣ Go to **📂 File** → **➕ Add Packages**.
3️⃣ Enter the 🔗 repository URL or 📍 local path.
4️⃣ Select the 📌 versioning strategy & click **📦 Add Package**.
5️⃣ Choose **StomSocketIOS** as the 📦 target & click **📦 Add Package**.

## ⚙️ Usage

### 📥 Import the Package
```swift
import StomSocketIOS
```

### 🔧 Initialize WebSocket Manager
```swift
private let webSocketManager = WebSocketJSManager(socketUrlString:"https://example.chatData.com/ChartStream/ws", subscribeTopics: "/user/topic/stream/tradingView")
```

### 🎯 Handle Connection Events
```swift
webSocketManager.onConnect = {
    print("✅ WebSocket Connected")
}

webSocketManager.onDisconnect = {
    print("❌ WebSocket Disconnected")
}

webSocketManager.onMessageReceived = { message in
    print("📩 Received Message: \(message)")
}
```

### 🔗 Connect to WebSocket
```swift
webSocketManager.connect()
```

### 📡 Subscribe to a Topic
```swift
webSocketManager.subscribe(topic: "/user/topic/stream/tradingView")
```

### 📤 Send a Message
```swift
let data: [String: Any] = ["key": "value"]
webSocketManager.send(destination: "/app/sendRequest", data: data)
```

### ❌ Disconnect from WebSocket
```swift
webSocketManager.disconnect()
```

## 📜 License
This project is licensed under the 📝 MIT License. See the LICENSE file for details.

## 🤝 Contributing
🙌 Contributions are welcome! Feel free to 🔀 fork this repository & submit 📨 pull requests.

## 📩 Contact
For any ❓ inquiries, feel free to 📧 reach out.
