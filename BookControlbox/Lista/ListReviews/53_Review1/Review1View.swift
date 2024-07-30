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
class Review1View: UIViewController {

	@IBOutlet var tableView: UITableView!

	@IBOutlet var buttonTab1: UIButton!
	@IBOutlet var buttonTab2: UIButton!

	@IBOutlet var viewTab1: UIView!
	@IBOutlet var viewTab2: UIView!

	@IBOutlet var imageRating1: UIImageView!
	@IBOutlet var imageRating2: UIImageView!
	@IBOutlet var imageRating3: UIImageView!
	@IBOutlet var imageRating4: UIImageView!
	@IBOutlet var imageRating5: UIImageView!
	@IBOutlet var labelReviews: UILabel!
    
    let authManager = AuthManager.shared

	private var reviews: [[String: String]] = []
    var comentarios = [Comentarios]()
    var viewData = ""
    var viewRate: Int? = 0
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Reviews"

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		tableView.register(UINib(nibName: "Review1Cell1", bundle: Bundle.main), forCellReuseIdentifier: "Review1Cell1")
		tableView.estimatedRowHeight = 100

	}
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add a Review", style: .done, target: self, action: #selector(actionAddReview(_:)))
        loadData()
    }

	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {
        comentarios.removeAll()
        
        let ref = Database.database().reference().child("baseDatos").child("libros").child(viewData)
        ref.child("comentarios").queryOrdered(byChild: "fecha").observeSingleEvent(of: .value) { comentariosSnapshot in
            var comentarios = [Comentarios]()
            
            if let comentariosValue = comentariosSnapshot.value as? [String: Any] {
                for (_, comentarioValue) in comentariosValue {
                    if let comentarioData = comentarioValue as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: comentarioData)
                            let comentario = try JSONDecoder().decode(Comentarios.self, from: jsonData)
                            comentarios.append(comentario)
                        } catch {
                            print("Error decoding comentario: \(error)")
                        }
                    }
                }
                self.comentarios = comentarios
                if self.comentarios.count > 0 {
                    var promedio = 0.0
                    var promedioTotal: Int? = 0
                    for i in self.comentarios {
                        promedio = promedio + i.valoracion
                    }
                    promedioTotal = Int(promedio/Double(self.comentarios.count))
                    if let rate = promedioTotal {
                        self.imageRating1.tintColor = (rate>=1) ? AppColor.Theme : UIColor.systemGray
                        self.imageRating2.tintColor = (rate>=2) ? AppColor.Theme : UIColor.systemGray
                        self.imageRating3.tintColor = (rate>=3) ? AppColor.Theme : UIColor.systemGray
                        self.imageRating4.tintColor = (rate>=4) ? AppColor.Theme : UIColor.systemGray
                        self.imageRating5.tintColor = (rate>=5) ? AppColor.Theme : UIColor.systemGray
                    }
                }
                self.labelReviews.text = "\(comentarios.count) Reviews"
                self.refreshTableView()
            }
        }
		refreshTableView()
	}

	// MARK: - Refresh methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView() {

		tableView.reloadData()
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateUI() {

		buttonTab1.titleLabel?.textColor = buttonTab1.isSelected ? AppColor.Theme : UIColor.label
		buttonTab2.titleLabel?.textColor = buttonTab2.isSelected ? AppColor.Theme : UIColor.label

		viewTab1.backgroundColor = buttonTab1.isSelected ? AppColor.Theme : UIColor.opaqueSeparator
		viewTab2.backgroundColor = buttonTab2.isSelected ? AppColor.Theme : UIColor.opaqueSeparator
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAddReview(_ sender: UIButton) {
        if authManager.isLoggedIn() {
            let vc = AddReview1View()
            vc.viewData = viewData
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        } else {
            let alertController = UIAlertController(title: "Atencion", message: "Debes logearte para agregar un review", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTab1(_ sender: UIButton) {

		print(#function)
		buttonTab1.isSelected = true
		buttonTab2.isSelected = false
		updateUI()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTab2(_ sender: UIButton) {

		print(#function)
		buttonTab1.isSelected = false
		buttonTab2.isSelected = true
		updateUI()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionLike(_ sender: UIButton) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionUnike(_ sender: UIButton) {

		print(#function)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Review1View: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return comentarios.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "Review1Cell1", for: indexPath) as! Review1Cell1
		cell.bindData(data: comentarios[indexPath.row])
		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Review1View: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return UITableView.automaticDimension
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		print(#function)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension Review1View: updateService {
    func callUpdate() {
        loadData()
    }
}
