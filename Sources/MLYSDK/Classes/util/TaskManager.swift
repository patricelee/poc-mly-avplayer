import Foundation

class TaskManager: Component {
    var states: [String: TaskState] = [:]

    func createCyclicTask(_ state: TaskState) async {
        self.states[state.name] = state
        while isActivated && state.isActivated {
            await state.delay()
            _ = await state.process()
        }
    }
}

class TaskState {
    var name: String
    var flow: Flow
    var sleepFirst: Bool
    var sleepSeconds: TimeInterval
    var sleepJitter: Double
    var maxErrorRetry: Int
    var maxTotalRetry: Int
    var count: Int = 0
    var result: Any?
    
    var isActivated: Bool {
        return maxTotalRetry == -1 || count <= maxTotalRetry
    }

    init(name: String,
         flow: Flow,
         sleepFirst: Bool = false,
         sleepSeconds: TimeInterval,
         sleepJitter: Double = 0,
         maxErrorRetry: Int,
         maxTotalRetry: Int)
    {
        self.name = name
        self.flow = flow
        self.sleepFirst = sleepFirst
        self.sleepSeconds = sleepSeconds
        self.sleepJitter = sleepJitter
        self.maxErrorRetry = maxErrorRetry
        self.maxTotalRetry = maxTotalRetry
    }
    
    init<T>(name: String,
         flow: AbstractFlow<T>,
         sleepFirst: Bool = false,
         sleepSeconds: TimeInterval,
         sleepJitter: Double = 0,
         maxErrorRetry: Int,
         maxTotalRetry: Int)
    {
        self.name = name
        self.flow = VoidFlow(flow)
        self.sleepFirst = sleepFirst
        self.sleepSeconds = sleepSeconds
        self.sleepJitter = sleepJitter
        self.maxErrorRetry = maxErrorRetry
        self.maxTotalRetry = maxTotalRetry
    }

    init(name: String,
         sleepFirst: Bool = false,
         sleepSeconds: TimeInterval,
         sleepJitter: Double = 0,
         maxErrorRetry: Int = -1,
         maxTotalRetry: Int = -1,
         _ callee: @escaping () async -> ())
    {
        self.name = name
        self.sleepFirst = sleepFirst
        self.sleepSeconds = sleepSeconds
        self.sleepJitter = sleepJitter
        self.maxErrorRetry = maxErrorRetry
        self.maxTotalRetry = maxTotalRetry
        self.flow = BlockFlow(callee)
    }

    func delay() async {
        if self.count > 0 || self.sleepFirst {
            await TaskTool.delay(seconds: self.sleepSeconds)
        }
    }

    func willProcess() {
        self.count += 1
    }

    func process() async {
        willProcess()
        self.result = await flow.process()
    }
}
