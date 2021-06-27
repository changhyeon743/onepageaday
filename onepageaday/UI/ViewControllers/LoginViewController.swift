//
//  LoginViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/18.
//

import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import Kingfisher

class LoginViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var signInWithApple: UIButton!
    
    fileprivate var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: "https://media.giphy.com/media/GZd8nPH3TcNSU/giphy.gif"),options: [.memoryCacheExpiration(.expired)])
        
        signInWithApple.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        signInWithApple.clipsToBounds = true
        signInWithApple.layer.cornerRadius = 5.0
        signInWithApple.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    

    @IBAction func signInWithApple(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    @IBAction func privacyButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://onepageaday-3a198.web.app") {
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        print("LoginViewController deinit")
    }
}




//MARK: APPLE
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding  {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                print(error!.localizedDescription)
                return
            }
            // User is signed in to Firebase with Apple.
            // ...
            
            print("isNewUser",authResult?.additionalUserInfo?.isNewUser)
            if let vc = self.storyboard!.instantiateInitialViewController() {
                self.view.window?.rootViewController = vc
                if let bsvc = (vc as? UITabBarController)?.viewControllers?.first as? BookSelectingViewController,
                   let newUser = authResult?.additionalUserInfo?.isNewUser {
                    
                    bsvc.isNewUser = !newUser
                }
            }
        }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
