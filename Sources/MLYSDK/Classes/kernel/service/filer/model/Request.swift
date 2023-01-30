class Request {
    var task: SpecTask
    var resource: Resource
    var isAborted: Bool {
        return self.task.isAborted ?? false
    }
    
    init(_ task: SpecTask, _ resource: Resource) {
        self.task = task
        self.resource = resource
    }

    func exit() async {
        self.task.exit()
    }

    func done() async {
        await self.task.done()
        self.resource.content = self.task.data
        self.resource.type = self.task.type
        self.resource.total = self.task.data?.count
        self.resource.isComplete = true
    }

    func abort(_ error: Error) async {
        self.task.abort()
    }
}
