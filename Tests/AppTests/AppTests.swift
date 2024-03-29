@testable import App
import Vapor
import XCTest
import FluentPostgreSQL
import MerkleModels
import Bedrock
import CryptoStarterPack

final class AppTests: XCTestCase {
    func testNothing() throws {
        // Add your tests here
        XCTAssert(true)
    }
	
	
	func testGetAndCreate() throws {
		var config = Config.default()
		var services = Services.default()
		var env = Environment.testing
		try App.configure(&config, &env, &services)
		let app = try Application(config: config, environment: env, services: services)
		try App.boot(app)

		let key = UInt256.random()
		let encryptedAddress = EncryptedAddress256(addressHash: UInt256(0), symmetricKey: key, recipientPublicKeys: [publicKey])
		let signedMessage = FlowMessage256(flow: "flow", privateKey: privateKey, publicKey: publicKey, message: encryptedAddress!)
		XCTAssertTrue(signedMessage != nil)
		let responder = try app.make(Responder.self)
		
		let createRequest = HTTPRequest(method: .POST, url: URL(string: "flows")!, headers: ["Content-Type": "application/json"])
		let wrappedCreateRequest = Request(http: createRequest, using: app)
		try wrappedCreateRequest.content.encode(signedMessage!)
		
		let createResponse = try responder.respond(to: wrappedCreateRequest).wait()
		
		let createResponseContent = try? createResponse.content.decode(FlowMessage256.self).wait()
		
		XCTAssertNotNil(createResponseContent)
		XCTAssertNotNil(createResponseContent!.id)
		XCTAssertNotNil(createResponseContent!.createdAt)
		
		let request = HTTPRequest(method: .GET, url: URL(string: "flows")!)
		let wrappedRequest = Request(http: request, using: app)

		let response = try responder.respond(to: wrappedRequest).wait()

		let savedMessages = try? response.content.decode([FlowMessage256].self).wait()
		
		XCTAssertNotNil(savedMessages)
		XCTAssertNotEqual(savedMessages!.count, 0)
	}

    static let allTests = [
        ("testNothing", testNothing),
		("testCreate", testGetAndCreate)
    ]
}

let privateKey = """
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAlznyd/pK9bVqC8JUv8q3SN8yCuk1vagIyHgF0MJPPIlU5fpX
HyUKN60IaIjD4ujjHu0mDnmJo9rh4gkXlfymIWl5gAD1tQ6K4u9TwIOB7oowBKYG
1xHNYBHZxP3pj/7rgKkQEvBZUrdBi4ss9wVvqjFK0wz7GiN8F2uxvR0foeqT/RV/
HZoglhVmj2FwC2hHIQFCrOgmzmbtEEyvC+h9DaSr7h5d6UM5Konqktq6OaZCALbo
IriaQnTjcyexcpSENLnPFMiNdUiOTQyXOKEI+ar59AdIpmEespwlQDFMka0MoxsX
vr4tRmeyl49En0EqYYRH5AIeeblkHfPh/fiBXwIDAQABAoIBAAzJLHPyaIYPuZCW
9J1moUp6/Hspro6Dd4KjizJUS2i937y2BsmuUwfUDGLyNUWpFRLXUCFnKzj8V57J
0AGxY8ZtaYVmD2Aog5ueSoF7XO/zJQ4vj2J9sdSOjc/2+9ld30F4idBgG90/ez42
HS4heoh0NHRVo6FZILPGOjfYD4Wb83L0gai+5kkhecDg8UWtVSzYbIyhB7G7SeWW
ogyQrugQbptB6TYTnoPsmraouU2aVEMOhC5sHLk3s7YGKce1UWJB95SUBSNE3itr
ljLkYBP42gjEzvc0sfNrXuxRXiQyrD+Go5lptsWE7aBpJk9nsXFsN1Kl6FqBTn+s
eFJSC1kCgYEAx1/AVsY2Isc96go9Owfz+PTrR8/PaWbcrjZLMmq5G7f0rTCRjUc9
MhYu2AiD1khauZD3TBsspO6WKALAJJlsv2GCuBCo42tUNz1JWystIYcfe64u3zaz
HVWV3H6mwfoND4EMoT0cytwadpf6629ql/b0o/vRwXAjxP2LTDnuIu0CgYEAwi1v
jmNI3raY46uv6X4LQEHpSQiLiNazVd2J724ZXeGdZCqDsRQCZYkZqyFZtd1yEiTd
6Ah1CS3H3a/MUt80AgPNb4MaRZWetZNavtNZ/JdqpN5FFsgrnmU7xOmhV+4HjQpE
pqU8qFpUey+L6A+iyZ8D2P+OVhaVKM5+2qlF7/sCgYA/x2S7HZtR0tT+mpnt2WR1
nrvpdBQQzsQHwvyZO0TOFjHieWgGfuSXsjr4BvlNwkWrmTFTGlpUxLIqSH749k+w
hVwQz9uHLN168lMWJCDC2fv7T8RUyaXQ24EeUTG9WeV1sT2+EtO0HWclywaM7E54
IJswHi2CqQH4UXePQfTpHQKBgQC284BMNBeQX5Kl0DmqUWvgWzml6jst7ryBhn5T
7PRRlCVrHvN9gFDRwd9BcebIh6DWn43E9VLwFwZdRSnKWyrxSwvgqTGzpkkm43N4
oEIEz9VXCWUnFeqjDtbFrSqrYkYTCT2tlboVFSbL+fxj5XeHaB+D8ST2z8gx7n1v
IFYYyQKBgClVy+MWDCJPMm2dRk6AEKGdAs4yiO5Sb710t29kvxKtZzUuyFCRZAtt
ENIcr0ZvAo6rQwP+DgsvYdKeUQbQaKDR82HkT/SUNPergdp5SFaR2C2XpRyYHh5q
Xj9uKUw0ExH06Qa5GGAcVhcw0PyGtM09Mu93iQbMUukBqQGQN5Z3
-----END RSA PRIVATE KEY-----
"""

let publicKey = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlznyd/pK9bVqC8JUv8q3
SN8yCuk1vagIyHgF0MJPPIlU5fpXHyUKN60IaIjD4ujjHu0mDnmJo9rh4gkXlfym
IWl5gAD1tQ6K4u9TwIOB7oowBKYG1xHNYBHZxP3pj/7rgKkQEvBZUrdBi4ss9wVv
qjFK0wz7GiN8F2uxvR0foeqT/RV/HZoglhVmj2FwC2hHIQFCrOgmzmbtEEyvC+h9
DaSr7h5d6UM5Konqktq6OaZCALboIriaQnTjcyexcpSENLnPFMiNdUiOTQyXOKEI
+ar59AdIpmEespwlQDFMka0MoxsXvr4tRmeyl49En0EqYYRH5AIeeblkHfPh/fiB
XwIDAQAB
-----END PUBLIC KEY-----
"""

