import Cocoa

// Estructura que define un cliente
struct Client: Equatable {
    private let name: String
    private let age: Int
    private let heightInCm: Int
    
    init(name: String, age: Int, heightInCm: Int) {
        self.name = name
        self.age = age
        self.heightInCm = heightInCm
    }
}

// Estructura para crear una reserva
struct Reservation {
    private static var contador = 0
    var idUnic: Int
    let hotelName: String
    let clients: [Client]
    let duration: Int
    let price: Double
    let breakfast: Bool
    
    init(hotelName: String, clients: [Client], duration: Int, price: Double, breakfast: Bool) {
        Reservation.contador += 1
        self.idUnic = Reservation.contador
        self.hotelName = hotelName
        self.clients = clients
        self.duration = duration
        self.price = price
        self.breakfast = breakfast
    }
}

// Enum para la gestión de errores
enum ReservationError: Error {
    case error1
    case error2
    case error3
    case error4
}

// Clase para la gestión de las reservas
class HotelReservationManager {
    private let breakfastIncrease = 1.25
    var bookings: [Reservation] = []
    var listIds: Set<Int> = []
    var listClients: [Client] = []
    
    
    // Método para calcular el precio total de una reserva
    private func calculatePrice(numberClients: Int, numberDays: Int, priceBase: Double, optionalBreakfast: Bool) -> Double{
        return Double(numberClients * numberDays) * (priceBase * (optionalBreakfast ? breakfastIncrease:1))
    }
    
    // Método para añadir una nueva reserva
    func addReservation(hotelName: String, clients: [Client], duration: Int, price: Double, breakfast: Bool) throws -> Reservation {
        
        // Precio total de una reserva
        let totalPrice = calculatePrice(
            numberClients: clients.count,
            numberDays: duration,
            priceBase: price,
            optionalBreakfast: breakfast)
        
        // Creación de una nueva reserva
        let newReservation = Reservation(
            hotelName: hotelName,
            clients: clients,
            duration: duration,
            price: totalPrice,
            breakfast: breakfast)
        
        // Comprobar entrada de parámetros
        guard !(hotelName == "" || clients.isEmpty || duration < 1 || price < 0) else {
            throw ReservationError.error4
        }
        // Comprobar id único
        guard !listIds.contains(newReservation.idUnic) else {
            throw ReservationError.error1
        }
        // Comprobar que los clientes no tienen una reserva anterior asignada
        guard !clients.contains(where: {listClients.contains($0)}) else {
            throw ReservationError.error2
        }
        // Actualizar lista ids, clientes y añadir reserva al listado
        listClients += clients
        listIds.insert(newReservation.idUnic)
        bookings.append(newReservation)
        return newReservation
    }
    
    // Método para borrar una reserva del sistema
    func cancelBoking(id: Int) throws {
        
        // Comprobar id único
        guard listIds.contains(id) else {
            throw ReservationError.error3
        }
        // Eliminar id y reserva, además compone un listado nuevo con todos los clientes una vez borrada la reserva
        listIds.remove(id)
        bookings.removeAll { booking in
            return booking.idUnic == id
        }
        listClients = bookings.flatMap { reservation in
            return reservation.clients}
    }
        
    // Método de visualización para las reservas
    var viewAllReservation: [String] {
        var listReservation: [String] = []
        for reservation in bookings {
            listReservation.append("Reserva Nº\(reservation.idUnic), Nombre Hotel: \(reservation.hotelName), Nº Clientes: \(reservation.clients.count), duración: \(reservation.duration), Opcion desayuno \(reservation.breakfast), Precio \(reservation.price)")
        }
        return listReservation
    }
    
    // Método que devuelve el listado de reservas en bruto
    var seeAllRawReservations: [Reservation] {
        return bookings
    }
        
}

//***********************************//
//************* TEST ****************//
//***********************************//

let client1 = Client(name: "Goku", age: 41, heightInCm: 175)
let client2 = Client(name: "Chi-Chi", age: 43, heightInCm: 163)
let client3 = Client(name: "Goten", age: 11, heightInCm: 123)
let client4 = Client(name: "Krilin", age: 41, heightInCm: 156)
let client5 = Client(name: "Bulma", age: 45, heightInCm: 165)
let client6 = Client(name: "Vegeta", age: 46, heightInCm: 164)
let client7 = Client(name: "Yamcha", age: 47, heightInCm: 183)
let client8 = Client(name: "Piccolo", age: 31, heightInCm: 226)
let client9 = Client(name: "Videl", age: 27, heightInCm: 157)
let client10 = Client(name: "Trunks", age: 31, heightInCm: 170)
let client11 = Client(name: "Mr Satan", age: 44, heightInCm: 188)


