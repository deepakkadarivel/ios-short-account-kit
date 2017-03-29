// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit


// MARK: - LoginViewController: UIViewController

final class LoginViewController: UIViewController {

    // MARK: Properties
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var dataEntryViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    fileprivate var showProfileOnAppear = false
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var surfConnectLabel: UILabel!
    @IBOutlet weak var userProfileButton: UIButton!
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Account Kit
        showAccountOnAppear = accountKit.currentAccessToken != nil
        dataEntryViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
    
        // Styling
        facebookButton.titleLabel?.addTextSpacing(2.0)
        surfConnectLabel.addTextSpacing(4.0)
    
        // Facebook Login
        
        // Create the login button
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
    
        // Set read permissions
        loginButton.readPermissions = ["public_profile"]
        
        // Check if user is logged in
        showProfileOnAppear = FBSDKAccessToken.current() != nil
        
//        if ((FBSDKAccessToken.current()) != nil) {
//            presentWithSegueIdentifier("showProfile", animated: false)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // AccountKit
        if showAccountOnAppear {
            showAccountOnAppear = false
            presentWithSegueIdentifier("showAccount", animated: animated)
        } else if let viewController = dataEntryViewController {
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: animated, completion: nil)
                dataEntryViewController = nil
            }
        }
        
        // Facebook Login
        if showProfileOnAppear {
            showProfileOnAppear = false
            presentWithSegueIdentifier("showProfile", animated: false)
        }
        
        //Styling
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func loginWithPhone(_ sender: AnyObject) {
        FBSDKAppEvents.logEvent("loginWithPhone clicked")
        if let viewController = accountKit.viewControllerForPhoneLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginWithEmail(_ sender: AnyObject) {
        FBSDKAppEvents.logEvent("loginWithEmail clicked")
        if let viewController = accountKit.viewControllerForEmailLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {
            presentWithSegueIdentifier("showProfile", animated: true)
        }
    }
    
    // MARK: Helper Functions
    
    func prepareDataEntryViewController(_ viewController: AKFViewController){
        viewController.delegate = self
    }
    
    fileprivate func presentWithSegueIdentifier(_ segueIdentifier: String, animated: Bool) {
        if animated {
                performSegue(withIdentifier: segueIdentifier, sender: nil)
        } else {
            UIView.performWithoutAnimation {
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }
    
}

// MARK: - LoginViewController: AKFViewControllerDelegate

extension LoginViewController: AKFViewControllerDelegate {
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken, state: String!) {
        presentWithSegueIdentifier("showAccount", animated: false)
        
    }
    
    func viewController(_ viewController: UIViewController, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
}