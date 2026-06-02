# Objective
## List of Created Decks Page

---

## Description
This objective outlines the creation of a dedicated page within the application that displays a list of decks previously created by the user. The page is accessible from the profile section and provides minimal functionality for viewing, managing, and organizing user-created decks. The implementation must strictly adhere to the provided Figma design reference to ensure consistency with the application's visual standards.

---

## Objectives Breakdown

### 1. Main Objective Area
Enable users to access and view a comprehensive list of all decks they have created through a dedicated page accessible from the profile navigation.

---

### 2. Secondary Objective Area
Provide users with basic deck management capabilities, including the ability to delete user-created decks and access additional actions through a context menu, while protecting built-in decks from modification.

---

### 3. Supporting Tasks

#### 3.1 Navigation and Access
- Implement a "Decks and Cards" button on the profile page that redirects to the List of Decks Page
- Ensure seamless navigation from the profile section to the new page

#### 3.2 Deck Display
- Display a list of all decks created by the user on the List of Decks Page
- Present the deck list in accordance with the Figma design layout

#### 3.3 Context Menu Implementation
- Create a context menu triggered by a 3-dot vertical menu icon
- Include two options in the context menu: Delete and Export

#### 3.4 Delete Functionality
- Enable users to delete user-created decks and all associated questions
- Display a confirmation dialog before deletion is executed
- Prevent deletion of built-in decks provided by the application

---

### 4. Detailed Breakdown

#### 4.1 Page Accessibility
The List of Decks Page is accessed exclusively through the "Decks and Cards" button located on the profile page, providing a clear entry point for users to manage their decks.

#### 4.2 Deck Listing Functionality
The page displays a list of decks created by the user with minimal additional features, focusing on clarity and simplicity in presentation.

#### 4.3 Context Menu Options
Two actions are available through the context menu:

##### Delete Option
- Removes the selected deck and all questions contained within it
- Applies only to user-created decks
- Requires confirmation from the user before execution
- Built-in decks cannot be deleted through this interface

##### Export Option
- Noted in the design reference but not part of the actual system implementation
- No functional requirement for this feature

#### 4.4 Design Compliance
The page layout and visual design must strictly follow the Figma design reference provided at: `assets\reference\decks-lists.png`

---