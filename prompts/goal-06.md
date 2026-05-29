Here is the structured Markdown output based strictly on your provided input:

---

# Objective
## Question Creation for Decks

---

## Description

This objective covers the implementation of question management functionality within the Deck system of the application. It defines how users interact with decks and their associated questions — including navigation, editing, deleting, and viewing questions — while ensuring UI consistency with the existing Figma design. It also establishes reusable component patterns for dialogs and sheets, and specifies that created decks with their questions should appear on the Play Page.

---

## Objectives Breakdown

### 1. Main Objective Area

Implement question management for decks, allowing users to view, edit, and delete questions tied to specific decks, following the UI layout defined in Figma.

---

### 2. Secondary Objective Area

Ensure UI consistency by reusing existing sheet/drawer components and introducing a reusable dialog component for delete confirmations. Reflect created decks and their questions on the Play Page.

---

### 3. Supporting Tasks

#### 3.1 Deck Page Interactions
- Tapping a deck or its chevron arrow navigates to the Questions Page for that specific deck
- Long-pressing a deck displays a context menu with **Edit Deck** and **Delete** options

#### 3.2 Questions Page Interactions
- Tapping the 3-vertical-dots icon on a question displays a context menu with **Edit**, **View**, and **Delete** options
- Each action (Edit, View, Delete) opens as a drawer/sheet, using the same existing sheet component already present in the codebase

#### 3.3 Delete Confirmation Dialog
- Deleting a question triggers a confirmation dialog
- The dialog must follow the same existing design
- Create a reusable dialog component to be used consistently across the app

#### 3.4 Play Page Integration
- Once a deck is created, it appears on the Play Page as a card along with its associated questions

---

### 4. Detailed Breakdown

#### 4.1 Deck Navigation (Deck Page)
Clicking a deck item or its chevron arrow opens a new Questions Page scoped to that specific deck. The Questions Page lists all questions belonging to the selected deck.

#### 4.2 Deck Context Menu (Long Press)
When a user long-presses a deck, a context menu appears with two options: **Edit Deck** and **Delete**. This interaction is specific to the Deck Page.

#### 4.3 Question Context Menu (3-Dot Icon)
On the Questions Page, tapping the 3-vertical-dots icon on a question reveals a context menu with **Edit**, **View**, and **Delete** actions. Each action renders as a drawer/sheet. The existing sheet component must be reused to maintain design consistency.

#### 4.4 Built-in Questions Behavior
The app includes built-in questions for each deck. Users are permitted to edit or delete these pre-existing questions.

#### 4.5 Reusable Dialog Component
A shared dialog component must be created for delete confirmations. It must match the existing dialog design and be reusable across different parts of the app for efficiency and consistency.

#### 4.6 Play Page Deck Display
After a deck is successfully created, it is displayed on the Play Page as a card. The card includes the deck along with its associated questions.

##### Nested Details
- The sheet component used for Edit, View, and Delete actions must be the same component already built — do not create a new one
- The dialog component for deletion confirmation must follow the same design already established in the app
- No new design patterns should be introduced outside of what is defined in Figma

---