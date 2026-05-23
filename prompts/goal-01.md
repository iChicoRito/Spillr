# Objective
## Design an Onboarding Screen Based on Figma Design Reference Accurately

---

## Description

The objective is to design and implement an onboarding flow for the **Spillr** application that accurately follows the provided Figma design reference. The flow consists of three onboarding screens, followed by a user name input screen and a name confirmation screen. All screens must maintain consistent layout, typography, color scheme, and component structure as specified. The application operates in an offline environment, utilizing **Drift** as the local database. All UI elements must adhere to the defined branding guidelines, and components must be built in a reusable manner for future scalability.

---

## Objectives Breakdown

### 1. Main Objective Area

Accurately implement the onboarding screen flow for the Spillr application by following the Figma design reference, ensuring visual and structural fidelity across all screens.

---

### 2. Secondary Objective Area

Support the onboarding flow with a name input and name confirmation screen that maintain the same layout, font size, color, and design language as the onboarding screens. Additionally, ensure offline data persistence using Drift database and establish a reusable component architecture for future development.

---

### 3. Supporting Tasks

#### 3.1 Onboarding Screen Implementation
- Create **Screen 1** with Title: *"Vibe Check"* and Subtitle: *"Awkward silence gets cancelled before it even starts, bestie."*
- Create **Screen 2** with Title: *"Tea Time"* and Subtitle: *"Pick a card and let the group reveal their funniest, weirdest lore."*
- Create **Screen 3** with Title: *"Main Character"* and Subtitle: *"Play with friends, dates, or anyone brave enough to answer."*

#### 3.2 Name Input & Confirmation Screen Implementation
- Implement the **Name Input Screen** following the same layout, font size, and color as the onboarding screens
- Implement the **Name Confirmation Screen** that displays a personalized message using the entered name

#### 3.3 Database Setup
- Configure **Drift** as the offline-only local database for storing the user's name

#### 3.4 Component Architecture
- Build screens and UI elements as **reusable components** for future implementation

---

### 4. Detailed Breakdown

#### 4.1 Onboarding Screens (Screen 1–3)

Each onboarding screen follows a consistent layout and branding:

- **Title styling:** Neutral/700 color, using the defined title text style
- **Subtitle styling:** Neutral/400 color, using the defined subtitle text style
- **Primary brand color:** Teal/500

##### Screen Content
- Screen 1 — Title: *Vibe Check* | Subtitle: *Awkward silence gets cancelled before it even starts, bestie.*
- Screen 2 — Title: *Tea Time* | Subtitle: *Pick a card and let the group reveal their funniest, weirdest lore.*
- Screen 3 — Title: *Main Character* | Subtitle: *Play with friends, dates, or anyone brave enough to answer.*

---

#### 4.2 Name Input Screen

Displayed after the three onboarding screens. Must follow the same layout, font size, color, and design language.

##### Text Specifications
- **Heading:** *"What should we call you?"* — Size: 24, Semibold
- **Subtext:** *"Your name personalized your Spillr"* — Size: 16, Normal
- **Text Field:** Must match the exact appearance shown in the provided image reference

##### Nested Details
- Text field design must replicate the provided image reference exactly
- No additional fields or inputs beyond what is specified

---

#### 4.3 Name Confirmation Screen

Displayed after the user has entered their name.

##### Text Specifications
- **Heading:** *"Let's Start Spilling, [name]"* — Size: 48, Semibold
- **Subtext:** *"Pull a card, answer with confidence, and let the chaos begin."* — Size: 18, Normal

##### Nested Details
- The `[name]` placeholder must be dynamically replaced with the user-entered name
- Layout, font size, and color must be consistent with all preceding screens
- No additional content beyond what is specified

---