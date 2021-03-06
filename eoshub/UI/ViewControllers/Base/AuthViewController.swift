//
//  AuthManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import RxSwift


class AuthViewController: BaseViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func login(with type: LoginType) {
        switch type {
        case .facebook:
            loginWithFacebook()
        case .google:
            loginWithGoogle()
        case .none:
            loginAnonymously()
        
        default:
            break
        }
        
    }
    
    private func loginWithGoogle() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    //MARK: Facebook
    private func loginWithFacebook() {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { [weak self](result, error) in
            if let error = error {
                Log.e(error)
                self?.failToLogin(error: error)
                return
            }
            
            if result?.isCancelled == true {
                Log.e("Canceled")
                self?.failToLogin(error: nil)
                return
            } else {
                Log.i("Logged in")
                self?.handleLoggedInWithFacebook()
            }
        }
    }
    
    
    private func handleLoggedInWithFacebook() {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
                .start { [weak self] (connection, result, error) in
                    if error == nil {
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        self?.handleCredential(credential: credential)
                    } else {
                        self?.failToLogin(error: error!)
                    }
            }
        }
        
        
       
    }
    
    
    //MARK: Google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            failToLogin(error: error)
        }
        
        guard let authentication = user?.authentication else {
            failToLogin(error: nil)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        handleCredential(credential: credential)
    }
    
    //MARK: Email Password
//    @remarks Possible error codes:
//
//    + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.
//    + `FIRAuthErrorCodeEmailAlreadyInUse` - Indicates the email used to attempt sign up
//    already exists. Call fetchProvidersForEmail to check which sign-in mechanisms the user
//    used, and prompt the user to sign in with one of those.
//    + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that email and password accounts
//    are not enabled. Enable them in the Auth section of the Firebase console.
//    + `FIRAuthErrorCodeWeakPassword` - Indicates an attempt to set a password that is
//    considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
//    dictionary object will contain more detailed explanation that can be shown to the user.
//
//    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.

    
    
    //MARK: EmailLink
    private func loginWithEmail(email: String) {
        //send sing in link request
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://eoshub.page.link/email")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: email,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    if let error = error {
                                        Log.e(error)
                                        return
                                    }
                                    // The link was successfully sent. Inform the user.
                                    // Save the email locally so you don't need to ask the user for it again
                                    // if they open the link on the same device.
//                                    UserDefaults.standard.set(email, forKey: "Email")
//                                    self.showMessagePrompt("Check your email for link")
                                    // ...
        }
    }
    
    //MARK: Anonymous
    private func loginAnonymously() {
        Auth.auth().signInAnonymously() { [weak self](user, error) in
            guard let user = user else { return }
            
            if let error = error {
                self?.failToLogin(error: error)
                return
            }
            
            self?.loggedIn(user: user)
            
            Log.i("User is signed in Anonymously")
        }
    }
    
    
    private func handleCredential(credential: AuthCredential) {
        WaitingView.shared.start()
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self](user, error) in
            WaitingView.shared.stop()
            if let error = error {
                 self?.failToLogin(error: error)
                return
            }
            
            guard let user = user else { return }
            
            
            self?.loggedIn(user: user)
        }
    }
    
   
    func loggedIn(user: AuthDataResult) {
        //override it
        Log.i("User is signed in")
    }
    
    func failToLogin(error: Error?) {
        
    }
    
}
