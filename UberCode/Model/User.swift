
//Creo Dictionary con Keys y los value surgen de "Service" completion


struct User {
    let fullname: String
    let email: String
    let accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["AccountType"] as? Int ?? 0
    }
}
