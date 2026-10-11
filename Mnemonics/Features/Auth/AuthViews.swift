import SwiftUI
import AuthenticationServices

/// Welcome → Login / Signup (navigation inside the unauthenticated flow).
struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            WelcomeView()
                .navigationDestination(for: AuthRoute.self) { r in
                    switch r { case .login: LoginView(); case .signup: SignupView() }
                }
        }
    }
}
enum AuthRoute: Hashable { case login, signup }

struct WelcomeView: View {
    var body: some View {
        ZStack {
            MBackground().ignoresSafeArea()
            VStack(spacing: MSpace.l) {
                Spacer()
                Image("LogoMark").resizable().scaledToFill().frame(width: 110, height: 110).clipShape(RoundedRectangle(cornerRadius: 26))
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                VStack(spacing: 4) {
                    Text("Let's Break").font(MFont.headingLarge).foregroundStyle(MColor.textPrimary)
                    Text("THE BARRIERS OF LANGUAGE").font(MFont.headingLarge).foregroundStyle(MColor.primaryGreen).multilineTextAlignment(.center)
                }
                Text("Join our community and master vocabulary with ease.").foregroundStyle(MColor.textSecondary).multilineTextAlignment(.center)
                Spacer()
                NavigationLink(value: AuthRoute.signup) { Text("Get Started") }.buttonStyle(PrimaryButtonStyle())
                NavigationLink(value: AuthRoute.login) {
                    Text("Log In").font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(MColor.primaryGreen)
                        .frame(maxWidth: .infinity).padding(.vertical, MSpace.m)
                        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(MColor.primaryGreen, lineWidth: 2))
                }
                Spacer().frame(height: MSpace.l)
            }.padding(.horizontal, MSpace.l)
        }
        .navigationBarHidden(true)
    }
}

private struct SocialButtons: View {
    @Environment(AppModel.self) private var model
    let google: String, apple: String
    var body: some View {
        VStack(spacing: MSpace.s) {
            Button { Task { _ = await model.auth.signInWithGoogle() } } label: {
                Label(google, systemImage: "globe").font(MFont.body.weight(.semibold)).foregroundStyle(MColor.textPrimary)
                    .frame(maxWidth: .infinity).padding(.vertical, 14).background(MColor.card, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                    .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(MColor.border))
            }
            SignInWithAppleButton(.continue) { model.auth.prepareAppleRequest($0) } onCompletion: { r in Task { _ = await model.auth.completeApple(r) } }
                .frame(height: 50).clipShape(RoundedRectangle(cornerRadius: MSpace.radiusXL))
                .accessibilityLabel(apple)
        }
    }
}

struct LoginView: View {
    @Environment(AppModel.self) private var model
    @State private var email = ""
    @State private var password = ""
    @State private var showReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back").font(MFont.headingLarge)
                    Text("Log in to continue your learning journey").foregroundStyle(MColor.textSecondary)
                }
                TextField("Email", text: $email).textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                SecureField("Password", text: $password).textContentType(.password)
                    .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                HStack { Spacer(); Button("Forgot Password?") { showReset = true }.font(MFont.small.weight(.semibold)).foregroundStyle(MColor.primaryGreen) }
                if let e = model.auth.errorMessage { Text("Login failed: \(e)").font(MFont.small).foregroundStyle(.red) }
                Button { submit() } label: { if model.auth.isWorking { ProgressView().tint(.white) } else { Text("Log In") } }
                    .buttonStyle(PrimaryButtonStyle()).disabled(model.auth.isWorking)
                HStack { Rectangle().fill(MColor.border).frame(height: 1); Text("or continue with").font(MFont.small).foregroundStyle(MColor.textSecondary); Rectangle().fill(MColor.border).frame(height: 1) }
                SocialButtons(google: "Continue with Google", apple: "Continue with Apple")
                HStack { Text("Don't have an account?").foregroundStyle(MColor.textSecondary)
                    NavigationLink("Sign Up", value: AuthRoute.signup).fontWeight(.bold).foregroundStyle(MColor.primaryGreen) }.frame(maxWidth: .infinity)
            }.padding(MSpace.l)
        }
        .mScreenBackground()
        .navigationTitle("").navigationBarTitleDisplayModeIfAvailable()
        .alert("Forgot Password?", isPresented: $showReset) { Button("OK", role: .cancel) {} } message: { Text("Password reset isn't available yet.") }
    }

    private func submit() {
        guard !email.isEmpty, !password.isEmpty else { model.showToast("Please enter email and password", isError: true); return }
        Task { _ = await model.auth.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password) }
    }
}

struct SignupView: View {
    @Environment(AppModel.self) private var model
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Account").font(MFont.headingLarge)
                    Text("Sign up to start mastering vocabulary").foregroundStyle(MColor.textSecondary)
                }
                TextField("Full Name", text: $name).textContentType(.name).padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                TextField("Email", text: $email).textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                SecureField("Password", text: $password).textContentType(.newPassword).padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                if let e = model.auth.errorMessage { Text("Signup failed: \(e)").font(MFont.small).foregroundStyle(.red) }
                Button { submit() } label: { if model.auth.isWorking { ProgressView().tint(.white) } else { Text("Sign Up") } }
                    .buttonStyle(PrimaryButtonStyle()).disabled(model.auth.isWorking)
                HStack { Rectangle().fill(MColor.border).frame(height: 1); Text("or register with").font(MFont.small).foregroundStyle(MColor.textSecondary); Rectangle().fill(MColor.border).frame(height: 1) }
                SocialButtons(google: "Sign Up with Google", apple: "Sign Up with Apple")
                HStack { Text("Already have an account?").foregroundStyle(MColor.textSecondary)
                    NavigationLink("Log In", value: AuthRoute.login).fontWeight(.bold).foregroundStyle(MColor.primaryGreen) }.frame(maxWidth: .infinity)
            }.padding(MSpace.l)
        }
        .mScreenBackground()
        .navigationTitle("").navigationBarTitleDisplayModeIfAvailable()
    }

    private func submit() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else { model.showToast("Please fill in all fields", isError: true); return }
        Task { _ = await model.auth.signUp(email: email.trimmingCharacters(in: .whitespaces), password: password, name: name) }
    }
}
