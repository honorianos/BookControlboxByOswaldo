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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Item3View: UIViewController {
    
    @IBOutlet var collectionViewSlider: UICollectionView!
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelBrandName: UILabel!
    @IBOutlet var labelPrice: UILabel!
    @IBOutlet var labelOriginalPrice: UILabel!
    
    @IBOutlet var imageRating1: UIImageView!
    @IBOutlet var imageRating2: UIImageView!
    @IBOutlet var imageRating3: UIImageView!
    @IBOutlet var imageRating4: UIImageView!
    @IBOutlet var imageRating5: UIImageView!
    @IBOutlet var labelReviews: UILabel!
    @IBOutlet var labelDescription: UILabel!
    
    let authManager = AuthManager.shared
    var viewData = Libros(autor: "", comentarios: [Comentarios](), foto: "", nombre: "", valoraciones: 0.0, categoria: "", id: "")
    private var images = ["", "", "", "", "", ""]
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let buttonReview = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(actionReviewNav))
        navigationItem.rightBarButtonItems = [buttonReview]
        
        collectionViewSlider.register(UINib(nibName: "Item3Cell1", bundle: Bundle.main), forCellWithReuseIdentifier: "Item3Cell1")
        
        let cellWidth = UIScreen.main.bounds.width - 100
        let sectionSpacing = CGFloat(30)
        let cellSpacing = CGFloat(10)
        
        if let layout = collectionViewSlider.collectionViewLayout as? Item3PagingCollectionViewLayout {
            layout.sectionInset = UIEdgeInsets(top: 0, left: sectionSpacing, bottom: 0, right: sectionSpacing)
            layout.itemSize = CGSize(width: cellWidth, height: collectionViewSlider.frame.size.height)
            layout.minimumLineSpacing = cellSpacing
            collectionViewSlider.collectionViewLayout = layout
            collectionViewSlider.translatesAutoresizingMaskIntoConstraints = false
            collectionViewSlider.decelerationRate = .fast
        }
        
        loadData()
    }
    
    // MARK: - Data methods
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func loadData() {
        
        labelTitle.text = viewData.nombre
        labelBrandName.text = viewData.autor
        labelPrice.text = viewData.categoria
        labelOriginalPrice.isHidden = true
        labelOriginalPrice.isHidden = false
        labelDescription.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        labelReviews.text = "\(viewData.comentarios?.count ?? 0) reviews"
        let intValue: Int? = Int(ceil(viewData.valoraciones))
        if let rate = intValue {
            imageRating1.tintColor = (rate>=1) ? AppColor.Theme : UIColor.systemGray
            imageRating2.tintColor = (rate>=2) ? AppColor.Theme : UIColor.systemGray
            imageRating3.tintColor = (rate>=3) ? AppColor.Theme : UIColor.systemGray
            imageRating4.tintColor = (rate>=4) ? AppColor.Theme : UIColor.systemGray
            imageRating5.tintColor = (rate>=5) ? AppColor.Theme : UIColor.systemGray
        }
    }
    
    // MARK: - User actions
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionReviewNav(_ sender: UIButton) {
        
        if authManager.isLoggedIn() {
            let vc = Review1View()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let alertController = UIAlertController(title: "Atencion", message: "Debes logearte para agregar un review", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionReview(_ sender: UIButton) {
        print(#function)
        let vc = Review1View()
        vc.viewData = viewData.id
        let intValue: Int? = Int(ceil(viewData.valoraciones))
        vc.viewRate = intValue
        vc.comentarios = viewData.comentarios ?? [Comentarios]()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionColor(_ sender: UIButton) {
        
        print(#function)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionSize(_ sender: UIButton) {
        
        print(#function)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionAddCart(_ sender: UIButton) {
        let vc = AddReview1View()
        
        self.navigationController?.present(vc, animated: true)
        print(#function)
    }
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Item3View: UICollectionViewDataSource {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView == collectionViewSlider) { return 10 }
        
        return 0
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == collectionViewSlider) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item3Cell1", for: indexPath) as! Item3Cell1
            cell.bindData(index: indexPath,foto: viewData.foto)
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Item3View: UICollectionViewDelegate {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == collectionViewSlider) { }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Item3View: UICollectionViewDelegateFlowLayout {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        
        if (collectionView == collectionViewSlider) { return CGSize(width: width-100, height: height) }
        
        return CGSize.zero
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if (collectionView == collectionViewSlider) { return 10 }
        
        return 0
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if (collectionView == collectionViewSlider) { return 10 }
        
        return 0
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if (collectionView == collectionViewSlider) { return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 30) }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
