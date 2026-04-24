# Implementation Plans

These plans map directly from the five concepts in `spec_and_origin.md` and frame them as iOS/Android experiences that can live inside the current Expo shell.

## 1. Whipping Boy

**Mobile experience**

A paired accountability feature where one person commits to a habit and nominates a friend who receives the consequence flow if the habit is missed.

**Core user flow**

1. User creates a pact with a habit, check-in rule, and consequence type.
2. Friend accepts the pact and grants explicit consent to receive the consequence.
3. Daily check-in closes at a fixed cutoff.
4. If the user misses the check-in, the friend receives the selected consequence event and the user sees the social cost immediately.

**iOS/Android shape**

- Native push notifications for reminders, missed check-ins, and pact escalations.
- Device health integrations later for automatic proof such as steps or workouts.
- Shared pact timeline with streaks, misses, and friend reactions.

**First implementation slice**

- Manual check-in only.
- One pact with one partner.
- Soft consequences only: alerts, streak loss, public nudge inside the app.

## 2. Royal Food Taster

**Mobile experience**

A message shielding flow where stressful content is routed to a trusted proxy first, then returned as a safer summary.

**Core user flow**

1. User activates shield mode for a contact or topic.
2. Incoming content is forwarded to a designated taster.
3. The taster reads the original message and sends back a summary, risk level, and suggested response posture.
4. User chooses to read the original, archive it, or reply from the summary view.

**iOS/Android shape**

- Notification-first experience with clear "screen for me" states.
- Summary cards optimized for lock-screen follow-up and quick actions.
- Shared task state so the taster knows what is pending and what was already triaged.

**First implementation slice**

- In-app inbox mock rather than live SMS/email interception.
- Manual forwarding into the feature.
- Structured summary fields: gist, emotional intensity, action needed.

## 3. Sin Eater

**Mobile experience**

A private release ritual where a user sends a confession or emotional dump to a trusted friend, and the message is destroyed after being read.

**Core user flow**

1. User writes or records a burden message.
2. User selects a trusted "sin eater" contact and sends it with an expiry rule.
3. Recipient opens the message once.
4. The app destroys the content on both sides and replaces it with a lightweight purification record.

**iOS/Android shape**

- Strong emphasis on ephemeral UI, read-once states, and deletion confirmation.
- Visual ritual feedback after the burden is accepted.
- Optional voice note support for low-friction emotional release.

**First implementation slice**

- Text only.
- One-to-one delivery.
- Simulated deletion state in-app before any real secure transport work.

## 4. Nomenclator

**Mobile experience**

A live memory support tool where a companion sends quick prompts to help the user remember names, context, and prior interactions during social encounters.

**Core user flow**

1. User creates an event or activates a live encounter mode.
2. Companion opens a backchannel console and picks a person profile.
3. Companion sends short prompts to the user in real time.
4. User sees discreet, glanceable prompts on phone or wearable.

**iOS/Android shape**

- Fast prompt composer for the companion.
- Watch-ready prompt format for short bursts of context.
- Shared people cards with names, affiliation, last meeting, and memorable details.

**First implementation slice**

- Phone-only prompt feed.
- Manual people cards.
- No camera or AR recognition.

## 5. Moirologist

**Mobile experience**

An emergency affirmation trigger that summons a preselected support squad to flood the user with praise, comfort, and partisan encouragement.

**Core user flow**

1. User configures a support squad and preferred comfort modes.
2. User hits a one-tap distress button from the app or widget.
3. Squad members receive an urgent prompt with clear response instructions.
4. User receives a stream of supportive messages, voice notes, and reactions in a dedicated recovery screen.

**iOS/Android shape**

- Home screen widget and shortcut entry point.
- High-priority notifications for squad members.
- Playback queue for comforting voice notes and short text bursts.

**First implementation slice**

- In-app distress button only.
- Text replies only.
- No automated writing; human supporters provide the response.

## Cross-Cutting Delivery Order

1. Stabilize the shared shell and feature contract so all five concepts can render without import failures.
2. Build one vertical slice with real interaction state, likely `nomenclator` because its phone-first workflow is the least dependent on external integrations.
3. Add shared mobile primitives: notifications, contacts, presence, event logs, and trust/consent settings.
4. Add platform-specific surfaces such as widgets, watch delivery, and health or communications integrations only after the in-app flows are proven.
