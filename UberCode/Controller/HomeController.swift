

import UIKit
import Firebase
import MapKit


private let reuseIdentifier = "Location Cell"

class HomeController : UIViewController {
    
    
    // MARK: Properties
    private let mapView = MKMapView()
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private var user: User? {
        didSet { locationInputView.user = user } //setea user con locationinputview user
    }
    
    
    private final let locationInputViewHeight: CGFloat  = 200
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //signOut()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        fetchUserData()
        fetchDrivers()
    }
    
   
    //MARK: API
    func fetchUserData() {  //func de "Service"
        Service.shared.fetchUserData { user in //setea self.user con user
            self.user = user
        }
    }
    
    func fetchDrivers() { //func de "Service" --> da locaizacion de cada driver en las condiciones de la func
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("Error signing out")
        }
    }
    
    //MARK: Helper Functions
    
    func configureUI() {
        configureMapView()
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        inputActivationView.alpha = 0 // elimina la View
        inputActivationView.delegate = self //muestra el mensaje del VC LocationInputActivation
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1 //aparece la view con efecto
        }
        configureTableView()
    }
    
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true // poner en la View la ubicacion
        mapView.userTrackingMode = .follow //follow de la location - clave para uber
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight  //ejecuta tableview
            })
            
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
        tableView.tableFooterView = UIView() //sin renglones vacios abajo
    }
}


//MARK: Location Services
extension HomeController{
    
    func enableLocationServices(){
        //Switch para determinar permisos auth
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: NOT DETERMINED")
            locationManager?.requestWhenInUseAuthorization() //1 pide permiso de accso
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: AUTH ALWAYS")
            locationManager?.startUpdatingLocation() //3 update location constantemente
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //4 busca mejorar la accuracy
        case .authorizedWhenInUse:
            print("DEBUG: AUTH WHEN IN USE")
            locationManager?.requestAlwaysAuthorization() //2 luego del primer permiso pide el "always"
        @unknown default:
            break
        }
    }
}



// traigo el Protocol a esta VC, con su func predeterminada. Arriba creo su delegate = self
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0 //oculto la barra de "where to?"
        configureLocationInputView() //al hacer click abre la Func y eso abre la tableview
    }
}

extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height  //desaparece TableView
        }) { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations:  {
                self.inputActivationView.alpha = 1
            })
        }
    }
}


//MARK: UITableView Delegate-DataSource (las dos primeras x FIX / las otras "search")
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TEST"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5  // return section = 0 yes 2 no 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
    
}
