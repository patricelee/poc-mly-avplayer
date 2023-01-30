import SwiftEventBus

class EventTool {
    
    func on(_ event: String, _ handler: @escaping (Any) -> ()) {
        SwiftEventBus.onBackgroundThread(self, name: event, sender: self) { notify in
            if let data = notify?.userInfo?["data"] {
                handler(data)
            }
        }
    }

    func emit(_ event: String, _ data: Any) {
        SwiftEventBus.post(event, sender: self, userInfo: ["data": data])
    }
    
    func unregisterAll(){
        SwiftEventBus.unregister(self)
    }
    
    func unregister(_ event: String){
        SwiftEventBus.unregister(self, name: event)
    }
}
