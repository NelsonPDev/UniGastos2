//
//  SQLiteManager.swift
//  UniGastos2
//
//  Created by Alumno on 06/05/26.
//

import Foundation
import SQLite3

class SQLiteManager {
    static let shared = SQLiteManager()
    private var db: OpaquePointer?

    init() {
        openDatabase()
        createTables()
    }

    func openDatabase() {
        let fileURL = try! FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("gastos.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error al abrir la base de datos")
        } else {
            print("Base de datos abierta correctamente")
        }
    }

    func createTables() {
        let createUsuario = """
        CREATE TABLE IF NOT EXISTS usuario(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT
        );
        """

        let createGastos = """
        CREATE TABLE IF NOT EXISTS gastos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            concepto TEXT,
            cantidad DOUBLE,
            fecha DOUBLE
        );
        """

        let createIngresos = """
        CREATE TABLE IF NOT EXISTS ingresos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cantidad DOUBLE,
            fecha DOUBLE
        );
        """

        execute(query: createUsuario)
        execute(query: createGastos)
        execute(query: createIngresos)
    }

    func execute(query: String) {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        } else {
            print("Error en query: \(query)")
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - USUARIO
    func guardarUsuario(nombre: String) {

        // BORRA EL USUARIO ANTERIOR
        execute(query: "DELETE FROM usuario;")

        let query = "INSERT INTO usuario (nombre) VALUES (?);"

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            sqlite3_bind_text(stmt, 1, (nombre as NSString).utf8String, -1, nil)

            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func obtenerUsuario() -> String {
        let query = "SELECT nombre FROM usuario ORDER BY id DESC LIMIT 1;"
        var stmt: OpaquePointer?
        var nombre = ""

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                nombre = String(cString: sqlite3_column_text(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return nombre
    }

    // MARK: - GASTOS
    func insertarGasto(concepto: String, cantidad: Double, fecha: Date) {
        let query = "INSERT INTO gastos (concepto, cantidad, fecha) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (concepto as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 2, cantidad)
            sqlite3_bind_double(stmt, 3, fecha.timeIntervalSince1970)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func obtenerGastos() -> [Gasto] {

        var lista: [Gasto] = []

        let query = "SELECT id, concepto, cantidad, fecha FROM gastos;"

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            while sqlite3_step(stmt) == SQLITE_ROW {

                let id = Int(sqlite3_column_int(stmt, 0))

                let concepto = String(
                    cString: sqlite3_column_text(stmt, 1)
                )

                let cantidad = sqlite3_column_double(stmt, 2)

                let fecha = Date(
                    timeIntervalSince1970:
                        sqlite3_column_double(stmt, 3)
                )

                lista.append(
                    Gasto(
                        id: id,
                        fecha: fecha,
                        concepto: concepto,
                        cantidad: cantidad
                    )
                )
            }
        }

        sqlite3_finalize(stmt)

        return lista
    }
    
    func eliminarGasto(id: Int) {
        let query = "DELETE FROM gastos WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(id))
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func actualizarGasto(id: Int, concepto: String, cantidad: Double) {
        let query = "UPDATE gastos SET concepto = ?, cantidad = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            sqlite3_bind_text(stmt, 1, (concepto as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 2, cantidad)
            sqlite3_bind_int(stmt, 3, Int32(id))

            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - INGRESOS
    func insertarIngreso(cantidad: Double, fecha: Date) {
        let query = "INSERT INTO ingresos (cantidad, fecha) VALUES (?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_double(stmt, 1, cantidad)
            sqlite3_bind_double(stmt, 2, fecha.timeIntervalSince1970)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func obtenerIngresos() -> [Ingreso] {

        var lista: [Ingreso] = []

        let query = "SELECT id, cantidad, fecha FROM ingresos;"

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            while sqlite3_step(stmt) == SQLITE_ROW {

                let id = Int(sqlite3_column_int(stmt, 0))

                let cantidad = sqlite3_column_double(stmt, 1)

                let fecha = Date(
                    timeIntervalSince1970:
                        sqlite3_column_double(stmt, 2)
                )

                lista.append(
                    Ingreso(
                        id: id,
                        fecha: fecha,
                        cantidad: cantidad
                    )
                )
            }
        }

        sqlite3_finalize(stmt)

        return lista
    }
    
    func eliminarIngreso(id: Int) {

        let query = "DELETE FROM ingresos WHERE id = ?;"

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            sqlite3_bind_int(stmt, 1, Int32(id))

            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func actualizarIngreso(id: Int, cantidad: Double) {

        let query = "UPDATE ingresos SET cantidad = ? WHERE id = ?;"

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {

            sqlite3_bind_double(stmt, 1, cantidad)

            sqlite3_bind_int(stmt, 2, Int32(id))

            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }
    
}
