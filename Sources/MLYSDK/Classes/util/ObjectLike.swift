class ObjectLike<T: Codable> : Codable {

    var data: [String:T] = [:]
    
    subscript(key: String) -> T? {
        set {
            if(newValue == nil){
                self.data.removeValue(forKey: key)
            }else{
                self.data[key] = newValue
            }
        }
        get {
            return self.data[key]
        }
    }

}
