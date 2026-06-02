# Objective
## Profile Page Implementation

---

## Description
This objective covers the full implementation of the Profile Page, which is accessible via the Profile Tab in the existing navbar. The page displays the user's avatar, name, and an edit profile option. Clicking "Edit Profile" opens a sheet/drawer that allows the user to update their name, select an avatar from a predefined set of assets, and choose a background color for their avatar container. The profile page also includes several static options and a set of real-time gameplay statistics pulled from the user's flipping game data. The design and layout must strictly follow the provided Figma design.

---

## Objectives Breakdown

### 1. Main Objective Area
Implement the Profile Page as a navigable page accessible from the Profile Tab in the navbar. The page must strictly follow the Figma design provided, displaying the user's avatar, name, and an "Edit Profile" button that opens a sheet/drawer for profile customization.

---

### 2. Secondary Objective Area
The profile page must also display:
- A set of static option items (no functionality required at this stage, with the exception of toggle switches).
- Real gameplay statistics sourced from the user's flipping game data, specifically: **Cards Played**, **Cards Answered**, and **Cards Passed**.

---

### 3. Supporting Tasks

#### 3.1 Navigation
- Add a Profile Tab to the navbar that routes to the Profile Page.

#### 3.2 Profile Page Display
- Display the user's current avatar.
- Display the user's name.
- Display an "Edit Profile" button/link.

#### 3.3 Edit Profile Sheet/Drawer
- Trigger a sheet/drawer when the user clicks "Edit Profile".
- Allow the user to update their name within the sheet.
- Allow the user to select an avatar from the 12 predefined SVG assets.
- Allow the user to choose a background color for the avatar container.
- Dynamically update the circular avatar placeholder based on the user's selections (avatar + background color) so the user sees live feedback.

#### 3.4 Static Profile Options
- Render the following options as static UI elements (no backend functionality):
  - Play History
  - Decks and Cards
  - Notifications
  - Dark Mode
  - Music & Sound
- Implement working toggle switches for **Notifications** and **Dark Mode** (the switches must toggle visually but do not need to trigger any actual functionality).

#### 3.5 Gameplay Statistics
- Display the following three stats using real data from the user's flipping game records:
  - Cards Played
  - Cards Answered
  - Cards Passed

---

### 4. Detailed Breakdown

#### 4.1 Figma Design Compliance
The design and layout of the Profile Page must be followed accurately based on the Figma file provided. No deviations from the provided design are permitted.

#### 4.2 Edit Profile Sheet — Avatar Assets
The avatar selection within the sheet must use the following local SVG assets:

- `assets\svg\avatars\user-avatar (1).svg`
- `assets\svg\avatars\user-avatar (2).svg`
- `assets\svg\avatars\user-avatar (3).svg`
- `assets\svg\avatars\user-avatar (4).svg`
- `assets\svg\avatars\user-avatar (5).svg`
- `assets\svg\avatars\user-avatar (6).svg`
- `assets\svg\avatars\user-avatar (7).svg`
- `assets\svg\avatars\user-avatar (8).svg`
- `assets\svg\avatars\user-avatar (9).svg`
- `assets\svg\avatars\user-avatar (10).svg`
- `assets\svg\avatars\user-avatar (11).svg`
- `assets\svg\avatars\user-avatar (12).svg`

#### 4.3 Dynamic Avatar Preview
The circular profile avatar placeholder inside the sheet must update dynamically as the user makes selections.

##### Nested Details
- The placeholder must reflect the selected avatar image in real time.
- The placeholder's container/background must reflect the selected background color in real time.
- This dynamic update applies only within the sheet as a live preview — it does not require persistence until the user confirms or saves changes (follow Figma design intent).
- No additional avatar sources or colors beyond what is stated may be assumed or added.

---