# Sample Agent Loop

A native iOS app written in Swift that an agent builds and tests from any
environment, including Linux, using the `lim` CLI with a remote Xcode sandbox and
a cloud iOS simulator.

- Bundle ID: `com.limrun.sample-agent-loop`
- Scheme: `sample-agent-loop`

Install the CLI and the Limrun skills, then follow the skill for the build, attach,
and drive workflow:

```bash
npm install --global lim
lim skills install
```

Always use `lim` in place of `xcodebuild` and the local iOS Simulator.
