# Objective
## Replace AI Prototype with Real AI Integration Using Groq API

---

## Description

This objective focuses on replacing the existing AI prototype within the application with a fully functional AI integration using the Groq API. The AI functionality is specifically scoped to generating questions based on a user-selected deck. The implementation must handle generation limits, connectivity fallbacks, and user-friendly error handling — all presented through dialogs in non-technical language.

---

## Objectives Breakdown

### 1. Main Objective Area

Replace the non-functional AI prototype with a real AI implementation powered by the Groq API, using the model `llama-3.3-70b-versatile`, to enable actual question generation for user-created decks.

---

### 2. Secondary Objective Area

Support the user's deck-and-question creation workflow by enabling AI-assisted question generation as an optional path alongside manual question creation. The AI must handle both initial generation and re-generation requests, while enforcing usage limits and providing clear, user-friendly feedback at every failure point.

---

### 3. Supporting Tasks

#### 3.1 Groq API Integration
- Integrate the Groq API using the provided API key `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`
- Set the model to `llama-3.3-70b-versatile` for all AI generation requests
- Scope all AI calls to question generation for the currently selected deck

#### 3.2 Question Generation Flow
- Trigger AI question generation when the user selects "Generate with AI" within a deck
- Allow the user to re-generate a question if they are not satisfied with the result
- Auto-fill the question input field when the user accepts a generated question

#### 3.3 Generation Limit Enforcement
- Restrict each user to a maximum of 15 generation/re-generation attempts
- Prevent further generation once the limit is reached
- Reset the generation count automatically after 1 hour from when the limit was hit

#### 3.4 Fallback and Error Handling
- Detect when the user has no internet connection before attempting generation
- Display all errors and fallback states as user-friendly dialogs — no raw error messages or technical/programmer-facing text

---

### 4. Detailed Breakdown

#### 4.1 Groq API Configuration
The Groq API must be used as the sole AI provider for this feature. The API key and model are already specified and must be used as-is:
- **API Key:** `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`
- **Model:** `llama-3.3-70b-versatile`

#### 4.2 Question Generation Context
The AI generates questions in the context of a specific selected deck. The flow is:
1. User creates a custom deck.
2. User adds questions — either manually or via AI generation.
3. When "Generate with AI" is chosen, the AI produces a question relevant to that deck.
4. The user may accept or re-generate the question.
5. On acceptance, the generated question populates the question input field.

#### 4.3 Generation Limit and Reset Logic
The user is subject to a hard limit on AI usage:

##### Nested Details
- Maximum allowed generations (including re-generations): **15**
- Once the limit is reached, the "Generate with AI" option becomes unavailable
- The limit resets **1 hour** after it was hit
- The countdown/reset is tied to when the limit was reached, not a fixed daily reset
- No additional generations are allowed during the cooldown period

#### 4.4 Fallback and Error Dialog Requirements
All error states must be shown as dialogs with user-friendly, non-technical language:

##### Nested Details
- **No internet connection:** Show a dialog informing the user that an internet connection is required to generate questions
- **Generation limit reached:** Show a dialog informing the user they have used all available generations and can try again after 1 hour
- **Any other API/generation error:** Must also be presented as a friendly dialog — no raw API errors, stack traces, or developer-facing messages should be shown to the user
