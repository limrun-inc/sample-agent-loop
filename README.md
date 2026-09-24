# Sample Agent Loop

A small iOS app for walking through the loop an AI coding agent runs on Limrun:
build on a remote Mac, install on a cloud simulator, drive the UI, read the app log.

The app has a "Forgot password?" screen with a bug on purpose. The reset request
always fails with HTTP 422, the app prints the failure to its log, and the screen
still says "Check your inbox for a reset link." The screen looks right; only the log
tells the truth. That is the failure an agent should catch.

## Setup

```bash
npm install --global lim
export LIM_API_KEY=lim_...   # console.limrun.com/settings, API Keys
```

## The loop

```bash
git clone https://github.com/limrun-inc/sample-agent-loop && cd sample-agent-loop

lim xcode build . --scheme sample-agent-loop
lim ios create --attach --reuse-if-exists --label demo=agent-loop

lim ios element-tree --json
lim ios tap-element --ax-unique-id forgotPasswordLink
lim ios tap-element --ax-unique-id emailField
lim ios type "test@example.com"
lim ios tap-element --ax-unique-id sendResetButton
lim ios screenshot ./after-submit.png

lim ios app-log com.limrun.sample-agent-loop --tail 50
```

The tree after submit shows `Check your inbox for a reset link.`; the log shows
`[password-reset] POST /password/reset failed: HTTP 422 ...`.

Every later `lim xcode build .` reinstalls on the attached simulator. When done:

```bash
lim ios delete
lim xcode delete
```

## Accessibility identifiers

| Element | Identifier |
| --- | --- |
| Link on the home screen | `forgotPasswordLink` |
| Email field | `emailField` |
| Submit button | `sendResetButton` |
| Success message | `resetConfirmation` |

## UI test

```bash
lim xcode test . --scheme sample-agent-loop
```

Launches the app and checks that the sign-in screen appears.
