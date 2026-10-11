import Foundation
import Observation
import CryptoKit
import AuthenticationServices
#if canImport(FirebaseAuth)
import FirebaseAuth
import FirebaseCore
#endif
#if canImport(GoogleSignIn) && canImport(UIKit)
import GoogleSignIn
#endif
#if canImport(UIKit)
import UIKit
#endif

struct AuthUser: Equatable {
    let uid: String
    var email: String
    var displayName: String
    var createdAt: Date?
}

enum AuthError: LocalizedError {
    case message(String)
    var errorDescription: String? { if case let .message(m) = self { m } else { nil } }
}

/// Port of `AuthRepository` / `AuthController` (Firebase Auth + Google + Apple).
/// Without the Firebase package (or on a bypass build) it behaves as a signed-in local guest.
@Observable @MainActor
final class AuthService {
    private(set) var user: AuthUser?
    private(set) var isReady = false
    var isWorking = false
    var errorMessage: String?

    /// Equivalent of `desktopAuthBypass`: skip auth and use a fixed local id.
    static let guestUser = AuthUser(uid: "default", email: "", displayName: "Learner", createdAt: nil)
    private var currentNonce: String?

    #if canImport(FirebaseAuth)
    private var handle: AuthStateDidChangeListenerHandle?
    #endif

    init() {
        #if canImport(FirebaseAuth)
        if FirebaseApp.app() == nil, Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        if FirebaseApp.app() != nil {
            apply(Auth.auth().currentUser)
            isReady = true
            handle = Auth.auth().addStateDidChangeListener { [weak self] _, u in
                Task { @MainActor in self?.apply(u) }
            }
            return
        }
        #endif
        user = Self.guestUser
        isReady = true
    }

    #if canImport(FirebaseAuth)
    private func apply(_ u: FirebaseAuth.User?) {
        user = u.map { AuthUser(uid: $0.uid, email: $0.email ?? "", displayName: $0.displayName ?? "", createdAt: $0.metadata.creationDate) }
    }
    #endif

    var isGuest: Bool { user?.uid == Self.guestUser.uid }

    // MARK: Email

    func signIn(email: String, password: String) async -> Bool {
        await run {
            #if canImport(FirebaseAuth)
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            #endif
        }
    }

    func signUp(email: String, password: String, name: String) async -> Bool {
        await run {
            #if canImport(FirebaseAuth)
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let change = result.user.createProfileChangeRequest()
            change.displayName = name
            try await change.commitChanges()
            self.apply(Auth.auth().currentUser)
            #endif
        }
    }

    func signOut() {
        #if canImport(FirebaseAuth)
        try? Auth.auth().signOut()
        #endif
    }

    // MARK: Google

    func signInWithGoogle() async -> Bool {
        await run {
            #if canImport(FirebaseAuth) && canImport(GoogleSignIn) && canImport(UIKit)
            guard let clientID = FirebaseApp.app()?.options.clientID else { throw AuthError.message("Missing Google client id.") }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            guard let root = Self.rootViewController() else { throw AuthError.message("No window to present Google Sign-In.") }
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: root)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.message("Google Sign-In failed: missing idToken. Register this app's bundle id / SHA in the Firebase Console.")
            }
            let cred = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            _ = try await Auth.auth().signIn(with: cred)
            #else
            throw AuthError.message("Google Sign-In is unavailable in this build.")
            #endif
        }
    }

    // MARK: Apple (nonce flow identical to the Flutter implementation)

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let raw = Self.randomNonce()
        currentNonce = raw
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(raw)
    }

    func completeApple(_ result: Result<ASAuthorization, Error>) async -> Bool {
        await run {
            let auth = try result.get()
            #if canImport(FirebaseAuth)
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = self.currentNonce, let tokenData = cred.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) else { throw AuthError.message("Apple Sign-In failed.") }
            let oauth = OAuthProvider.appleCredential(withIDToken: token, rawNonce: nonce, fullName: cred.fullName)
            let res = try await Auth.auth().signIn(with: oauth)
            let name = [cred.fullName?.givenName, cred.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
            if !name.isEmpty, (res.user.displayName ?? "").isEmpty {
                let change = res.user.createProfileChangeRequest(); change.displayName = name
                try await change.commitChanges(); self.apply(Auth.auth().currentUser)
            }
            #else
            _ = auth
            #endif
        }
    }

    // MARK: helpers

    private func run(_ work: @escaping () async throws -> Void) async -> Bool {
        isWorking = true; errorMessage = nil
        defer { isWorking = false }
        do { try await work(); return true }
        catch {
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return false }
            errorMessage = error.localizedDescription; return false
        }
    }

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String((0..<length).map { _ in charset.randomElement()! })
    }
    private static func sha256(_ s: String) -> String {
        SHA256.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    #if canImport(UIKit)
    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
            .first(where: \.isKeyWindow)?.rootViewController
    }
    #endif
}
