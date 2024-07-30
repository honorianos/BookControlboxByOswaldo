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

protocol DelegateFilterName {
    func getSortName(name: String)
    func getFilterName(name: String)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Items1View: UIViewController {
    
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubTitle: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var viewSortBy: UIView!
    @IBOutlet var viewFilters: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var sortFilterName = "Inicio Final"
    var filterName = "Nombre"
    let authManager = AuthManager.shared
    private var books: [Libros] = []
    private var booksTemp: [Libros] = []
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        labelTitle.text = "Books"
        
        viewSortBy.layer.borderWidth = 1
        viewSortBy.layer.borderColor = AppColor.Border.cgColor
        
        viewFilters.layer.borderWidth = 1
        viewFilters.layer.borderColor = AppColor.Border.cgColor
        
        navigationItem.titleView = viewTitle
        collectionView.register(UINib(nibName: "Items1Cell1", bundle: Bundle.main), forCellWithReuseIdentifier: "Items1Cell1")
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if authManager.isLoggedIn() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(actionCallLogout(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(actionCallLogin(_:)))
        }
        
    }
    
    @objc func actionCallLogin(_ sender: UIButton) {
        print(#function)
        let vc = Login1View()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func actionCallLogout(_ sender: UIButton) {
        authManager.logout()
        if authManager.isLoggedIn() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(actionCallLogout(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(actionCallLogin(_:)))
        }
    }
    
    // MARK: - Data methods
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func loadData() {
        
        booksTemp.removeAll()
        
        obtenerLibrosConComentarios { book, error in
            if let error = error {
                print("Error fetching books: \(error)")
            } else if let book = book {
                print("Fetched books: \(book)")
                self.books = book
                self.booksTemp = book
                self.labelSubTitle.text = "\(book.count) items"
                self.refreshCollectionView()
            }
        }
        
    }
    
    func fetchBooksFromFirebaseDatabase(completion: @escaping (Book?, Error?) -> Void) {
        let ref = Database.database().reference().child("baseDatos").child("libros")
        ref.observeSingleEvent(of: .value) { snapshot  in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"]))
                return
            }
            
            var libros = [Libros]()
            let dispatchGroup = DispatchGroup()
            
            for (key, libroValue) in value {
                dispatchGroup.enter()
                
                if var libroData = libroValue as? [String: Any] {
                    ref.child(key).child("comentarios").observeSingleEvent(of: .value) { comentariosSnapshot in
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
                        }
                        
                        libroData["comentarios"] = comentarios
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: libroData)
                            var libro = try JSONDecoder().decode(Libros.self, from: jsonData)
                            libro.comentarios = comentarios
                            libros.append(libro)
                        } catch {
                            print("Error decoding libro: \(error)")
                        }
                        
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(Book(libros: libros), nil)
            }
        }
        
    }

    func obtenerLibrosConComentarios(completion: @escaping ([Libros]?, Error?) -> Void) {
        let ref = Database.database().reference().child("baseDatos").child("libros")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"]))
                return
            }
            
            var libros = [Libros]()
            let dispatchGroup = DispatchGroup()
            
            for (key, libroValue) in value {
                dispatchGroup.enter()
                
                if var libroData = libroValue as? [String: Any] {
                    ref.child(key).child("comentarios").observeSingleEvent(of: .value) { comentariosSnapshot in
                        var comentarios = [Comentarios]()
                        
                        if let comentariosValue = comentariosSnapshot.value as? [String: Any] {
                            for (_, comentarioValue) in comentariosValue {
                                if let comentarioData = comentarioValue as? [String: Any] {
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: comentarioData, options: [])
                                        let comentario = try JSONDecoder().decode(Comentarios.self, from: jsonData)
                                        comentarios.append(comentario)
                                    } catch {
                                        print("Error decoding comentario: \(error)")
                                    }
                                }
                            }
                        }
                        
                        libroData["comentarios"] = comentarios.map { $0.dictionaryRepresentation }
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: libroData, options: [])
                            var libro = try JSONDecoder().decode(Libros.self, from: jsonData)
                            libro.comentarios = comentarios
                            libros.append(libro)
                        } catch {
                            print("Error decoding libro: \(error)")
                        }
                        
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(libros, nil)
            }
        }
    }


    // MARK: - Refresh methods
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func refreshCollectionView() {
        
        collectionView.reloadData()
    }
    
    // MARK: - User actions
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionSortBy(_ sender: UIButton) {
        
        print(#function)
        callFilterManager(context: .Sort)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionFilter(_ sender: UIButton) {
        print(#function)
        callFilterManager(context: .Filter)
    }
    
    func callFilterManager(context: ContextSortBy) {
        let vc = SortByView()
        vc.context = context
        switch context {
        case .Sort:
            vc.valueSortName = self.sortFilterName
        case .Filter:
            vc.valueSortName = self.filterName
        }
        vc.delegate = self
        self.navigationController?.present(vc, animated: true)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionFavorite(_ sender: UIButton) {
        
        print(#function)
        dismiss(animated: true)
    }
}

extension Items1View: DelegateFilterName {
    
    func getSortName(name: String) {
        print(name)
        self.sortFilterName = name
    }
    
    func getFilterName(name: String) {
        print(name)
        self.filterName = name
    }
    
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Items1View: UICollectionViewDataSource {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return booksTemp.count
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Items1Cell1", for: indexPath) as! Items1Cell1
        cell.bindData(index: indexPath.item, data: booksTemp[indexPath.row])
        cell.buttonFavorite.tag = indexPath.row
        cell.buttonFavorite.addTarget(self, action: #selector(actionFavorite(_:)), for: .touchUpInside)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Items1View: UICollectionViewDelegate {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(#function)
        let vc = Item3View()
        vc.viewData = booksTemp[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Items1View: UICollectionViewDelegateFlowLayout {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width-45)/2
        return CGSize(width: width, height: (width*1.3))
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
}

extension Items1View: UISearchBarDelegate {
    // MARK: - UISearchControllerDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        booksTemp = []
        if searchText.isEmpty {
            booksTemp = books
        }
        else {
            for i in books {
                switch filterName {
                case "Nombre":
                    if i.nombre.lowercased().contains(searchText.lowercased()) {
                        booksTemp.append(i)
                    }
                case "Categoria":
                    if i.categoria.lowercased().contains(searchText.lowercased()) {
                        booksTemp.append(i)
                    }
                case "Autor":
                    if i.autor.lowercased().contains(searchText.lowercased()) {
                        booksTemp.append(i)
                    }
                default:
                    if i.nombre.lowercased().contains(searchText.lowercased()) {
                        booksTemp.append(i)
                    }
                }
                
            }
            if sortFilterName != "Inicio Final" {
                booksTemp.reverse()
            }
        }
        self.refreshCollectionView()
    }
}

extension Encodable {
    var dictionaryRepresentation: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
