//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Firebase

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Login1View: UIViewController {

	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelSubTitle: UILabel!
	@IBOutlet var imageViewLogo: UIImageView!
	@IBOutlet var textFieldEmail: UITextField!
	@IBOutlet var textFieldPassword: UITextField!
	@IBOutlet var buttonHideShowPassword: UIButton!
    
    let authManager = AuthManager.shared
    let userDefaultsManager = UserDefaultsManager.shared
    let keyUser = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		textFieldEmail.setLeftPadding(value: 15)
		textFieldPassword.setLeftPadding(value: 15)
		textFieldPassword.setRightPadding(value: 40)

		loadData()
	}

	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

		labelTitle.text = "Welcome to\nBooksReview"
		labelSubTitle.text = "An exciting place for Books."
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHideShowPassword(_ sender: Any) {

		buttonHideShowPassword.isSelected = !buttonHideShowPassword.isSelected
		textFieldPassword.isSecureTextEntry = !buttonHideShowPassword.isSelected
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLogin(_ sender: Any) {
        validateFields()
	}
    
    func validateFields() {
        guard let email = textFieldEmail.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Email field cannot be empty.")
            return
        }
        
        guard let password = textFieldPassword.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Password field cannot be empty.")
            return
        }
        loginUser(email: textFieldEmail.text ?? "", password: textFieldPassword.text ?? "") { user in
            if let user = user, self.textFieldPassword.text == user.password{
                print("User: \(user)")
                let loginSuccess = self.authManager.login(username: user.username, email: user.email, password: user.password)
                if loginSuccess {
                    self.navigationController?.popViewController(animated: true)
                    print("success login")
                } else {
                    self.showAlert(title: "Error", message: "Email not found")
                    print("Login failed")
                }
                
            } else {
                self.showAlert(title: "Error", message: "failed login")
                print("User not found or login failed")
            }
        }
     }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loginUser(email: String, password: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("baseDatos").child("Usuarios").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot   in
            if let userDict = snapshot.value as? [String: [String: AnyObject]],
               let userKey = userDict.keys.first,
               let userData = userDict[userKey] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    self.userDefaultsManager.saveStringKey(value: userKey, forKey: "key")
                    completion(user)
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionForgotPassword(_ sender: Any) {

		print(#function)
		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSignUp(_ sender: Any) {

		print(#function)
        let vc = SignUp1View()
        self.navigationController?.pushViewController(vc, animated: true)
	}
}
