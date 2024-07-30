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
import FirebaseDatabase

//-----------------------------------------------------------------------------------------------------------------------------------------------
class SignUp1View: UIViewController {

	@IBOutlet var textFieldFirstName: UITextField!
	@IBOutlet var textFieldLastName: UITextField!
	@IBOutlet var textFieldEmail: UITextField!
	@IBOutlet var textFieldPassword: UITextField!
	@IBOutlet var textFieldPassword2: UITextField!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = false
		navigationItem.largeTitleDisplayMode = .never

		navigationItem.titleView = UIImageView(image: UIImage(systemName: "circles.hexagongrid.fill"))

		textFieldFirstName.setLeftPadding(value: 15)
		textFieldLastName.setLeftPadding(value: 15)
		textFieldEmail.setLeftPadding(value: 15)
		textFieldPassword.setLeftPadding(value: 15)
		textFieldPassword2.setLeftPadding(value: 15)
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionFacebook(_ sender: Any) {

		print(#function)
		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionContinue(_ sender: Any) {
		print(#function)
        if let name = textFieldFirstName.text, name.isEmpty {
            showAlert(title: "Atencion", message: "nombre vacio")
            return
        }
        if let lastName = textFieldFirstName.text, lastName.isEmpty {
            showAlert(title: "Atencion", message: "apellido vacio")
            return
        }
        if let email = textFieldEmail.text, email.isEmpty {
            showAlert(title: "Atencion", message: "email vacio")
            return
        }
        if let password = textFieldPassword.text, let password2 = textFieldPassword2.text{
            if password.isEmpty || password2.isEmpty {
                showAlert(title: "Atencion", message: "password vacio")
                return
            }
            else if password != password2 {
                showAlert(title: "Atencion", message: "no son iguales el password")
                return
            }
        }
        let fullName = textFieldFirstName.text ?? "" + " " + (textFieldLastName.text ?? "")
        
        let newUser = User(username: fullName, email: textFieldEmail.text ?? "", password: textFieldPassword.text ?? "")
        insertUserToFirebase(user: newUser)
        
        self.navigationController?.popViewController(animated: true)
	}

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTerms(_ sender: Any) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPrivacy(_ sender: Any) {

		print(#function)
	}
    
    func insertUserToFirebase(user: User) {
        let ref = Database.database().reference()
        guard let userData = try? JSONEncoder().encode(user),
              let userDict = try? JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any] else {
            print("Error encoding user data")
            return
        }

        let userId = ref.child("baseDatos").child("Usuarios").childByAutoId().key
        
        ref.child("baseDatos").child("Usuarios").child(userId!).setValue(userDict) { error, _ in
            if let error = error {
                print("Error writing user data to Firebase: \(error.localizedDescription)")
            } else {
                print("User data successfully written to Firebase")
            }
        }
    }
}
