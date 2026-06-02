# Objective
## Push Notification

---

## Description
This objective covers the implementation of a push notification feature within the app. Notifications are controlled by the user via a toggle switch on the Profile page. When enabled, the user receives randomized push notifications with pre-defined titles and messages. The timing of these notifications is also randomized, ensuring they are not sent too frequently in succession.

---

## Objectives Breakdown

### 1. Main Objective Area
Enable a user-controlled push notification system that delivers randomized, personalized notifications to users who have opted in through the Profile page.

---

### 2. Secondary Objective Area
Ensure notifications respect the user's preference — delivering messages only when the toggle is active, and suppressing them entirely when it is turned off. Notification content and scheduling should both follow a randomized pattern without clustering notifications too closely together.

---

### 3. Supporting Tasks

#### 3.1 Notification Toggle Setup
- Add a switch toggle on the Profile page to control notification preferences
- When the toggle is **ON**, the user receives push notifications
- When the toggle is **OFF**, no push notifications are sent to the user

#### 3.2 Notification Content
- Use randomized push notification messages personalized with the user's name (`[Name]`)
- Pull from the defined set of 5 notification templates

#### 3.3 Notification Scheduling
- Schedule notifications at randomized intervals
- Ensure notifications are not sent too close to one another in time

---

### 4. Detailed Breakdown

#### 4.1 Profile Page Toggle
The Profile page includes a switch toggle dedicated to notifications. This toggle serves as the user's opt-in/opt-out control for receiving push notifications.

#### 4.2 Notification Content Templates
Five pre-defined push notification templates are used, each containing a title and a personalized message body referencing the user by name:

| # | Title | Message |
|---|-------|---------|
| 1 | **Tea Check** | [Name], not you ghosting the tea. Open Spillr and pull a card. |
| 2 | **Group Chat Energy** | [Name], one random question could expose the whole group chat. |
| 3 | **Chaos Incoming** | Your next card is waiting, [Name], and it's giving chaos. |
| 4 | **One Card Only** | Social battery low, [Name]? Same. Still, one card won't hurt. |
| 5 | **Don't Make It Awkward** | [Name], the deck has something to ask. Don't leave it hanging. |

#### 4.3 Notification Schedule
Notifications are dispatched on a randomized schedule.

##### Scheduling Details
- The interval between notifications must be randomized
- Notifications should not be sent in rapid succession — spacing must avoid being too close time to time
- No fixed schedule or specific time window is defined beyond the randomized constraint

---