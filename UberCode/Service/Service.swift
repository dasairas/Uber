

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()  //access Firebase data
let REF_USERS = DB_REF.child("users") //carpeta "users"
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")


struct Service {
    
    static let shared = Service()
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }  //current user
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let user = User(dictionary: dictionary)
            completion(user) //busca en el Firebase, crea un dictionary y completa los "Value" del "Key" de "Users.swift"
        }
    }
    
    func fetchDrivers(location: CLLocation) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with:  { (uid, location) in //busca en "LOCATIONS" el query "location" y devuelve uid y location con radius 50
                
            })
        }
        
    }
}
