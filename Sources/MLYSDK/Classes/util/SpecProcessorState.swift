protocol SpecProcessorState {

    var isInitial: Bool { get set }
    var isRunning: Bool { get set }
    var isExiting: Bool { get set }
    var isExited: Bool { get set }

}
enum EnumProcessorState {
    case initial, running, exiting, exited
}

class ProcessorState: SpecProcessorState {
    var state: EnumProcessorState = .initial
    var isInitial: Bool {
        get {
            return self.state == .initial
        }
        set {
            self.state = .initial
        }
    }

    var isRunning: Bool {
        get {
            return self.state == .running
        }
        set {
            self.state = .running
        }
    }

    var isExiting: Bool {
        get {
            return self.state == .exiting
        }
        set {
            self.state = .exiting
        }
    }

    var isExited: Bool {
        get {
            return self.state == .exited
        }
        set {
            self.state = .exited
        }
    }

    func toInitial() {
        self.state = .initial
    }
    func toRunning() {
        self.state = .running
    }
    func toExiting() {
        self.state = .exiting
    }
    func toExited() {
        self.state = .exited
    }

}
