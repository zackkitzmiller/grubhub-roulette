/**
 * Grubhub Roulette Background Script
 * Service worker for Chrome extension
 */

class BackgroundService {
  constructor() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Handle extension installation
    chrome.runtime.onInstalled.addListener((details) => {
      this.handleInstallation(details);
    });

    // Handle extension startup
    chrome.runtime.onStartup.addListener(() => {
      console.log('Grubhub Roulette extension started');
    });

    // Handle messages from content scripts or popup
    chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
      this.handleMessage(request, sender, sendResponse);
    });
  }

  handleInstallation(details) {
    console.log('Grubhub Roulette installed:', details.reason);

    if (details.reason === 'install') {
      // First time installation
      console.log('Welcome to Grubhub Roulette!');
    } else if (details.reason === 'update') {
      // Extension updated
      console.log('Grubhub Roulette updated to version', chrome.runtime.getManifest().version);
    }
  }

  handleMessage(request, _sender, sendResponse) {
    // Handle any background processing if needed
    console.log('Background received message:', request);

    // For now, just acknowledge the message
    sendResponse({ received: true });
  }
}

// Initialize the background service
new BackgroundService();
