import Foundation
import MerkleModels
import Vapor
import FluentPostgreSQL

struct FlowMessageController256: FlowMessageController {
	typealias FlowMessageType = FlowMessage256
	
	func findAll(_ req: Request) throws -> Future<[FlowMessageType]> {
		let limit = try? req.query.get(Int.self, at: "limit")
		let flow = try? req.query.get(String.self, at: "flow")
		let publicKeyHashString = try? req.query.get(String.self, at: "publicKeyHash")
		let publicKeyHash = publicKeyHashString != nil ? FlowMessageType.Digest(stringValue: publicKeyHashString!) : nil
		let query = FlowMessageType.query(on: req)
		let queryAfterFlow = flow != nil ? query.filter(\.flow == flow) : query
		let queryAfterPKHash = publicKeyHash != nil ? queryAfterFlow.filter(\.publicKeyHash == publicKeyHash) : queryAfterFlow
		return limit != nil ? queryAfterPKHash.range(..<limit!).all() : queryAfterPKHash.all()
	}
	
	private enum Error: Swift.Error {
        case publicKeyNotFound, signatureVerificationError, inputValidationError
    }
	
	func create(_ req: Request) throws -> Future<FlowMessageType> {
		return try req.content.decode(FlowMessageType.self).flatMap { flowMessage in
			guard let publicKey = flowMessage.publicKey else { throw Error.publicKeyNotFound }
			if !flowMessage.verify(publicKey: publicKey) { throw Error.signatureVerificationError }
			if flowMessage.fluentID != nil || flowMessage.createdAt != nil { throw Error.inputValidationError }
			return flowMessage.removingPublicKey().save(on: req)
		}
	}
	
	init() { }

//	
//	public func findAll(_ req: Request) throws -> Future<[FlowMessage256]> {
//		let flow = try req.query.get(String.self, at: "flow")
//		let publicKeyHash = try req.query.get(String.self, at: "publicKeyHash")
//		
//	}
//	
//	public func create(_ req: Request) throws -> Future<FlowMessage256> {
//		<#code#>
//	}
}


//import Vapor
//
///// Controls basic CRUD operations on `Todo`s.
//final class TodoController {
//    /// Returns a list of all `Todo`s.
//    func index(_ req: Request) throws -> Future<[Todo]> {
//        return Todo.query(on: req).all()
//    }
//
//    /// Saves a decoded `Todo` to the database.
//    func create(_ req: Request) throws -> Future<Todo> {
//        return try req.content.decode(Todo.self).flatMap { todo in
//            return todo.save(on: req)
//        }
//    }
//
//    /// Deletes a parameterized `Todo`.
//    func delete(_ req: Request) throws -> Future<HTTPStatus> {
//        return try req.parameters.next(Todo.self).flatMap { todo in
//            return todo.delete(on: req)
//        }.transform(to: .ok)
//    }
//}
