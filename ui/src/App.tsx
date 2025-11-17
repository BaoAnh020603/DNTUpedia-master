import { useState, useEffect } from "react";
import { DeepChat } from "deep-chat-react";
import "./App.css";
import "deep-chat";

function App() {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const handleResponse = (response: any) => {
    if (response.text) {
      let processedText = response.text;
      // Thay thế toàn bộ <thinking>...</thinking> (hoặc chỉ <thinking>...</thinking> trên 1 dòng) bằng "Đang suy nghĩ..."
      processedText = processedText.replace(
        /<thinking>[\s\S]*?<\/thinking>/gi,
        "*Đang suy nghĩ...*\n"
      );
      return {
        ...response,
        text: processedText,
      };
    }
    return response;
  };

  useEffect(() => {
    if (isOpen) setIsLoading(false);
  }, [isOpen]);

  return (
    <div className="App">
      <div className="banner"></div>

      {!isOpen && (
        <button className="chatbot-toggle" onClick={() => setIsOpen(true)}>
          <img
            src="/assets/DNTUChatbot.png"
            alt="DNTU Chatbot"
            className="chatbot-icon"
          />
        </button>
      )}

      {isOpen && (
        <div className="chatbot-container">
          <div className="chatbot-wrapper">
            <div className="chat-header">
              <img
                src="/assets/DNTUChatbot.png"
                alt="DNTU Logo"
                className="header-icon"
              />
              <span className="header-title">DNTUpedia Chatbot</span>
              <button className="close-button" onClick={() => setIsOpen(false)}>
                ✕
              </button>
            </div>

            <div className="chat-content">
              <DeepChat
                style={{
                  width: "100%",
                  height: "100%",
                  border: "none",
                  background: "transparent",
                }}
                introMessage={{
                  text: "Chào mừng đến với DNTUpedia Chatbot! Gõ tin nhắn để bắt đầu.",
                }}
                connect={{
                  url: process.env.REACT_APP_API_URL || "",
                  method: "POST",
                  headers: {
                    "Content-Type": "application/json",
                    Accept: "text/event-stream",
                  },
                  stream: true,
                }}
                requestBodyLimits={{ maxMessages: -1 }}
                errorMessages={{ displayServiceErrorMessages: true }}
                onError={(error: any) => console.error("API Error:", error)}
                responseInterceptor={handleResponse}
              />
              <button className="upload-icon" />
              {isLoading && (
                <div className="loading-overlay">DNTU Loading...</div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
