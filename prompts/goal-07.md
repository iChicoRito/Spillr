# Objective
## AI Generative Question Creation Based on Deck Category

---

## Description

This objective focuses on integrating an AI-powered question generation feature into the existing application. The AI must operate fully offline, remain lightweight in terms of storage impact, and generate questions contextually based on the selected deck category. The feature is initiated through a dedicated UI button and guides the user through a generation flow that includes a loading state, a review dialog, and an option to accept or regenerate the output before it populates the question field.

---

## Objectives Breakdown

### 1. Main Objective Area

Integrate an offline AI model capable of generating questions based on the deck category selected by the user, without requiring an internet connection and without significantly increasing the application's storage footprint.

---

### 2. Secondary Objective Area

Implement the AI generation feature within the existing UI by adding a "Generate with AI" button and a post-generation review flow, allowing the user to either accept the generated question or request a new one before it is applied to the question field.

---

### 3. Supporting Tasks

#### 3.1 AI Integration

- Integrate Gemini Nano / AICore as the offline AI solution
- Ensure the model operates fully offline without network dependency
- Ensure the model does not significantly increase the application size

#### 3.2 UI Implementation

- Add a "Generate with AI" button below the existing "Create" button, as specified in the Figma design
- Change the button label to "Generating Question..." while the AI is processing
- Display a dialog/modal after generation is complete showing the generated question

#### 3.3 Post-Generation Actions

- Provide a "Generate Again" action in the dialog to allow the user to request a new question
- Provide an "Accept" action in the dialog to confirm the generated question
- Upon acceptance, automatically populate the Question Field with the AI-generated question

---

### 4. Detailed Breakdown

#### 4.1 Offline AI Model Selection

The selected AI solution is Gemini Nano / AICore. This model was chosen specifically because it supports fully offline operation and has a minimal impact on application size, meeting both constraints stated in the objective.

#### 4.2 UI Button Placement and State

A "Generate with AI" button is placed below the existing "Create" button, following the layout defined in the provided Figma design. During AI generation, the button text dynamically changes to "Generating Question..." to indicate the active processing state to the user.

#### 4.3 Generation Review Dialog

Once the AI finishes generating the question, a dialog or modal is presented to the user containing the generated question and two available actions.

##### Nested Details

- The dialog displays the AI-generated question for user review before any field is modified
- "Generate Again" triggers a new generation cycle using the same deck category context
- "Accept" closes the dialog and fills the Question Field with the generated question
- The Question Field is only populated upon explicit user acceptance — not automatically on generation