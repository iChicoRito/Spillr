# Objective
## Redirection to Dashboard AKA the Play Page

---

## Description

After completing the onboarding screen where the user enters their name, the application currently redirects to a placeholder page. The objective is to replace that placeholder with the fully designed **Play Page**, following the exact layout and design already established in Figma. The Play Page serves as the main dashboard where users can browse and select a deck to begin their experience. This includes a branded header, a personalized welcome message, a swipeable deck carousel with interactive snap and scale behavior, and a bottom navigation bar — all implemented strictly according to the Figma design.

---

## Objectives Breakdown

### 1. Main Objective Area

Replace the current post-onboarding placeholder page with the actual **Play Page**, ensuring the layout, visual design, and component structure match the Figma design exactly.

---

### 2. Secondary Objective Area

Deliver a fully interactive and visually consistent Play Page that includes:
- A branded header with logo and profile/streak elements
- A personalized welcome message using the user's entered name
- A swipeable deck carousel with snap and scale interactions
- A bottom navigation bar matching the Figma design

---

### 3. Supporting Tasks

#### 3.1 Post-Onboarding Redirection
- Remove the existing redirect to the placeholder page
- Implement redirect to the Play Page upon successful name submission during onboarding

#### 3.2 Header Implementation
- Display the Spillr logo using the asset at `assets/svg/Spillr.svg`
- Add a placeholder element for the user's profile
- Add a streak indicator beside the profile placeholder using the asset at `assets/svg/streak-icon.svg`

#### 3.3 Welcome Message
- Display a personalized welcome message using the name entered during onboarding:
  ```
  Hey, [InsertedName]
  Ready to Spill?
  Pick a deck and start the conversation.
  ```

#### 3.4 Deck Section
- Display a section title "Choose Your Deck" centered on screen
- Render the decks as a horizontally swipeable carousel
- Each deck card must display: variant color, category name, and description

#### 3.5 Carousel Interactivity
- Implement smooth left/right swipe behavior for the carousel
- Center-snap the active card when the user swipes
- Scale up the center card to visually indicate it is the most active/focused card
- Display a **"Play [CategoryName]"** label that updates based on the currently centered card

#### 3.6 Icons
- Use **HugeIcons** exclusively for all iconography throughout the Play Page

#### 3.7 Bottom Navigation Bar
- Implement the navbar exactly as shown in the Figma design
- Include exactly 3 navigation items: **Decks**, **Play**, **Profile**

---

### 4. Detailed Breakdown

#### 4.1 Header Component
The header must include three elements arranged as per the Figma design:
1. The Spillr logo (`assets/svg/Spillr.svg`)
2. A profile placeholder
3. A streak indicator icon (`assets/svg/streak-icon.svg`) placed beside the profile placeholder

#### 4.2 Welcome Message Component
The welcome message must dynamically inject the name the user entered during the onboarding screen. The message format is fixed and must not be altered:
- Line 1: `Hey, [InsertedName]`
- Line 2: `Ready to Spill?`
- Line 3: `Pick a deck and start the conversation.`

#### 4.3 Deck Carousel Component
The carousel is the primary interactive element of the Play Page.

##### Nested Details
- Decks are displayed in a horizontal carousel layout
- Swiping left or right transitions between decks smoothly
- The card in the center position snaps into place
- The centered card is scaled up relative to adjacent cards to indicate active focus
- The "Play [CategoryName]" label updates dynamically to reflect the currently centered deck's category name
- Each deck card displays its own variant color, category name, and description as shown in the Figma design
- No assumptions are made about the number of decks or their content beyond what is stated

#### 4.4 Bottom Navigation Bar
The navbar must replicate the Figma design exactly and contain only the following three items:
- **Decks**
- **Play**
- **Profile**

> **Scope Note:** Only the Play Page is in scope for this objective. The Decks and Profile pages are not part of this task.

---