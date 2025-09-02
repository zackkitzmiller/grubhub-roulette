/**
 * Grubhub Roulette Content Script
 * Robust implementation with error handling and fallback selectors
 */

class GrubhubRoulette {
  constructor() {
    this.logger = new Logger("GrubhubRoulette");
    this.selectors = new SelectorManager();
    this.isProcessing = false;
    this.maxRetries = 3;
    this.timeoutMs = 10000;
  }

  async spinTheWheel(options = {}) {
    if (this.isProcessing) {
      this.logger.warn("Already processing, ignoring request");
      return { success: false, message: "Already processing request" };
    }

    this.isProcessing = true;
    this.logger.info("Starting wheel spin with options:", options);

    try {
      // Validate we're on the correct page
      if (!this.validatePage()) {
        throw new Error("Not on a supported Grubhub page");
      }

      // Remove featured/promotional content if enabled
      if (options.removeFeatured !== false) {
        await this.removeFeaturedContent();
      }

      // Load more restaurants if enabled
      if (options.loadMore !== false) {
        await this.loadMoreRestaurants(options.aggressiveLoad);
      }

      // Get restaurant cards and select random one
      const result = await this.selectRandomRestaurant(options.preferRegular);

      this.logger.info("Wheel spin completed successfully");
      return {
        success: true,
        message: "Random restaurant selected!",
        ...result,
      };
    } catch (error) {
      this.logger.error("Error during wheel spin:", error);
      return { success: false, message: error.message };
    } finally {
      this.isProcessing = false;
    }
  }

  validatePage() {
    const url = window.location.href;
    const validPatterns = [
      /grubhub\.com\/lets-eat/,
      /grubhub\.com\/restaurant/,
      /grubhub\.com\/delivery/,
      /grubhub\.com\/takeout/,
      /grubhub\.com\/search/,
    ];

    return validPatterns.some((pattern) => pattern.test(url));
  }

  async removeFeaturedContent() {
    this.logger.info("Removing featured content");

    const topicElements = await this.selectors.findElements("topicComponent");
    if (topicElements.length > 1) {
      // Keep the last one, remove the rest
      for (let i = 0; i < topicElements.length - 1; i++) {
        topicElements[i].remove();
      }
      this.logger.info(`Removed ${topicElements.length - 1} featured sections`);
    }
  }

  async loadMoreRestaurants(aggressive = false) {
    this.logger.info("Attempting to load more restaurants", { aggressive });

    let attempts = 0;
    let maxAttempts = aggressive ? 15 : 5; // 15 attempts for aggressive, 5 for normal
    let totalLoaded = 0;

    while (attempts < maxAttempts) {
      try {
        const loadMoreButton = await this.selectors.findElement(
          "loadMoreButton",
          3000
        );
        if (
          loadMoreButton &&
          loadMoreButton.offsetParent !== null &&
          !loadMoreButton.disabled
        ) {
          // Count restaurants before clicking
          const beforeCount = await this.countRestaurants();

          loadMoreButton.click();
          this.logger.info(
            `Clicked load more button (attempt ${attempts + 1})`
          );

          // Wait for content to load with longer timeout
          await this.delay(3000);

          // Count restaurants after clicking to see if we got new ones
          const afterCount = await this.countRestaurants();
          const newRestaurants = afterCount - beforeCount;

          if (newRestaurants > 0) {
            totalLoaded += newRestaurants;
            this.logger.info(
              `Loaded ${newRestaurants} new restaurants (total: ${totalLoaded})`
            );
          } else {
            this.logger.info("No new restaurants loaded, stopping");
            break;
          }
        } else {
          this.logger.info("Load more button not available or disabled");
          break;
        }
      } catch (error) {
        this.logger.info("No more load more button found");
        break;
      }
      attempts++;
    }

    this.logger.info(
      `Finished loading restaurants. Total attempts: ${attempts}, Total new restaurants: ${totalLoaded}`
    );
  }

  async countRestaurants() {
    const restaurantCards = await this.selectors.findElements("restaurantCard");
    return restaurantCards.length;
  }

  async selectRandomRestaurant(preferRegular = false) {
    this.logger.info("Selecting random restaurant", { preferRegular });

    const restaurantCards = await this.selectors.findElements("restaurantCard");

    if (restaurantCards.length === 0) {
      throw new Error("No restaurant cards found on the page");
    }

    let selectedCards = restaurantCards;
    let selectionType = "all";

    // If preferRegular is enabled, try to filter out featured restaurants
    if (preferRegular) {
      const regularCards = this.filterRegularRestaurants(restaurantCards);
      if (regularCards.length > 0) {
        selectedCards = regularCards;
        selectionType = "regular";
        this.logger.info(
          `Found ${regularCards.length} regular restaurants out of ${restaurantCards.length} total`
        );
      } else {
        this.logger.info("No regular restaurants found, using all restaurants");
      }
    }

    const randomIndex = Math.floor(Math.random() * selectedCards.length);
    const selectedCard = selectedCards[randomIndex];

    // Find the original index in the full list
    const originalIndex = restaurantCards.indexOf(selectedCard);

    this.logger.info(
      `Selected ${selectionType} restaurant ${randomIndex + 1} of ${
        selectedCards.length
      } (original index: ${originalIndex + 1})`
    );

    // Remove all cards except the selected one
    let removedCount = 0;
    for (let i = 0; i < restaurantCards.length; i++) {
      if (i !== originalIndex) {
        restaurantCards[i].remove();
        removedCount++;
      }
    }

    return {
      selectedIndex: originalIndex,
      totalRestaurants: restaurantCards.length,
      regularRestaurants: preferRegular ? selectedCards.length : null,
      selectionType: selectionType,
      removedCount: removedCount,
    };
  }

