//
//  ContentView.swift
//  sample-agent-loop
//

//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image("SampleImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .accessibilityLabel("Mountains and sun")
                Text("Hello, world!")
                NavigationLink("Forgot password?") {
                    ForgotPasswordView()
                }
                .accessibilityIdentifier("forgotPasswordLink")
            }
            .padding()
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
        Form {
            Section("Reset your password") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("emailField")
                Button("Send reset link") {
                    Task { await sendResetLink() }
                }
                .disabled(email.isEmpty || sending)
                .accessibilityIdentifier("sendResetButton")
            }
            if submitted {
                Section {
                    Text("Check your inbox for a reset link.")
                        .accessibilityIdentifier("resetConfirmation")
                }
            }
        }
        .navigationTitle("Forgot password")
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
