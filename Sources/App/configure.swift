import FluentPostgreSQL
import Vapor
import MerkleModels

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    
    let db = Environment.get("POSTGRES_DB") ?? "merkleflow-test"
    let host = Environment.get("POSTGRES_HOST") ?? "postgres"
    let user = Environment.get("POSTGRES_USER") ?? "merkleflow"
    let pass = Environment.get("POSTGRES_PASSWORD") ?? "password"
    let port = Int(Environment.get("POSTGRES_PORT") ?? "5432") ?? 5432
    let pgsql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: host, port: port, username: user, database: db, password: pass))
    var databases = DatabasesConfig()
    databases.add(database: pgsql, as: .psql)
    services.register(databases)

	var migrations = MigrationConfig()
    migrations.add(model: FlowMessage256.self, database: .psql)
    services.register(migrations)
}
