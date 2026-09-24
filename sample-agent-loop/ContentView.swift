//
//  ContentView.swift
//  sample-agent-loop
//

import SwiftUI

/// Sign-in screen. The reset flow behind "Forgot password?" is the part the
/// walkthrough drives; sign-in itself is not wired to anything.
struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showSignInNote = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 76, height: 76)
                        .background(.tint, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .accessibilityHidden(true)
                    Text("Agent Loop")
                        .font(.largeTitle.bold())
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .accessibilityIdentifier("signInEmailField")
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding(14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .accessibilityIdentifier("signInPasswordField")
                }

                VStack(spacing: 16) {
                    Button {
                        showSignInNote = true
                    } label: {
                        Text("Sign in")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityIdentifier("signInButton")

                    NavigationLink("Forgot password?") {
                        ForgotPasswordView()
                    }
                    .font(.subheadline.weight(.medium))
                    .accessibilityIdentifier("forgotPasswordLink")
                }

                if showSignInNote {
                    Text("Sign-in is not wired up in this sample. Try \"Forgot password?\" instead.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("signInNote")
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }
}

/// Password reset form. Demonstrates a UI that reports success even when the
/// request fails: the log line, not the screen, is where the failure shows.
struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var submitted = false
    @State private var sending = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reset your password")
                    .font(.title2.bold())
                Text("Enter the email on your account and we will send a link to choose a new password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityIdentifier("emailField")

            Button {
                Task { await sendResetLink() }
            } label: {
                Group {
                    if sending {
                        ProgressView()
                    } else {
                        Text("Send reset link")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || sending)
            .accessibilityIdentifier("sendResetButton")

            if submitted {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)
                    Text("Check your inbox for a reset link.")
                        .font(.subheadline)
                        .accessibilityIdentifier("resetConfirmation")
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .navigationTitle("Forgot password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendResetLink() async {
        sending = true
        defer { sending = false }
        // Stand-in for the app's own backend. Always answers 422, the way a
        // real reset endpoint does for an unknown address.
        let url = URL(string: "https://httpbin.org/status/422")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["email": email])
        do {
            let (body, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            if status >= 400 {
                print("[password-reset] POST /password/reset failed: HTTP \(status) for \(email) body=\(body.count) bytes")
            } else {
                print("[password-reset] POST /password/reset ok: HTTP \(status)")
            }
        } catch {
            print("[password-reset] POST /password/reset error: \(error)")
        }
        // Bug on purpose: the view never reads the failure case.
        submitted = true
    }
}

#Preview {
    ContentView()
}
