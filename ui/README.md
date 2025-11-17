# ChatBot UI

A user interface (UI) for a chatbot built with React, integrated with an API to provide an interactive conversational experience.

## Description

This project provides a user interface for a chatbot, utilizing a background image and overlay chatbot to simulate a website experience. It is designed for easy integration with a backend API and can be customized according to the team's needs.

## Features

- Displays a full-screen banner with customizable images.
- Overlay chatbot with a friendly and interactive interface.
- Supports DeepChat API integration for message handling.
- Responsive design and easy customization.

## Environment Variables

Create a `.env` file in the root directory and configure the following environment variable:

```env
REACT_APP_API_URL=your_api_url_here
```

- `REACT_APP_API_URL`: The URL of your backend API endpoint for the chatbot

## Installation

```bash
# Navigate to the ui directory
cd ui

# Install dependencies
npm install

# Install serve (if not already installed)
npm install -g serve

# Build the project
npm run build

# Run the application
serve -s build
```
