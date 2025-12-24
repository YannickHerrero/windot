// ==UserScript==
// @name           Leader Key Navigation
// @description    Ctrl+A as leader key for vim-like navigation
// @author         windot
// @version        1.2
// @include        main
// ==/UserScript==

(function() {
  'use strict';
  
  // Leader key is now Ctrl+A (won't interfere with typing)
  const LEADER_KEY = 'a';
  const LEADER_MODIFIER = 'ctrlKey';
  
  let leaderActive = false;
  let statusIndicator = null;
  
  // Key bindings with descriptions
  const leaderBindings = {
    'a': { fn: () => showTabPicker(), desc: 'tab picker' },
    'b': { fn: () => showTabPicker(), desc: 'tab picker' },
    't': { fn: () => {
      gBrowser.selectedTab = gBrowser.addTrustedTab('about:newtab');
      gURLBar.focus();
      gURLBar.select();
    }, desc: 'new tab' },
    'w': { fn: () => gBrowser.removeCurrentTab(), desc: 'close tab' },
    'j': { fn: () => gBrowser.tabContainer.advanceSelectedTab(-1, true), desc: 'prev tab' },
    'k': { fn: () => gBrowser.tabContainer.advanceSelectedTab(1, true), desc: 'next tab' },
    'h': { fn: () => BrowserBack(), desc: 'back' },
    'l': { fn: () => BrowserForward(), desc: 'forward' },
    '1': { fn: () => gBrowser.selectTabAtIndex(0), desc: 'tab 1' },
    '2': { fn: () => gBrowser.selectTabAtIndex(1), desc: 'tab 2' },
    '3': { fn: () => gBrowser.selectTabAtIndex(2), desc: 'tab 3' },
    '4': { fn: () => gBrowser.selectTabAtIndex(3), desc: 'tab 4' },
    '5': { fn: () => gBrowser.selectTabAtIndex(4), desc: 'tab 5' },
    '6': { fn: () => gBrowser.selectTabAtIndex(5), desc: 'tab 6' },
    '7': { fn: () => gBrowser.selectTabAtIndex(6), desc: 'tab 7' },
    '8': { fn: () => gBrowser.selectTabAtIndex(7), desc: 'tab 8' },
    '9': { fn: () => gBrowser.selectTabAtIndex(-1), desc: 'last tab' },
    'o': { fn: () => { gURLBar.focus(); gURLBar.select(); }, desc: 'url bar' },
    '/': { fn: () => gBrowser.getFindBar().then(f => f.open()), desc: 'find' },
    'r': { fn: () => BrowserReload(), desc: 'reload' },
    'p': { fn: () => {
      let tab = gBrowser.selectedTab;
      tab.pinned ? gBrowser.unpinTab(tab) : gBrowser.pinTab(tab);
    }, desc: 'pin tab' },
    'd': { fn: () => {
      let newTab = gBrowser.duplicateTab(gBrowser.selectedTab);
      gBrowser.selectedTab = newTab;
    }, desc: 'duplicate' },
    'u': { fn: () => undoCloseTab(), desc: 'undo close' },
    'm': { fn: () => gBrowser.selectedTab.toggleMuteAudio(), desc: 'mute' },
    'g': { fn: () => gBrowser.selectTabAtIndex(0), desc: 'first tab' },
    'x': { fn: () => gBrowser.removeCurrentTab(), desc: 'close tab' },
  };
  
  // Build help text from bindings
  function getHelpText() {
    return `C-a tabs    t new     w close   x close
j   prev    k next    h back    l forward
o   url     / find    r reload
d   dup     p pin     m mute    u undo
1-9 tab N   g first`;
  }
  
  // Create visual indicator
  function createIndicator() {
    statusIndicator = document.createElement('div');
    statusIndicator.id = 'leader-key-indicator';
    statusIndicator.style.cssText = `
      position: fixed;
      bottom: 10px;
      right: 10px;
      padding: 10px 14px;
      background: rgba(0, 0, 0, 0.9);
      color: #e0e0e0;
      border-radius: 6px;
      font-family: monospace;
      font-size: 13px;
      z-index: 99999;
      display: none;
      white-space: pre;
      line-height: 1.6;
      border: 1px solid rgba(255, 255, 255, 0.1);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
    `;
    document.documentElement.appendChild(statusIndicator);
  }
  
  function showIndicator() {
    if (!statusIndicator) createIndicator();
    statusIndicator.textContent = getHelpText();
    statusIndicator.style.display = 'block';
  }
  
  function hideIndicator() {
    if (statusIndicator) {
      statusIndicator.style.display = 'none';
    }
  }
  
  function activateLeader() {
    leaderActive = true;
    showIndicator();
  }
  
  function deactivateLeader() {
    leaderActive = false;
    hideIndicator();
  }
  
  // Tab picker implementation
  function showTabPicker() {
    // Remove existing overlay if present
    let existingOverlay = document.getElementById('tab-picker-overlay');
    if (existingOverlay) existingOverlay.remove();
    
    // Create overlay
    let overlay = document.createElement('div');
    overlay.id = 'tab-picker-overlay';
    overlay.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.7);
      display: flex;
      flex-direction: column;
      align-items: center;
      padding-top: 100px;
      z-index: 99999;
    `;
    
    // Search input
    let searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'Search tabs...';
    searchInput.style.cssText = `
      width: 500px;
      padding: 12px 16px;
      font-size: 16px;
      border: 2px solid #0060df;
      border-radius: 8px;
      margin-bottom: 16px;
      outline: none;
      background: #fff;
      color: #000;
    `;
    
    // Tab list container
    let tabList = document.createElement('div');
    tabList.style.cssText = `
      width: 500px;
      max-height: 400px;
      overflow-y: auto;
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    `;
    
    let selectedIndex = 0;
    let filteredTabs = [];
    
    function renderTabs(filter = '') {
      tabList.innerHTML = '';
      filteredTabs = Array.from(gBrowser.tabs).filter(tab => {
        const title = tab.label.toLowerCase();
        const url = tab.linkedBrowser?.currentURI?.spec?.toLowerCase() || '';
        return title.includes(filter.toLowerCase()) || url.includes(filter.toLowerCase());
      });
      
      filteredTabs.forEach((tab, index) => {
        let item = document.createElement('div');
        item.style.cssText = `
          padding: 12px 16px;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 12px;
          border-bottom: 1px solid #eee;
          ${index === selectedIndex ? 'background: #0060df; color: #fff;' : 'color: #000;'}
        `;
        
        // Favicon
        let favicon = document.createElement('img');
        favicon.src = tab.image || 'chrome://branding/content/icon32.png';
        favicon.style.cssText = 'width: 16px; height: 16px;';
        favicon.onerror = () => { favicon.src = 'chrome://branding/content/icon32.png'; };
        
        // Title
        let title = document.createElement('span');
        title.textContent = tab.label;
        title.style.cssText = 'flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;';
        
        // Index hint
        let indexHint = document.createElement('span');
        indexHint.textContent = `[${index + 1}]`;
        indexHint.style.cssText = 'opacity: 0.5; font-size: 12px;';
        
        item.appendChild(favicon);
        item.appendChild(title);
        item.appendChild(indexHint);
        
        item.onclick = () => {
          gBrowser.selectedTab = tab;
          closeOverlay();
        };
        
        item.onmouseenter = () => {
          selectedIndex = index;
          renderTabs(searchInput.value);
        };
        
        tabList.appendChild(item);
      });
    }
    
    function closeOverlay() {
      overlay.remove();
    }
    
    function updateSelection(newIndex) {
      selectedIndex = Math.max(0, Math.min(newIndex, filteredTabs.length - 1));
      renderTabs(searchInput.value);
      
      // Scroll selected item into view
      let items = tabList.children;
      if (items[selectedIndex]) {
        items[selectedIndex].scrollIntoView({ block: 'nearest' });
      }
    }
    
    searchInput.oninput = () => {
      selectedIndex = 0;
      renderTabs(searchInput.value);
    };
    
    searchInput.onkeydown = (e) => {
      switch(e.key) {
        case 'ArrowDown':
        case 'Tab':
          if (!e.shiftKey) {
            e.preventDefault();
            updateSelection(selectedIndex + 1);
          } else {
            e.preventDefault();
            updateSelection(selectedIndex - 1);
          }
          break;
        case 'ArrowUp':
          e.preventDefault();
          updateSelection(selectedIndex - 1);
          break;
        case 'Enter':
          e.preventDefault();
          if (filteredTabs[selectedIndex]) {
            gBrowser.selectedTab = filteredTabs[selectedIndex];
            closeOverlay();
          }
          break;
        case 'Escape':
          e.preventDefault();
          closeOverlay();
          break;
      }
    };
    
    overlay.onclick = (e) => {
      if (e.target === overlay) closeOverlay();
    };
    
    overlay.appendChild(searchInput);
    overlay.appendChild(tabList);
    document.documentElement.appendChild(overlay);
    
    renderTabs();
    searchInput.focus();
  }
  
  // Main keyboard handler
  function handleKeydown(event) {
    const target = event.target;
    
    // Allow escape to close tab picker
    if (event.key === 'Escape') {
      let overlay = document.getElementById('tab-picker-overlay');
      if (overlay) {
        overlay.remove();
        event.preventDefault();
        event.stopPropagation();
        return;
      }
      // Also cancel leader mode on Escape
      if (leaderActive) {
        deactivateLeader();
        event.preventDefault();
        event.stopPropagation();
        return;
      }
    }
    
    // Check for leader key (Ctrl+A)
    if (!leaderActive && event.key.toLowerCase() === LEADER_KEY && event[LEADER_MODIFIER] && !event.altKey && !event.metaKey && !event.shiftKey) {
      event.preventDefault();
      event.stopPropagation();
      activateLeader();
      return;
    }
    
    // Handle leader commands
    if (leaderActive) {
      event.preventDefault();
      event.stopPropagation();
      
      const key = event.key.toLowerCase();
      const binding = leaderBindings[key] || leaderBindings[event.key];
      
      if (binding) {
        try {
          binding.fn();
        } catch (e) {
          console.error('Leader key binding error:', e);
        }
      }
      
      deactivateLeader();
    }
  }
  
  // Install event listener with capture to get events before they reach content
  window.addEventListener('keydown', handleKeydown, true);
  
  // Cleanup on window close
  window.addEventListener('unload', () => {
    window.removeEventListener('keydown', handleKeydown, true);
    if (statusIndicator) {
      statusIndicator.remove();
    }
  });
  
  console.log('Leader key navigation loaded. Press Ctrl+A to see commands.');
})();
