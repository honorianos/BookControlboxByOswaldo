//
//  Book.swift
//  BookControlbox
//
//  Created by Oswaldo Escobar on 28/07/24.
//


import Foundation

// MARK: - Book
struct Book: Codable {
    let libros: [Libros]
}

// MARK: - Libros
struct Libros: Codable {
    let autor: String
    var comentarios: [Comentarios]?
    let foto: String
    let nombre: String
    let valoraciones: Double
    let categoria: String
    var id =  String()
}

// MARK: - Comentarios
struct Comentarios: Codable {
    let comentario, fecha, idUsuario: String
    let valoracion: Double
}
