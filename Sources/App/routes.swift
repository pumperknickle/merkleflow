import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "It works!"
    }
    
    router.get("hello") { req in
        return "Hello, world!"
    }
	
	let flowMessageController = FlowMessageController256()
	router.get("flows", use: flowMessageController.findAll)
	router.post("flows", use: flowMessageController.create)
//
//    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
