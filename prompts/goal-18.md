# Objective
## Minor Design Revisions and Changes for UI/UX

---

## Description
This objective encompasses design refinements across multiple pages of the application to improve visual hierarchy and user experience. The primary focus is to remove redundant navigation elements that are now provided natively by devices, enhance the avatar customization interface with dynamic visual feedback, refine icon sizing and positioning for a cleaner appearance, and implement access control for question management in built-in decks.

---

## Objectives Breakdown

### 1. Main Objective Area
Streamline navigation UI across multiple pages by removing redundant back buttons and improving visual hierarchy, recognizing that all modern devices now provide native back navigation functionality.

---

### 2. Secondary Objective Area
Enhance visual design and user feedback through dynamic avatar color selection, refined icon sizing, and improved spacing throughout the interface.

---

### 3. Supporting Tasks

#### 3.1 Navigation Refinement
- Remove the back (<) button from the Questions Page header
- Remove the chevron arrow icon from the Play History page
- Remove the back (<) button from the List of Created Decks header (Profile Page)
- Utilize the freed-up space to allow header titles to expand for improved visual layout

#### 3.2 Avatar Customization Enhancement
- Implement dynamic background color for avatar selection boxes that changes based on the user's selected color
- Adjust the vertical position of the avatar within the circular container to prevent the avatar head from touching the circle edge

#### 3.3 Deck Page Icon Refinement
- Reduce the size of deck icons and their circular containers
- Decrease padding on all sides of the icon containers for a cleaner appearance
- Replace the ">" icon with 3 vertical dots while preserving the context menu functionality

#### 3.4 Built-in Deck Access Control
- Hide the Add Question button on the Questions Page for all built-in decks

---

### 4. Detailed Breakdown

#### 4.1 Navigation Updates
Remove back buttons from three specific page locations as native device back buttons now provide this functionality. Header titles should utilize the vacated space for improved visual balance.

**Affected Pages:**
- Questions Page (remove < back button)
- Play History page (remove chevron arrow icon)
- List of Created Decks on Profile Page (remove < back button)

#### 4.2 Avatar Customization Enhancements
Two distinct improvements to enhance the avatar selection user experience:

**Dynamic Color Background:** Avatar selection boxes should dynamically change their background color to match the color selected by the user.

**Avatar Vertical Positioning:** Adjust the avatar's height position within its circular container to ensure adequate spacing, preventing the avatar head from contacting the circle boundary.

##### Reference Materials
- Avatar positioning correction reference: [assets\reference\avatar-fix.png]

#### 4.3 Deck Page Icon Refinements
Multiple adjustments to improve the visual appearance and consistency of deck page icons:

**Size Reduction:** Reduce both the icon size and the size of the circular container that surrounds it.

**Padding Decrease:** Decrease padding on all sides of the icon for a cleaner, more compact visual appearance.

**Icon Replacement:** Change the ">" chevron icon to 3 vertical dots while maintaining the existing context menu functionality.

##### Reference Materials
- Design reference: [assets\reference\deck-page.png]

#### 4.4 Built-in Deck Question Management
For all built-in decks on the Questions Page, the Add Question button must be hidden from the user interface, as built-in decks do not support user-added questions.