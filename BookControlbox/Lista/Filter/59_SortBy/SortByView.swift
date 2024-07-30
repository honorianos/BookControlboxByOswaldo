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

enum ContextSortBy {
    case Sort
    case Filter
}

enum SortBy: String {
    case nombre
    case Filter
}
//-----------------------------------------------------------------------------------------------------------------------------------------------
class SortByView: UIViewController {

	@IBOutlet var pickerView: UIPickerView!
    @IBOutlet weak var selectedName: UILabel!
    
	private var sortBy: [String] = []
    private var value: String = ""
    var valueSortName = ""
    var context: ContextSortBy = .Sort
    var delegate: DelegateFilterName?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		loadData()
	}

	// MARK: - Data methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

		sortBy.removeAll()
        
        switch context  {
        case .Sort:
            sortBy.append("Inicio - Final")
            sortBy.append("Final - Inicio")
        case .Filter:
            sortBy.append("Nombre")
            sortBy.append("Autor")
            sortBy.append("Categoria")
        }
        
        loadViews(value)
		refreshPickerView()
	}
    
    func loadViews(_ data: String) {
        selectedName.text = "Seleccionado: \(valueSortName)"
    }

	// MARK: - Refresh methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshPickerView() {

		pickerView.reloadAllComponents()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionClose(_ sender: UIButton) {

		print(#function)
		dismiss(animated: true, completion: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionDone(_ sender: UIButton) {

		print(#function)
        switch context {
        case .Sort:
            delegate?.getSortName(name: value)
        case .Filter:
            delegate?.getFilterName(name: value)
        }
        self.dismiss(animated: true)
	}
}

// MARK: - UIPickerViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SortByView: UIPickerViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfComponents(in pickerView: UIPickerView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		sortBy.count
	}
}

// MARK: - UIPickerViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SortByView: UIPickerViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {

		return 45
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

		let label = UILabel()
		label.text = sortBy[row]
		label.font = UIFont.systemFont(ofSize: 16)
		label.textAlignment = .center
        value = sortBy[row]
		return label
	}
}
