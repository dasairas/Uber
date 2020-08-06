

import UIKit
import Firebase
import MapKit

class HomeController : UIViewController {
    
    // MARK: Properties
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private let InputActivationView = LocationInputActivationView()
    
    
    
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
        } else { // o sea está logeado -->
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
        
        view.addSubview(InputActivationView)
        InputActivationView.centerX(inView: view)
        InputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        InputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
    }
    
    func configureMapView() {
       view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true // poner en la View la ubicacion
        mapView.userTrackingMode = .follow //follow de la location - clave para uber
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
