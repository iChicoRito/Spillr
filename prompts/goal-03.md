# Objective
## The Flipping Card Game (Spillr)

---

## Description

Spillr is an icebreaker card game where users select a category deck and are presented with a series of flippable cards, each containing a question relevant to that category. The game flows across three main pages: the Play Page, the Game Page, and the Ending Page. The experience is designed to be interactive and visually dynamic, with backgrounds and badges adapting to the selected category. The game ends with a personalized result message based on how the user engaged with the cards.

---

## Objectives Breakdown

### 1. Main Objective Area

Build a multi-page interactive flipping card game with a fixed question set per category, dynamic visual theming, card flip interactions, and a conditional ending screen based on user behavior throughout the game session.

---

### 2. Secondary Objective Area

- Allow users to select a category from the Play Page and carry that selection into the Game Page.
- Allow mid-game category switching via a dropdown selector.
- Track user interactions (answered vs. passed) to determine the correct ending condition.
- Navigate users back to the Play Page from both the Game Page (via Back button) and the Ending Page (via Explore Cards button).

---

### 3. Supporting Tasks

#### 3.1 Play Page Tasks
- Display fixed category cards, each with a Title and Description.
- Each card has a "Play [Category]" button that redirects the user to the Game Page.

#### 3.2 Game Page Tasks
- Implement a Back button that cancels the current game and returns to the Play Page.
- Display the Spillr logo centered, aligned with the Back button.
- Implement a dropdown/select for changing the active category mid-game.
- Render the main flippable card with front and back states.
- Display a card count indicator below the card (e.g., "3 of 23").
- Apply a dynamic background based on the currently selected category.

#### 3.3 Card Interaction Tasks
- Front face: show the category badge, Question No., and a "Tap to Flip" indicator.
- Back face: show the question text for that card.
- Allow the user to either proceed to the next card or pass a question.

#### 3.4 Ending Page Tasks
- Evaluate end condition based on user interaction data.
- Display the appropriate ending message based on the condition met.
- Provide an "Explore Cards" button that returns the user to the Play Page.

---

### 4. Detailed Breakdown

#### 4.1 Category Decks and Questions

Each category contains exactly 20 fixed questions. The five categories and their questions are as follows:

**Deep Spill**
Questions centered on self-reflection and personal growth.
- What's something you wish people understood about you?
- What's one thing you're still learning to accept about yourself?
- When was the last time you felt genuinely proud of yourself?
- What's a fear you don't talk about often?
- What's one mistake that taught you a lot?
- What kind of person do you want to become?
- What's something you miss from your younger self?
- What's one thing you're trying to heal from?
- What makes you feel safe around someone?
- What's a lesson you learned the hard way?
- What's something you pretend doesn't bother you?
- What do you usually overthink about?
- What's one thing you're grateful for right now?
- What's something you want to be remembered for?
- When do you feel most like yourself?
- What's a boundary you're trying to protect?
- What's something you wish you had said earlier?
- What does peace look like for you?
- What's one thing you're afraid to fail at?
- What kind of love or friendship feels healthy to you?

**No Dead Air**
Questions centered on light, casual, everyday preferences.
- What's your go-to comfort food?
- What song have you been replaying lately?
- What's your most used emoji?
- What app do you open way too much?
- What's your favorite lazy-day activity?
- What's your usual drink order?
- What movie or series can you rewatch anytime?
- What's something small that instantly improves your mood?
- What's your go-to snack?
- What's your favorite time of the day?
- What's one random thing you're good at?
- What's your ideal weekend plan?
- What's a food you'll never get tired of?
- What's your current favorite meme or trend?
- What's your favorite way to relax?
- What's one thing you always forget?
- What's the last thing that made you laugh?
- What's your favorite weather?
- What's one item you always bring with you?
- What's your go-to excuse when you're late?

**Chaos Mode**
Questions centered on humor, absurdity, and chaotic self-awareness.
- What's your most unserious fear?
- What's your villain origin story?
- What's your most delulu belief?
- What's a hill you would die on, even if it's dumb?
- What's your most NPC habit?
- What's something you hate for no clear reason?
- What's your most chaotic online purchase?
- What's your toxic trait, but make it funny?
- What's your "I'm cooked" moment this week?
- What's the weirdest thing you searched that was harmless?
- What's something normal that feels illegal to do?
- What's your most random ick?
- What's a dramatic reaction you had to a minor problem?
- What food would you defend with your life?
- What's something you do that deserves a side-eye?
- What's your most useless talent?
- What's the dumbest thing that made you laugh recently?
- What's your most chaotic group chat moment?
- What's something you would cancel plans for immediately?
- What's one thing that gives you instant main character energy?

**Hot Seat**
Questions directed at identifying group members by behavior or trait.
- Who in this group is the most dramatic?
- Who is most likely to be late?
- Who gives the best advice here?
- Who is most likely to overthink a simple message?
- Who has the funniest reactions?
- Who is the most difficult to read?
- Who is most likely to disappear and come back like nothing happened?
- Who in this group has the most chaotic energy?
- Who is most likely to start laughing at the wrong time?
- Who would survive best in a random emergency?
- Who is the most honest in the group?
- Who gives off main character energy?
- Who is most likely to accidentally expose a secret?
- Who takes the longest to reply?
- Who is the most protective friend?
- Who is most likely to say "I'm fine" but is not fine?
- Who would be the worst at keeping a straight face?
- Who is most likely to make a bad decision for the plot?
- Who has changed the most over time?
- Who in this group knows the most tea?

**Date Mode**
Questions centered on relationships, preferences, and romantic compatibility.
- What's your ideal first date?
- What makes you feel comfortable with someone?
- What's a green flag you notice quickly?
- What's a red flag you never ignore?
- What's your love language?
- What kind of effort matters most to you?
- What's something small that makes you feel appreciated?
- What's your idea of quality time?
- What's a romantic gesture you actually like?
- What's something you value in a relationship?
- What's your favorite way to show affection?
- What makes you lose interest quickly?
- What's something you want a partner to understand about you?
- What's your dating non-negotiable?
- What's the best compliment someone can give you?
- What kind of communication do you prefer?
- What's something that instantly makes someone attractive to you?
- What's a simple date idea you would genuinely enjoy?
- What's something you're still learning about relationships?
- What does a healthy relationship look like to you?

---

#### 4.2 Game Page Element Specifications

| Element | Details |
|---|---|
| Back Button | Top-left; cancels current game, returns to Play Page |
| Spillr Logo | Top-center; aligned with Back button |
| Category Dropdown | Allows user to change active category mid-game |
| Card Front | Shows: category badge, Question No., "Tap to Flip" indicator |
| Card Back | Shows: the question text |
| Card Count Indicator | Positioned below the card; format: "X of Y" |
| Background | Dynamically changes based on selected category |

---

#### 4.3 Ending Page Conditions

Three distinct ending messages are displayed based on user behavior:

**Condition 1 — All questions answered (none passed)**
> *"You Spilled Everything, [Name] — You survived the questions. Honestly, iconic behavior."*

**Condition 2 — All cards completed, but some were passed**
> *"Almost Spilled Everything, [Name] — You finished the deck, but some tea stayed unspilled."*

**Condition 3 — All questions passed (none answered)**
> *"Certified Dodger, Chico — You passed every question. Suspicious, but we'll allow it."*

##### Nested Details
- The user's name is injected dynamically into Condition 1 and Condition 2 ending messages.
- Condition 3 uses the fixed name "Chico" as stated in the input.
- The "Explore Cards" button on the Ending Page returns the user to the Play Page.
- No additional ending states beyond these three are defined in the input.