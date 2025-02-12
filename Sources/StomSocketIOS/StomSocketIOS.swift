// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit
import WebKit

public class StomSocketIOS: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    private var webView: WKWebView?  // 🔹 Strong reference to prevent deallocation
    private var isWebViewLoaded = false  // Track WebView load status
    
    public var socketUrl: String = "https://stream.example.com/ChartStream/ws"
    public var subscribeTopics: String = "/user/topic/stream/tradingView"
    public var connectionURL: String?
    public var subscribeTopic: String?
    public var sendDestination: String?
   public  var onConnect: (() -> Void)?
   public var onDisconnect: (() -> Void)?
    
   public var onMessageReceived: ((String) -> Void)?
    public var onError: ((String) -> Void)?
    
    // Combine initializers into one
   public init(socketUrlString: String = "https://stream.example.com/ChartStream/ws",subscribeTopics:String) {
        self.socketUrl = socketUrlString
        self.subscribeTopics = subscribeTopics
        super.init()
        setupWebView()
    }

    // MARK: - Setup WebView
    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "socketHandler")  // Message handler
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.navigationDelegate = self
        webView?.isHidden = true  // Hide WebView
        
        if let webView = webView {
            UIApplication.shared.windows.first?.addSubview(webView)  // Keep WebView in hierarchy
            webView.loadHTMLString(getHTMLContent(), baseURL: nil)
        }
    }
    
    // MARK: - Handle WebView Load Completion
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewLoaded = true
        print("✅ WebView loaded successfully.")
    }
    
    // MARK: - JavaScript Execution Helper
    private func runJSFunction(_ function: String) {
        guard isWebViewLoaded else {
            print("⚠️ WebView not yet loaded. Retrying in 1 second...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.runJSFunction(function)
            }
            return
        }
        
        webView?.evaluateJavaScript(function) { result, error in
            if let error = error {
                print("❌ JS Error: \(error.localizedDescription)")
            } else {
                print("✅ JS Executed Successfully: \(function)")
            }
        }
    }
    
    // MARK: - WebSocket Actions
   public func connect() {
        runJSFunction("connect();")
        onConnect?()
    }
    
    public func disconnect() {
        runJSFunction("disconnect();")
        onDisconnect?()
    }
    
    public func subscribe(topic:String) {
        runJSFunction("subscribe('\(topic)');")
    }
    
    public func unsubscribe() {
        runJSFunction("unsubscribe();")
    }
    
    // MARK: - New Method to Call send Function
    public func send(destination: String, data: [String: Any]) {
        let dataJSON = convertToJSON(data: data)
        let jsFunction = "send('\(destination)', \(dataJSON));"
        runJSFunction(jsFunction)
    }

    // MARK: - Helper to Convert Data to JSON
    private func convertToJSON(data: [String: Any]) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to convert data to JSON")
            return "{}"  // Default empty JSON object if failed
        }
        return jsonString
    }
    
    // MARK: - WKScriptMessageHandler (Receiving JS Messages)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "socketHandler", let response = message.body as? String {
            print("📩 Received from WebSocket: \(response)")
            
            switch response {
                
            case "Connected" :
                self.onConnect?()
            case "Disconnected":
                self.onDisconnect?()
            case "SendRequest":
                print("✅ Request Send Sucessfully.")
            default:
                break
            }
            
            onMessageReceived?(response)
        }
    }
    
    // MARK: - HTML with JavaScript (WebSocket)
    private func getHTMLContent() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Hubkoin Socket Service</title>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
        </head>
        <body>
            <script>
                var stompClient = null;
                var id = 0;

                function connect() {
                    var socket = new SockJS('\(socketUrl)');
                    stompClient = Stomp.over(socket);
                    stompClient.connect({}, function (frame) {
                        window.webkit.messageHandlers.socketHandler.postMessage("Connected");
                        stompClient.subscribe('\(subscribeTopics)', function (message) {
                            window.webkit.messageHandlers.socketHandler.postMessage(message.body);
                        });
                    });
                }
                
                function send(topic, data) {
                                  
                                      
                                  try {
                                    id = Math.floor((Math.random() * 1000) + 1);
                                    stompClient.send(topic, {}, JSON.stringify(data));
                                     window.webkit.messageHandlers.socketHandler.postMessage("SendRequest");
                                  }
                                  catch(err) {
                                        window.webkit.messageHandlers.socketHandler.postMessage(`Send message Error ${err}`);
                                  }
                }

                function disconnect() {
                    if (stompClient !== null) {
                        stompClient.disconnect();
                        window.webkit.messageHandlers.socketHandler.postMessage("Disconnected");
                    }
                }

                function subscribe(topic) {
                    id = Math.floor((Math.random() * 1000) + 1);
                    stompClient.send("/app/sendRequest/tradingView", {}, JSON.stringify({
                        method: "SUBSCRIBE",
                        base: "USD",
                        counter: "BTC",
                        actualResolution: "1D",
                        id: id
                    }));
                    window.webkit.messageHandlers.socketHandler.postMessage("Subscribed");
                }
                
                function unsubscribe() {
                    stompClient.send("/app/sendRequest/tradingView", {}, JSON.stringify({
                        method: "UNSUBSCRIBE",
                        base: "USD",
                        counter: "BTC",
                        actualResolution: "1D",
                        id: id
                    }));
                    window.webkit.messageHandlers.socketHandler.postMessage("Unsubscribed");
                }
            </script>
        </body>
        </html>
        """
    }
}
