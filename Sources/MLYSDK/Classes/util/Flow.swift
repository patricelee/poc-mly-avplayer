import Foundation

protocol SpecFlow {
    func process() async -> Any?
    func create() async
    func destory() async
}

class AbstractFlow<T> {
    
    var _content: T
    private var data: [String: Any] = [:]

    init(content: T) {
        self._content = content
    }

    func process() async {
        Logger.error("AbstractFlow \(type(of: self)) process didnot implemented")
    }

    func create() async {
        Logger.info("AbstractFlow \(type(of: self)) create didnot implemented")
    }

    func destory() async {
        Logger.info("AbstractFlow \(type(of: self)) destory didnot implemented")
    }

    func _remove(_ keys: String...) async {
        for key in keys {
            self.data.removeValue(forKey: key)
        }
    }

    func _expose(_ key: String, _ value: Any?) async {
        if value == nil {
            self.data.removeValue(forKey: key)
        } else {
            self.data[key] = value
        }
    }

    func _require(_ key: String) async -> Any? {
        return self.data[key]
    }
    
}

class VoidFlow<T>: Flow {
    
    var flow: AbstractFlow<T>
    
    init(_ flow: AbstractFlow<T>) {
        self.flow = flow
    }
    
    override func process() async -> Any? {
        await self.flow.process()
    }
    
}


class BlockFlow: Flow {
    
    var block: () async ->()
    
    init(_ block: @escaping () async ->()) {
        self.block = block
    }
    
    override func process() async -> Any? {
        await block()
    }
    
}

class Flow: SpecFlow {
    private var data: [String: Any] = [:]

    func process() async -> Any? {
        Logger.error("\(type(of: self)) process")
        return nil
    }

    func create() async {
        Logger.info("\(type(of: self)) create")
    }

    func destory() async {
        Logger.info("\(type(of: self)) destory")
    }

    func _remove(_ keys: String...) async {
        for key in keys {
            self.data.removeValue(forKey: key)
        }
    }

    func _expose(_ key: String, _ value: Any?) async {
        if value == nil {
            await _remove(key)
        } else {
            self.data[key] = value
        }
    }

    func _require(_ key: String) async -> Any? {
        return self.data[key]
    }
}

struct FlowOptions<T> {
    var id: String!
    var content: T!
}
