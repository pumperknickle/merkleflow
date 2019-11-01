import Foundation
import MerkleModels
import Vapor

public protocol FlowMessageController {
	associatedtype FlowMessageType: FlowMessage
	
	func findAll(_ req: Request) throws -> Future<[FlowMessageType]>
	func create(_ req: Request) throws -> Future<FlowMessageType>
}
