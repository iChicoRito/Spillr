# Objective
## Play Page Card Redesign with Active/Inactive State Animations

---

## Description

This objective focuses on redesigning the cards on the Play Page to match a provided Figma design. The redesign involves two distinct card states — **active** and **inactive** — each with their own visual properties. A smooth animation must be implemented to transition between these two states, specifically involving the movement of rounded arc elements and the appearance of card content.

---

## Objectives Breakdown

### 1. Main Objective Area

Redesign the Play Page cards to visually match the provided Figma design, incorporating both active and inactive card states with their respective distinct properties.

---

### 2. Secondary Objective Area

Implement a smooth animated transition between the inactive and active card states, driven by the movement of rounded arc elements and the reveal of active card content.

---

### 3. Supporting Tasks

#### 3.1 Card State Definition
- Define the **active card** visual structure: title, card count, icon, play button, and a rounded arc at the bottom
- Define the **inactive card** visual structure: play button and two rounded arcs (matching the current state)

#### 3.2 Animation Implementation
- Animate the two rounded arcs of the inactive card to move smoothly upward or downward during the transition
- Animate the bottom rounded arc (with icon) of the active card to move up smoothly into view during activation

---

### 4. Detailed Breakdown

#### 4.1 Active Card Components
The active card must display the following elements: a **title**, a **card count**, an **icon**, a **play button**, and a **rounded arc at the bottom** containing the icon.

#### 4.2 Inactive Card Components
The inactive card must display a **play button** and **two rounded arcs**, consistent with the current existing card state on the Play Page.

#### 4.3 Transition Animation Behavior
When a card transitions between inactive and active states, the following animation must occur smoothly:

##### Nested Details
- The **two rounded arcs** of the inactive card must animate — moving up or down — as part of the transition
- The **bottom rounded arc with icon** from the active card must slide upward smoothly into its final position
- The animation must feel smooth and visually continuous, not abrupt
- No additional animation behavior beyond arc and content movement is stated — do not assume extra effects
- Edge cases such as mid-transition interruption or rapid switching are not mentioned and should not be assumed

---