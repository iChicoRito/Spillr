# Objective
## Audio System Enhancement: Background Music, Sound Effects, and Volume Control Fixes

---

## Description
This objective focuses on fixing and improving the audio and sound system within the app. The task involves addressing issues with background music playback behavior, implementing proper volume fading effects for background music, synchronizing sound effect playback with background music volume, correcting device volume controls to affect both background music and sound effects uniformly, and implementing a structured "Music & Sounds" settings sheet in the profile page. All changes must align with the provided Figma design reference.

---

## Objectives Breakdown

### 1. Main Objective Area
Establish a cohesive audio system that properly manages background music playback, sound effect interactions, and volume controls across the app while following the specified design reference.

---

### 2. Secondary Objective Area
Implement a user-facing "Music & Sounds" settings interface in the profile page that allows users to adjust Master Volume, Background Music volume, and Sound Effects volume independently, ensuring consistency with device media volume controls.

---

### 3. Supporting Tasks

#### 3.1 Background Music Behavior
- Fix background music to stop playing when the app is closed or moved to background (matching standard app behavior)
- Ensure background music resumes properly when the app is reopened or returned to foreground

#### 3.2 Volume Fading and Adjustment
- Implement volume fade-out for background music when navigating away from the Play Page
- Implement slow fade-down of background music volume when sound effects are triggered
- Ensure background music remains at default volume while on the Play Page

#### 3.3 Device Volume Control Synchronization
- Fix device media volume adjustment to control both background music and sound effects
- Ensure sound effects volume is no longer controlled by the ringtone slider
- Align both background music and sound effects with media volume controls

#### 3.4 Settings Implementation
- Implement "Music & Sounds" settings sheet in the profile page
- Create volume adjustment controls for Master Volume, Background Music, and Sound Effects

---

### 4. Detailed Breakdown

#### 4.1 Background Music Playback
The background music must respect standard app lifecycle behavior by stopping when the app is closed or running in the background, and only resume when the app is returned to active use.

#### 4.2 Volume Control Hierarchy
The audio system must support three distinct volume controls:
- **Master Volume**: Overall control for all audio
- **Background Music Volume**: Independent control for background music levels
- **Sound Effects Volume**: Independent control for sound effect levels

#### 4.3 Adaptive Volume Behavior
Background music should respond dynamically to page navigation and sound effect triggers:
- Default volume on Play Page
- Faded volume (barely audible) on all other pages
- Gradual fade when sound effects are triggered

##### Implementation Reference
- Follow the Figma design layout exactly as specified in the reference image
- Reference image location: `assets\reference\music-sound-option.png`

---