  filterRegularRestaurants(restaurantCards) {
    // Filter out restaurants that appear to be featured/promoted
    return restaurantCards.filter((card) => {
      // Check for common featured/promoted indicators
      const featuredIndicators = [
        '[class*="featured"]',
        '[class*="promoted"]',
        '[class*="sponsored"]',
        '[class*="ad"]',
        '[data-testid*="featured"]',
        '[data-testid*="promoted"]',
        ".promotion",
        ".featured-restaurant",
      ];

      // Check if the card or its parent contains featured indicators
      for (const indicator of featuredIndicators) {
        if (
          card.matches(indicator) ||
          card.querySelector(indicator) ||
          card.closest(indicator)
        ) {
          return false; // This is a featured restaurant
        }
      }

      // Check for promotional badges or text
      const textContent = card.textContent.toLowerCase();
      const promotionalTerms = ["featured", "promoted", "sponsored", "ad"];

      for (const term of promotionalTerms) {
        if (textContent.includes(term)) {
          return false;
        }
      }

      return true; // This appears to be a regular restaurant
    });
  }

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

/**
 * Selector management with fallback options
 */
class SelectorManager {
  constructor() {
    this.selectorMap = {
      topicComponent: [
        '[data-testid="topic-component"]',
        ".topic-component",
        '[class*="topic"]',
        '[class*="featured"]',
      ],
      restaurantCard: [
        '[data-testid="grid-component-cell-wrapper"]',
        '[data-testid="restaurant-card"]',
        '[data-testid="search-result-restaurant"]',
        '[data-testid="search-result"]',
        ".restaurant-card",
        ".search-result",
        '[class*="restaurant"]',
        '[class*="grid-cell"]',
        '[class*="search-result"]',
        "article",
        '[role="article"]',
      ],
      loadMoreButton: [
        '[data-testid="grid-component-load-more-button"]',
        '[data-testid="load-more"]',
        'button[class*="load-more"]',
        'button:contains("Load More")',
        'button:contains("Show More")',
      ],
    };
  }

  async findElement(elementType, timeoutMs = 5000) {
    const selectors = this.selectorMap[elementType];
    if (!selectors) {
      throw new Error(`Unknown element type: ${elementType}`);
    }

    return new Promise((resolve, reject) => {
      let observer = null;

      const cleanup = () => {
        if (observer) {
          observer.disconnect();
        }
      };

      const timeout = setTimeout(() => {
        cleanup();
        reject(
          new Error(`Element ${elementType} not found within ${timeoutMs}ms`)
        );
      }, timeoutMs);

      const checkElement = () => {
        for (const selector of selectors) {
          const element = document.querySelector(selector);
          if (element) {
            clearTimeout(timeout);
            cleanup();
            resolve(element);
            return true;
          }
        }
        return false;
      };

      // Check immediately
      if (checkElement()) return;

      // Set up observer for dynamic content
      observer = new MutationObserver(() => {
        checkElement();
      });

      observer.observe(document.body, {
        childList: true,
        subtree: true,
      });
    });
  }

  async findElements(elementType) {
    const selectors = this.selectorMap[elementType];
    if (!selectors) {
      throw new Error(`Unknown element type: ${elementType}`);
    }

    for (const selector of selectors) {
      const elements = document.querySelectorAll(selector);
      if (elements.length > 0) {
        return Array.from(elements);
      }
    }

    return [];
  }
}

/**
 * Simple logging utility
 */
class Logger {
  constructor(prefix) {
    this.prefix = prefix;
  }

  info(message, ...args) {
    console.log(`[${this.prefix}] INFO:`, message, ...args);
  }

  warn(message, ...args) {
    console.warn(`[${this.prefix}] WARN:`, message, ...args);
  }

  error(message, ...args) {
    console.error(`[${this.prefix}] ERROR:`, message, ...args);
  }
}

// Initialize the roulette instance
const grubhubRoulette = new GrubhubRoulette();

// Message listener
chrome.runtime.onMessage.addListener((request, _sender, sendResponse) => {
  if (request.action === "spinTheWheel") {
    grubhubRoulette
      .spinTheWheel(request.options)
      .then((result) => sendResponse(result))
      .catch((error) =>
        sendResponse({
          success: false,
          message: error.message,
        })
      );

    // Return true to indicate we'll send response asynchronously
    return true;
  } else {
    console.log("Unknown action received:", request.action);
    sendResponse({ success: false, message: "Unknown action" });
  }
});
