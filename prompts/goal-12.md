# Objective
## In-Game and Lobby Background Music / Sound Effects

---

## Description
This objective covers the integration of background music (BGM) and sound effects (SFX) across the application's lobby and in-game screens. Specific audio assets are assigned to each screen and interaction. BGM tracks alternate between two files depending on context, while SFX assets are triggered by specific in-game events and dialog interactions.

---

## Objectives Breakdown

### 1. Main Objective Area
Implement background music and sound effects throughout the application using the provided audio assets, covering the lobby screen, the in-game (card flipping) screen, in-game event SFXs, and dialog/modal pop-ups.

---

### 2. Secondary Objective Area
Ensure that background music rotates between two designated tracks per screen context — alternating on each app reopen (lobby) or each game start (in-game) — and that all dialogs/modals share a single unified SFX.

---

### 3. Supporting Tasks

#### 3.1 Lobby BGM Setup
- Use `assets/sounds/lobby-bgm (1).m4a` and `assets/sounds/lobby-bgm (2).m4a` as the lobby background music
- Alternate between the two tracks each time the application is reopened

#### 3.2 In-Game BGM Setup
- Use `assets/sounds/in-game-bgm (1).m4a` and `assets/sounds/in-game-bgm (2).m4a` as the in-game background music for the card flipping screen
- Alternate between the two tracks each time a new game starts

#### 3.3 In-Game Sound Effects
- Assign each SFX asset to its corresponding in-game event based on the asset name
- Use `assets/sounds/card-answered.mp3` when a card is answered
- Use `assets/sounds/card-pass.mp3` when a card is passed
- Use `assets/sounds/flipping-card.mp3` when a card is flipped
- Use `assets/sounds/ending-screen.mp3` when the ending screen appears

#### 3.4 Dialog / Modal SFX Setup
- Use `assets/sounds/confirmation-dialog.mp3` as the shared SFX for all dialog and modal pop-ups
- All types of dialogs/modals use the same single audio file

---

### 4. Detailed Breakdown

#### 4.1 Lobby Background Music
Two BGM tracks are designated for the lobby screen. The active track alternates between `lobby-bgm (1).m4a` and `lobby-bgm (2).m4a` each time the application is reopened.

#### 4.2 In-Game Background Music
Two BGM tracks are designated for the in-game (card flipping) screen. The active track alternates between `in-game-bgm (1).m4a` and `in-game-bgm (2).m4a` each time a game session starts.

#### 4.3 Sound Effects Mapping
Each SFX asset is mapped to a specific in-game event or UI interaction:

##### SFX Asset Reference
- `card-answered.mp3` → Triggered when a card is answered
- `card-pass.mp3` → Triggered when a card is passed
- `flipping-card.mp3` → Triggered when a card is being flipped
- `ending-screen.mp3` → Triggered when the ending screen is displayed
- `confirmation-dialog.mp3` → Triggered for all dialog and modal pop-ups (shared universally)

---