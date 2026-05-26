import SwiftUI
import Charts

// MARK: - MODELOS
struct Gasto: Identifiable {
    var id: Int
    var fecha: Date
    var concepto: String
    var cantidad: Double
}

struct Ingreso: Identifiable {
    var id: Int
    var fecha: Date
    var cantidad: Double
}

struct ContentView: View {

    @State private var tieneUsuario = false

    var body: some View {

        Group {

            if tieneUsuario {

                LoginView()

            } else {

                RegistroView()
            }
        }
        .onAppear {

            let usuario = SQLiteManager.shared.obtenerUsuario()

            tieneUsuario = !usuario.isEmpty
        }
    }
}

// MARK: - LOGIN VIEW
struct LoginView: View {

    @State private var usuario = ""
    @State private var mostrarError = false
    @State private var irHome = false

    @State var listaGastos: [Gasto] = []
    @State var listaIngresos: [Ingreso] = []

    var body: some View {

        NavigationStack {

            GeometryReader { geo in

                ZStack {

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 28/255, green: 19/255, blue: 63/255),
                            Color(red: 101/255, green: 144/255, blue: 157/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 25) {

                        Spacer()

                        Image("icono")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(geo.size.width * 0.4, 180),
                                height: min(geo.size.width * 0.4, 180)
                            )

                        Text("UniGastos")
                            .font(.system(size: 35, weight: .bold, design: .serif))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(1.5)

                        VStack(spacing: 20) {

                            Text("Iniciar Sesión")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .tracking(0.75)

                            // TEXTFIELD
                            TextField(
                                "",
                                text: $usuario,
                                prompt: Text("Usuario")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(.gray)
                            )
                            .padding()
                            .frame(height: 65)
                            .foregroundStyle(Color.black)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(35)
                            .padding(.horizontal, 10)
                            .font(.system(size: 22))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                            .onChange(of: usuario) { _, newValue in

                                let filtrado = newValue.filter { $0.isLetter }

                                usuario = String(filtrado.prefix(12))
                            }

                            Button {

                                let usuarioGuardado =
                                    SQLiteManager.shared.obtenerUsuario()

                                let nombreLimpio =
                                    usuario.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )

                                if nombreLimpio == usuarioGuardado {

                                    listaGastos =
                                        SQLiteManager.shared.obtenerGastos()

                                    listaIngresos =
                                        SQLiteManager.shared.obtenerIngresos()

                                    irHome = true

                                } else {

                                    mostrarError = true
                                }

                            } label: {

                                Text("Entrar")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(Color.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }

                        }
                        .padding(.vertical, 35)
                        .padding(.horizontal, 25)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 40/255, green: 42/255, blue: 92/255),
                                    Color(red: 58/255, green: 65/255, blue: 120/255)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(35)
                        .padding(.horizontal, 30)

                        Spacer()
                    }
                }
            }

            .alert("Error", isPresented: $mostrarError) {

                Button("OK", role: .cancel) { }

            } message: {

                Text("El usuario no coincide")
            }

            .navigationDestination(isPresented: $irHome) {

                HomeView(
                    nombre: usuario,
                    ingresos: $listaIngresos,
                    gastos: $listaGastos
                )
            }
        }
    }
}

// MARK: - VISTA Registro
struct RegistroView: View {
    @State private var usuario: String = ""
    @State private var irHome = false
    @State var listaGastos: [Gasto] = []
    @State var listaIngresos: [Ingreso] = []
    
