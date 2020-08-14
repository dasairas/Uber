

import UIKit
import Firebase
import MapKit

class HomeController : UIViewController {
    
    // MARK: Properties
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //signOut()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        
    }
    
    //MARK: API
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
        locationInputView.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            print("DEBUG: Present TableView in ")
        }
    }
    
    
}


//MARK: Location Services
extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices(){
        
        locationManager.delegate = self // es por el Delegate y la Func "didChangeAutorization"
        
        
        //Switch para determinar permisos auth
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: NOT DETERMINED")
            locationManager.requestWhenInUseAuthorization() //1 pide permiso de accso
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: AUTH ALWAYS")
            locationManager.startUpdatingLocation() //3 update location constantemente
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //4 busca mejorar la accuracy
        case .authorizedWhenInUse:
            print("DEBUG: AUTH WHEN IN USE")
            locationManager.requestAlwaysAuthorization() //2 luego del primer permiso pide el "always"
        @unknown default:
            break
        }
    }
    
    //Implementado por el "Delegate". Te pregunta si queres "always" luego de aceptar "when in use"
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
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
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}