let reservationManager = HotelReservationManager()

// Test cliente ya con una reserva asignada
func testAddReservation() {
    
    print("🟡 Test cliente ya con reserva 🟡")
    let clients = [client1, client2]
    let clients1 = [client3, client4, client2]

    do {
        try reservationManager.addReservation(hotelName: "Luchadores", clients: clients, duration: 2, price: 25, breakfast: true)
        print("Realizo una reserva")
        print("Intento repetir cliente en la siguiente reserva")
        try reservationManager.addReservation(hotelName: "Luchadores", clients: clients1, duration: 2, price: 25, breakfast: true)
    }catch ReservationError.error1 {
        print("Error ID ya con una reserva")
    }catch ReservationError.error2 {
        print("Error cliente ya con una reserva")
    }catch ReservationError.error3{
        print("Error eserva no existe")
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
}

testAddReservation()

// Test error cancelar reserva inexistente
func testCancelRservation() {
    print("🟡 Test cancelar reserva y cancelar reserva inexistente 🟡")
    
    do {
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client5], duration: 5, price: 20.50, breakfast: false)
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client6], duration: 3, price: 20.50, breakfast: true)
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client7], duration: 1, price: 20.50, breakfast: false)
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client8], duration: 20, price: 20.50, breakfast: true)

        print("Creo 4 reservas")
        print("Numero de reservas \(reservationManager.listIds)")
        try reservationManager.cancelBoking(id: 3)
        print("Borro reserva con el id 3")
        print("Numero de reservas \(reservationManager.listIds)")
        print("Intento borrar reserva 10 inexistente")
        try reservationManager.cancelBoking(id: 10)
        
    }catch ReservationError.error1 {
        print("Error ID ya con una reserva")
    }catch ReservationError.error2 {
        print("Error cliente ya con una reserva")
    }catch ReservationError.error3{
        print("Error eserva no existe")
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
}
testCancelRservation()

// Test calculo de precio por reserva
func testReservationPrice() {
    print("🟡 Test para comprobar que el método para calcular el precio total de reserva siempre devuelve igual 🟡")
    
    do {
        print("Realizo 2 reservas con las mismas condiciones")
        let reserva1 = try reservationManager.addReservation(hotelName: "Luchadores", clients: [client9], duration: 5, price: 20.50, breakfast: true)
        let reserva2 = try reservationManager.addReservation(hotelName: "Luchadores", clients: [client10], duration: 5, price: 20.50, breakfast: true)
        print("Resultado del precio de cada reserva Reserva1: \(reserva1.price) Reserva2: \(reserva2.price)")
        print("Comparo los resultado y si son distintos lanzamos una excepción")
        let listPriceReservation = Set(reservationManager.bookings.map {$0.price})
        // Lanzamos excepción si los precios son distintos
        assert(reserva1.price == reserva2.price, "Error en el calculo del precio final por reserva")
        
    }catch ReservationError.error1 {
        print("Error ID ya con una reserva")
    }catch ReservationError.error2 {
        print("Error cliente ya con una reserva")
    }catch ReservationError.error3{
        print("Error eserva no existe")
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
}
testReservationPrice()

func testParameterEntryError() {
    print("🟡 Test para comprobar la entrade de parámetros de una nueva reserva 🟡")
    
    do {
        print("Realizo reserva con parámetros erroneos")
        try reservationManager.addReservation(hotelName: "", clients: [client11], duration: 5, price: 20.50, breakfast: true)
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
    do {
        print("Realizo reservas con parámetros erroneos")
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [], duration: 5, price: 20.50, breakfast: true)
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
    do {
        print("Realizo reservas con parámetros erroneos")
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client11], duration: -5, price: 20.50, breakfast: true)
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
    do {
        print("Realizo reservas con parámetros erroneos")
        try reservationManager.addReservation(hotelName: "Luchadores", clients: [client11], duration: 5, price: -20.50, breakfast: true)
    }catch ReservationError.error4{
        print("Error entrada de parámetros")
    }catch{
        print("Error inexperado")
    }
}

testParameterEntryError()

// Test para comprobar el método que devuelve todas las reservas
func testSeeActiveReservations () {
    print("🟡 Test para comprobar todas las reservas 🟡")
    reservationManager.seeAllRawReservations
    let reservas = reservationManager.viewAllReservation
    for reserva in reservas {
        print(reserva)
    }
}
testSeeActiveReservations()





