/**
 * Grubhub Roulette Popup Script
 * Enhanced with error handling and user feedback
 */

class PopupController {
  constructor() {
    this.spinButton = null;
    this.statusElement = null;
    this.isSpinning = false;
    this.init();
  }

  init() {
    // Wait for both DOM and Chrome APIs to be ready
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", () => {
        this.initializeExtension();
      });
    } else {
      this.initializeExtension();
    }
  }

  initializeExtension() {
    // Check if we're in a proper extension context
    if (typeof chrome === "undefined") {
      console.error("Chrome extension APIs not available");
      this.showError("Extension not properly loaded");
      return;
    }

    // Log available Chrome APIs for debugging
    console.log("Chrome APIs available:", {
      tabs: !!chrome.tabs,
      storage: !!chrome.storage,
      runtime: !!chrome.runtime,
    });

    this.setupElements();
    this.setupEventListeners();
  }

  showError(message) {
    const container = document.querySelector(".container");
    if (container) {
      container.innerHTML = `
        <h1><img src="icon128.png" alt="Grubhub Roulette"></h1>
        <div class="status-message error">${message}</div>
      `;
    }
  }

  setupElements() {
    this.spinButton = document.getElementById("spinWheelButton");
    this.statusElement = document.getElementById("status");
    this.removeFeaturedCheckbox = document.getElementById("removeFeatured");
    this.loadMoreCheckbox = document.getElementById("loadMore");
    this.aggressiveLoadCheckbox = document.getElementById("aggressiveLoad");
    this.preferRegularCheckbox = document.getElementById("preferRegular");
    this.optionsToggle = document.getElementById("optionsToggle");
    this.optionsPanel = document.getElementById("optionsPanel");

    if (!this.spinButton) {
      console.error("Spin button not found");
      return;
    }

    // Create status element if it doesn't exist
    if (!this.statusElement) {
      this.statusElement = document.createElement("div");
      this.statusElement.id = "status";
      this.statusElement.className = "status-message";
      this.spinButton.parentNode.insertBefore(
        this.statusElement,
        this.spinButton.nextSibling
      );
    }

    // Load saved preferences
    this.loadPreferences();
  }

  setupEventListeners() {
    if (!this.spinButton) return;

    this.spinButton.addEventListener("click", () => {
      this.handleSpinClick();
    });

    // Options toggle functionality
    if (this.optionsToggle && this.optionsPanel) {
      this.optionsToggle.addEventListener("click", () => {
        this.toggleOptions();
      });
    }

    // Save preferences when checkboxes change
    if (this.removeFeaturedCheckbox) {
      this.removeFeaturedCheckbox.addEventListener("change", () => {
        this.savePreferences();
      });
    }

    if (this.loadMoreCheckbox) {
      this.loadMoreCheckbox.addEventListener("change", () => {
        this.savePreferences();
      });
    }

    if (this.aggressiveLoadCheckbox) {
      this.aggressiveLoadCheckbox.addEventListener("change", () => {
        this.savePreferences();
      });
    }

    if (this.preferRegularCheckbox) {
      this.preferRegularCheckbox.addEventListener("change", () => {
        this.savePreferences();
      });
    }
  }

  async handleSpinClick() {
    if (this.isSpinning) {
      this.showStatus("Already spinning...", "warning");
      return;
    }

    try {
      this.setSpinning(true);
      this.showStatus("Spinning the wheel...", "loading");

      const tabs = await this.getCurrentTab();
      if (!tabs || tabs.length === 0) {
        throw new Error("No active tab found");
      }

      const tab = tabs[0];

      // Validate we're on a Grubhub page
      if (!this.isValidGrubhubPage(tab.url)) {
        throw new Error(
          "Please navigate to a Grubhub restaurant listing page first"
        );
      }

      const options = this.getOptions();
      const response = await this.sendMessageToTab(tab.id, {
        action: "spinTheWheel",
        options: options,
      });

      if (response && response.success) {
        this.showStatus(response.message, "success");
        if (response.totalRestaurants) {
          this.showStatus(
            `🎉 Selected 1 restaurant out of ${response.totalRestaurants}!`,
            "success"
          );
        }
      } else {
        throw new Error(response?.message || "Failed to spin the wheel");
      }
    } catch (error) {
      console.error("Error spinning wheel:", error);
      this.showStatus(error.message, "error");
    } finally {
      this.setSpinning(false);
    }
  }

  getCurrentTab() {
    return new Promise((resolve, reject) => {
      if (!chrome.tabs) {
        reject(new Error("Chrome tabs API not available"));
        return;
      }

      try {
        chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
          if (chrome.runtime.lastError) {
            reject(new Error(chrome.runtime.lastError.message));
          } else {
            resolve(tabs);
          }
        });
      } catch (error) {
        reject(new Error("Error accessing tabs API: " + error.message));
      }
    });
  }

  sendMessageToTab(tabId, message) {
    return new Promise((resolve, reject) => {
      if (!chrome.tabs) {
        reject(new Error("Chrome tabs API not available"));
        return;
      }

      const timeout = setTimeout(() => {
        reject(new Error("Request timed out"));
      }, 15000); // 15 second timeout

      try {
        chrome.tabs.sendMessage(tabId, message, (response) => {
          clearTimeout(timeout);

          if (chrome.runtime.lastError) {
            reject(new Error(chrome.runtime.lastError.message));
          } else {
            resolve(response);
          }
        });
      } catch (error) {
        clearTimeout(timeout);
        reject(new Error("Error sending message: " + error.message));
      }
    });
  }

  isValidGrubhubPage(url) {
    if (!url) return false;

    const validPatterns = [
      /grubhub\.com\/lets-eat/,
      /grubhub\.com\/restaurant/,
      /grubhub\.com\/delivery/,
      /grubhub\.com\/takeout/,
      /grubhub\.com\/search/,
    ];

    return validPatterns.some((pattern) => pattern.test(url));
  }

  setSpinning(spinning) {
    this.isSpinning = spinning;
    if (this.spinButton) {
      this.spinButton.disabled = spinning;
      this.spinButton.textContent = spinning
        ? "Spinning..."
        : "Spin the Wheel!";
    }
  }

  showStatus(message, type = "info") {
    if (!this.statusElement) return;

    this.statusElement.textContent = message;
    this.statusElement.className = "status-message " + type;

    // Auto-hide success messages after 3 seconds
    if (type === "success") {
      setTimeout(() => {
        if (this.statusElement.textContent === message) {
          this.statusElement.textContent = "";
          this.statusElement.className = "status-message";
        }
      }, 3000);
    }
  }

  toggleOptions() {
    if (!this.optionsPanel || !this.optionsToggle) return;

    const isHidden = this.optionsPanel.style.display === "none";
    const arrow = this.optionsToggle.querySelector(".toggle-arrow");

    if (isHidden) {
      this.optionsPanel.style.display = "block";
      if (arrow) arrow.classList.add("rotated");
    } else {
      this.optionsPanel.style.display = "none";
      if (arrow) arrow.classList.remove("rotated");
    }
  }

  getOptions() {
    return {
      removeFeatured: this.removeFeaturedCheckbox
        ? this.removeFeaturedCheckbox.checked
        : true,
      loadMore: this.loadMoreCheckbox ? this.loadMoreCheckbox.checked : true,
      aggressiveLoad: this.aggressiveLoadCheckbox
        ? this.aggressiveLoadCheckbox.checked
        : false,
      preferRegular: this.preferRegularCheckbox
        ? this.preferRegularCheckbox.checked
        : false,
    };
  }

  loadPreferences() {
    // Check if chrome.storage is available
    if (!chrome.storage || !chrome.storage.sync) {
      console.warn("Chrome storage API not available, using defaults");
      this.setDefaultPreferences();
      return;
    }

    try {
      chrome.storage.sync.get(
        ["removeFeatured", "loadMore", "aggressiveLoad", "preferRegular"],
        (result) => {
          if (chrome.runtime.lastError) {
            console.warn(
              "Error loading preferences:",
              chrome.runtime.lastError
            );
            this.setDefaultPreferences();
            return;
          }

          if (this.removeFeaturedCheckbox) {
            this.removeFeaturedCheckbox.checked =
              result.removeFeatured !== false;
          }
          if (this.loadMoreCheckbox) {
            this.loadMoreCheckbox.checked = result.loadMore !== false;
          }
          if (this.aggressiveLoadCheckbox) {
            this.aggressiveLoadCheckbox.checked =
              result.aggressiveLoad === true;
          }
          if (this.preferRegularCheckbox) {
            this.preferRegularCheckbox.checked = result.preferRegular === true;
          }
        }
      );
    } catch (error) {
      console.warn("Error accessing storage:", error);
      this.setDefaultPreferences();
    }
  }

  setDefaultPreferences() {
    // Set default values when storage is not available
    if (this.removeFeaturedCheckbox) {
      this.removeFeaturedCheckbox.checked = true;
    }
    if (this.loadMoreCheckbox) {
      this.loadMoreCheckbox.checked = true;
    }
    if (this.aggressiveLoadCheckbox) {
      this.aggressiveLoadCheckbox.checked = false;
    }
    if (this.preferRegularCheckbox) {
      this.preferRegularCheckbox.checked = false;
    }
  }

  savePreferences() {
    // Check if chrome.storage is available
    if (!chrome.storage || !chrome.storage.sync) {
      console.warn("Chrome storage API not available, preferences not saved");
      return;
    }

    try {
      const options = this.getOptions();
      chrome.storage.sync.set(options, () => {
        if (chrome.runtime.lastError) {
          console.warn("Error saving preferences:", chrome.runtime.lastError);
        }
      });
    } catch (error) {
      console.warn("Error saving preferences:", error);
    }
  }
}

// Initialize the popup controller
new PopupController();