    var body: some View {
        NavigationStack {

            GeometryReader { geo in

                ZStack {

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 28/255, green: 19/255, blue: 63/255),
                            Color(red: 101/255, green: 144/255, blue: 157/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 25) {

                        Spacer()

                        // LOGO
                        Image("icono")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(geo.size.width * 0.4, 180),
                                height: min(geo.size.width * 0.4, 180)
                            )

                        // TITULO
                        Text("UniGastos")
                            .font(.system(size: 35, weight: .bold, design: .serif))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(1.5)

                        // TARJETA LOGIN
                        VStack(spacing: 20) {
                            
                            Text("Registro")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .tracking(0.75)
                            
                            Text("Usuario")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .tracking(0.75)
                            
                            
                            // TEXTFIELD
                            TextField(
                                "",
                                text: $usuario,
                                prompt: Text("Usuario")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(.gray)
                            )
                                .padding()
                                .frame(height: 65)
                                .foregroundStyle(Color.black)
                                .background(Color.white.opacity(0.95))
                                .cornerRadius(35)
                                .padding(.horizontal, 10)
                                .font(.system(size: 22))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                                .onChange(of: usuario) { _, newValue in

                                    // SOLO LETRAS
                                    let filtrado = newValue.filter { $0.isLetter }

                                    // MAXIMO 12
                                    usuario = String(filtrado.prefix(12))
                                }

                            // BOTÓN
                            Button(action: {

                                let nombreLimpio = usuario.trimmingCharacters(in: .whitespacesAndNewlines)

                                // VALIDACIONES
                                if nombreLimpio.count >= 3 {

                                    SQLiteManager.shared.guardarUsuario(nombre: nombreLimpio)

                                    irHome = true
                                }

                            }) {

                                Text("Crea Cuenta")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(Color.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                        .padding(.vertical, 35)
                        .padding(.horizontal, 25)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 40/255, green: 42/255, blue: 92/255),
                                    Color(red: 58/255, green: 65/255, blue: 120/255)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(35)
                        .padding(.horizontal, 30)

                        Spacer()
                    }
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height
                    )
                }
            }
            .navigationDestination(isPresented: $irHome) {

                HomeView(
                    nombre: usuario,
                    ingresos: $listaIngresos,
                    gastos: $listaGastos
                )
            }

            .onAppear {

                usuario = SQLiteManager.shared.obtenerUsuario()

                listaGastos = SQLiteManager.shared.obtenerGastos()

                listaIngresos = SQLiteManager.shared.obtenerIngresos()

                if !usuario.isEmpty {

                    irHome = true
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - HOME VIEW
struct HomeView: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var filtroSeleccionado = "Mes"
    
    var safeProgress: Double {
        let value = abs(balance)
        
        if !value.isFinite {
            return 0.01
        }
        
        // normaliza entre 0 y 1
        let normalized = min(value / 1000, 1.0)
        
        return max(0.01, normalized)
    }
    
    var ingresosFiltrados: [Ingreso] {
        ingresos.filter { filtrarPorTiempo(fecha: $0.fecha, periodo: filtroSeleccionado) }
    }
    var gastosFiltrados: [Gasto] {
        gastos.filter { filtrarPorTiempo(fecha: $0.fecha, periodo: filtroSeleccionado) }
    }
    var balance: Double {
        let totalIngresos = ingresosFiltrados.reduce(0){$0 + $1.cantidad}
        let totalGastos = gastosFiltrados.reduce(0){$0 + $1.cantidad}
        
        let resultado = totalIngresos - totalGastos
        
        if resultado.isNaN || resultado.isInfinite {
            return 0
        }
        
        return resultado
    }
    
    var body: some View {
        MainLayout(nombre: nombre, ingresos: $ingresos, gastos: $gastos) {
            
            // TARJETA BALANCE
            VStack(spacing: 8) {

                Text("Saldo Actual")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("$\(String(format: "%.0f", balance))")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(
                Color(red: 31/255, green: 18/255, blue: 84/255)
            )
            .cornerRadius(25)
            .padding(.top, 6)
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 20)
            
            // GRÁFICA
            VStack {
                
                let totalIngresos = ingresosFiltrados.reduce(0) { $0 + $1.cantidad }
                let totalGastos = gastosFiltrados.reduce(0) { $0 + $1.cantidad }
                let total = totalIngresos + totalGastos
                
                if total > 0 {
                    
                    Chart {
                        SectorMark(
                            angle: .value("Cantidad", totalIngresos),
                            innerRadius: .ratio(0.0),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.blue)
                        
                        SectorMark(
                            angle: .value("Cantidad", totalGastos),
                            innerRadius: .ratio(0.0),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.purple.opacity(0.7))
                    }
                    .frame(height: 190)
                    .padding(.top, 10)
                    
                    VStack(spacing: 8) {
                        
                        Text("Ingreso \(String(format: "%.1f", (totalIngresos / total) * 100))%")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text("Gastos \(String(format: "%.1f", (totalGastos / total) * 100))%")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(.bottom)
                }
                else {
                    Text("Sin datos")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(height: 320)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 52/255, green: 57/255, blue: 110/255),
                        Color(red: 82/255, green: 101/255, blue: 128/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(35)
            .padding(.horizontal, 20)
            
            // BOTONES FILTRO
            HStack(spacing: 0) {
                
                FilterButton(
                    text: "Dia",
                    activo: filtroSeleccionado == "Día"
                ) {
                    filtroSeleccionado = "Día"
                }
                
                FilterButton(
                    text: "Semana",
                    activo: filtroSeleccionado == "Semana"
                ) {
                    filtroSeleccionado = "Semana"
                }
                
                FilterButton(
                    text: "Mes",
                    activo: filtroSeleccionado == "Mes"
                ) {
                    filtroSeleccionado = "Mes"
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - GASTOS VIEW
struct GastosView: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var mostrarForm = false
    @State private var gastoEditar: Gasto?
    @State private var mostrarEditar = false
    @State private var mostrarAlertaEliminar = false
    @State private var gastoAEliminar: Gasto?
    @State private var mostrarMensaje = false
    @State private var mensaje = ""
    
    var body: some View {
        
        VStack {
            
            BalanceCard2(
                monto: String(format: "%.0f",
                              gastos.reduce(0){$0 + $1.cantidad})
            )
            
            VStack {
                
                if gastos.isEmpty {
                    
                    Text("Sin datos de gastos")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(height: 200)
                    
                } else {
                    
                    let datos = gastos.filter {
                        $0.cantidad.isFinite && !$0.cantidad.isNaN
                    }
                    
                    Chart(datos) { item in
                        
                        LineMark(
                            x: .value("Fecha", item.fecha),
                            y: .value("Monto", item.cantidad)
                        )
                        
                        PointMark(
                            x: .value("Fecha", item.fecha),
                            y: .value("Monto", item.cantidad)
                        )
                    }
                    .frame(height: 200)
                    .padding()
                }
            }
            .background(Color.black.opacity(0.3))
            .cornerRadius(25)
            .padding(.horizontal)
            
            List {

                ForEach(gastos.reversed()) { g in

                    HistorialRow(
                        titulo: g.concepto,
                        monto: -g.cantidad,
                        fecha: g.fecha
                    )
                    .listRowBackground(Color.clear)

                    .swipeActions {

                        Button {

                            gastoEditar = g
                            //mostrarEditar = true

                        } label: {

                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.yellow)

                        Button(role: .destructive) {

                            gastoAEliminar = g
                            mostrarAlertaEliminar = true

                        } label: {

                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                    
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(maxHeight: 300)
            
            .padding(.horizontal)
            
            Button(action: {
                mostrarForm = true
            }) {
                
                AddButton(titulo: "Gasto")
            }
        }
        .alert("Éxito", isPresented: $mostrarMensaje) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mensaje)
        }
        .sheet(isPresented: $mostrarForm) {
            
            FormularioPro(
                titulo: "Nuevo Gasto",
                esGasto: true
            ) { c, m in
                
                SQLiteManager.shared.insertarGasto(
                    concepto: c,
                    cantidad: m,
                    fecha: Date()
                )

                gastos = SQLiteManager.shared.obtenerGastos()
                mensaje = "Gasto agregado correctamente"
                mostrarMensaje = true
            }
            .navigationBarBackButtonHidden(true)
        }
        
        .alert("Eliminar gasto", isPresented: $mostrarAlertaEliminar) {

            Button("Cancelar", role: .cancel) { }

            Button("Eliminar", role: .destructive) {

                if let gasto = gastoAEliminar {

                    SQLiteManager.shared.eliminarGasto(id: gasto.id)

                    gastos = SQLiteManager.shared.obtenerGastos()
                }

            }

        } message: {

            Text("¿Seguro que deseas eliminar este gasto?")
        }
        
        .sheet(item: $gastoEditar) { gasto in
            EditarGastoView(gasto: gasto) { mensaje in
                gastos = SQLiteManager.shared.obtenerGastos()
                self.mensaje = mensaje
                mostrarMensaje = true
            }
        }
        
    
    }
}

// MARK: - FORMULARIO MODERNO
struct FormularioPro: View {

    let titulo: String
    let esGasto: Bool
    var alGuardar: (String, Double) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var concepto = ""
    @State private var monto = ""

    var body: some View {

        NavigationStack {

            ZStack {

                // FONDO
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 28/255, green: 19/255, blue: 63/255),
                        Color(red: 120/255, green: 170/255, blue: 185/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {

                    Spacer()

                    // TITULO
                    Text(titulo)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    // TARJETA
                    VStack(spacing: 20) {

                        // SOLO MOSTRAR CONCEPTO EN GASTOS
                        if esGasto {

                            TextField(
                                "",
                                text: $concepto,
                                prompt: Text("Concepto")
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                    .foregroundColor(.gray)
                            )
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white.opacity(0.95))
                                .cornerRadius(18)
                                .fuenteUniGastos(size: 20)                        }

                        // MONTO
                        TextField(
                            "",
                            text: $monto,
                            prompt: Text("$ Monto")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.gray)
                        )
                            .keyboardType(.decimalPad)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(18)
                            .fuenteUniGastos(size: 20)

                        // BOTON GUARDAR
                        Button {

                            if let m = Double(monto),
                               m.isFinite,
                               m > 0 {

                                let texto = concepto.isEmpty
                                ? "Ingreso"
                                : concepto

                                alGuardar(texto, m)

                                dismiss()
                            }

                        } label: {

                            Text("Guardar")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(18)
                        }

                        // CANCELAR
                        Button {

                            dismiss()

                        } label: {

                            Text("Cancelar")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(25)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(30)
                    .padding(.horizontal, 25)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - COMPONENTES
struct MainLayout<Content: View>: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var vistaActiva: String = "Resumen"
    @State private var mostrarEquipo = false
    
    let content: () -> Content
    
    init(
        nombre: String,
        ingresos: Binding<[Ingreso]>,
        gastos: Binding<[Gasto]>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.nombre = nombre
        self._ingresos = ingresos
        self._gastos = gastos
        self.content = content
    }
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 28/255, green: 19/255, blue: 63/255),
                    Color(red: 120/255, green: 170/255, blue: 185/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // HEADER
                HStack {
                    
                    Text("Hola, \(nombre)")
                        .fuenteUniGastos(size: 34)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        mostrarEquipo = true
                    } label: {

                        Image("icono")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                    }
                        
                }
                .padding(.horizontal, 22)
                .padding(.top, 0)
                .padding(.bottom, 18)
                .background(
                    Color(red: 30/255, green: 15/255, blue: 72/255)
                )
                
                // TABS
                HStack {
                    
                    Button(action: {
                        vistaActiva = "Ingresos"
                    }) {
                        
                        VStack(spacing: 6) {
                            
                            Text("Ingresos")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white.opacity(
                                    vistaActiva == "Ingresos" ? 1 : 0.7
                                ))
                            
                            Rectangle()
                                .fill(vistaActiva == "Ingresos"
                                      ? Color.white
                                      : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(5)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        vistaActiva = "Resumen"
                    }) {
                        
                        VStack(spacing: 6) {
                            
                            Text("Resumen")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white.opacity(
                                    vistaActiva == "Resumen" ? 1 : 0.7
                                ))
                            
                            Rectangle()
                                .fill(vistaActiva == "Resumen"
                                      ? Color.white
                                      : Color.clear)
                                .frame(width: 95, height: 3)
                                .cornerRadius(5)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        vistaActiva = "Gastos"
                    }) {
                        
                        VStack(spacing: 6) {
                            
                            Text("Gastos")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white.opacity(
                                    vistaActiva == "Gastos" ? 1 : 0.7
                                ))
                            
                            Rectangle()
                                .fill(vistaActiva == "Gastos"
                                      ? Color.white
                                      : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(5)
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    Color(red: 34/255, green: 24/255, blue: 82/255)
                )
                
                VStack {

                    switch vistaActiva {
                            
                        case "Ingresos":
                            
                            IngresosView(
                                nombre: nombre,
                                ingresos: $ingresos,
                                gastos: $gastos
                            )
                            
                        case "Gastos":
                            
                            GastosView(
                                nombre: nombre,
                                ingresos: $ingresos,
                                gastos: $gastos
                            )
                            
                        default:
                            
                            content()
                        }
                    }
                    .padding(.bottom, 20)
                }
            .frame(maxHeight: .infinity, alignment: .top)
            }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $mostrarEquipo) {

            EquipoView()
        }
        }
    }


struct BalanceCard: View {
    let monto: String
    var body: some View {
        Text("Ingreso Total: $\(monto)")
            .font(.system(size: 35, weight: .bold, design: .serif))
            .fontWeight(.heavy)
            .foregroundColor(.white)
            .tracking(1.5)
    }
}
struct BalanceCard2: View {
    let monto: String
    var body: some View {
        Text("Gasto Total: $\(monto)")
            .font(.system(size: 35, weight: .bold, design: .serif))
            .fontWeight(.heavy)
            .foregroundColor(.white)
            .tracking(1.5)
    }
}

struct HistorialRow: View {
    let titulo: String
    let monto: Double
    let fecha: Date
    
    var body: some View {
        
        HStack {
            
            Text(titulo)
                .fuenteUniGastos(size: 22)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("$\(monto, specifier: "%.0f")")
                .fuenteUniGastos(size: 22)
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
    }
}

struct FilterButton: View {
    let text: String
    let activo: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .fuenteUniGastos()
                .padding()
                .background(activo ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct AddButton: View {
    let titulo: String
    
    var body: some View {
        Text("Añadir \(titulo)")
            .font(.system(size: 22, weight: .bold, design: .serif))
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// MARK: - FUNCIÓN
func filtrarPorTiempo(fecha: Date, periodo: String) -> Bool {
    let cal = Calendar.current
    
    if periodo == "Día" {
        return cal.isDateInToday(fecha)
    }
    if periodo == "Semana" {
        return cal.isDate(fecha, equalTo: Date(), toGranularity: .weekOfYear)
    }
    return cal.isDate(fecha, equalTo: Date(), toGranularity: .month)
}

// MARK: - INGRESOS VIEW
struct IngresosView: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var mostrarForm = false
    @State private var ingresoEditar: Ingreso?
    @State private var mostrarAlertaEliminar = false
    @State private var ingresoAEliminar: Ingreso?
    @State private var mostrarMensaje = false
    @State private var mensaje = ""
    
    var body: some View {
        
        VStack {
            
            BalanceCard(
                monto: String(format: "%.0f",
                              ingresos.reduce(0){$0 + $1.cantidad})
            )
            
            VStack {
                
                if ingresos.isEmpty {
                    
                    Text("Sin datos de ingresos")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(height: 200)
                    
                } else {
                    
                    let datos = ingresos.filter {
                        $0.cantidad.isFinite && !$0.cantidad.isNaN
                    }
                    
                    Chart(datos) { item in
                        
                        LineMark(
                            x: .value("Fecha", item.fecha),
                            y: .value("Monto", item.cantidad)
                        )
                        
                        PointMark(
                            x: .value("Fecha", item.fecha),
                            y: .value("Monto", item.cantidad)
                        )
                    }
                    .fuenteUniGastos(size: 10)
                    .frame(height: 200)
                    .padding()
                }
            }
            .background(Color.black.opacity(0.3))
            .cornerRadius(25)
            .padding(.horizontal)
            
            List {

                ForEach(ingresos.reversed()) { i in

                    HistorialRow(
                        titulo: "Ingreso",
                        monto: i.cantidad,
                        fecha: i.fecha
                    )
                    .listRowBackground(Color.clear)

                    .swipeActions {

                        Button {

                            ingresoEditar = i
                            //mostrarEditar = true

                        } label: {

                            Label("Editar", systemImage: "pencil")
                        }
                            .tint(.yellow)

                        Button(role: .destructive) {

                            ingresoAEliminar = i
                            mostrarAlertaEliminar = true

                        } label: {

                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(maxHeight: 300)
            
            .padding(.horizontal)
            
            Button(action: {
                mostrarForm = true
            }) {
                
                AddButton(titulo: "Ingreso")
                
            }
        }
        .alert("Éxito", isPresented: $mostrarMensaje) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mensaje)
        }
        .sheet(isPresented: $mostrarForm) {
            
            FormularioPro(
                titulo: "Nuevo Ingreso",
                esGasto: false
            ) { _, m in
                
                SQLiteManager.shared.insertarIngreso(
                    cantidad: m,
                    fecha: Date()
                )

                ingresos = SQLiteManager.shared.obtenerIngresos()
                mensaje = "Ingreso agregado correctamente"
                mostrarMensaje = true
            }
            .navigationBarBackButtonHidden(true)
        }
        
        .alert("Eliminar ingreso", isPresented: $mostrarAlertaEliminar) {

            Button("Cancelar", role: .cancel) { }

            Button("Eliminar", role: .destructive) {

                if let ingreso = ingresoAEliminar {

                    SQLiteManager.shared.eliminarIngreso(id: ingreso.id)

                    ingresos = SQLiteManager.shared.obtenerIngresos()
                }

            }

        } message: {

            Text("¿Seguro que deseas eliminar este ingreso?")
        }
        
        .sheet(item: $ingresoEditar) { ingreso in
            EditarIngresoView(ingreso: ingreso) { mensaje in
                ingresos = SQLiteManager.shared.obtenerIngresos()
                self.mensaje = mensaje
                mostrarMensaje = true
            }
        }
    }
}

struct EditarGastoView: View {

    var gasto: Gasto
    var alActualizar: (String) -> Void
    
    

    @Environment(\.dismiss) var dismiss

    @State private var concepto: String = ""
    @State private var cantidad: String = ""

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 28/255, green: 19/255, blue: 63/255),
                        Color(red: 120/255, green: 170/255, blue: 185/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {
// correcion de titulos y letras
                    Text("Editar Gasto")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .bold()
                        .foregroundColor(.white)

                    TextField(
                        "",
                        text: $concepto,
                        prompt: Text("Concepto")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                    )
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)

                    TextField(
                        "",
                        text: $cantidad,
                        prompt: Text("$ Monto")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                    )
                        .foregroundStyle(.black)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)

                    Button {

                        if let monto = Double(cantidad) {

                            SQLiteManager.shared.actualizarGasto(
                                id: gasto.id,
                                concepto: concepto,
                                cantidad: monto
                            )

                            alActualizar("Gasto modificado correctamente")
                            dismiss()
                        }

                    } label: {

                        Text("Actualizar")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }

                    Button {

                        dismiss()

                    } label: {

                        Text("Cancelar")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .onAppear {

            concepto = gasto.concepto
            cantidad = String(gasto.cantidad)
        }
    }
}

struct EditarIngresoView: View {

    var ingreso: Ingreso
    var alActualizar: (String) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var cantidad: String = ""

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 28/255, green: 19/255, blue: 63/255),
                        Color(red: 120/255, green: 170/255, blue: 185/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {

                    Text("Editar Ingreso")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .bold()
                        .foregroundColor(.white)

                    TextField(
                        "",
                        text: $cantidad,
                        prompt: Text("$ Monto")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                    )
                        .foregroundStyle(.black)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)

                    Button {

                        if let monto = Double(cantidad) {

                            SQLiteManager.shared.actualizarIngreso(
                                id: ingreso.id,
                                cantidad: monto
                            )

                            alActualizar("Ingreso modificado correctamente")
                            dismiss()
                        }

                    } label: {

                        Text("Actualizar")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }

                    Button {

                        dismiss()

                    } label: {

                        Text("Cancelar")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .onAppear {

            cantidad = String(ingreso.cantidad)
        }
    }
}

struct EquipoView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {

        ZStack {

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 28/255, green: 19/255, blue: 63/255),
                    Color(red: 120/255, green: 170/255, blue: 185/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                Text("Integrantes del equipo")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                VStack(spacing: 15) {

                    Text("• Jose Adrian Liy García")
                    Text("• Nelson Enrique Pérez Juan")

                }
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.white)

                Button {

                    dismiss()

                } label: {

                    Text("Cerrar")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                }
            }
            .padding()
        }
    }
}
extension View {

    func fuenteUniGastos(size: CGFloat = 22) -> some View {

        self.font(
            .system(
                size: size,
                weight: .bold,
                design: .serif
            )
        )
    }
}
