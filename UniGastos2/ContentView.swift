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

// MARK: - VISTA RAÍZ
struct ContentView: View {
    @State private var usuario: String = ""
    @State private var usuariosGuardados: [String] = []
    @State private var irHome = false
    @State var listaGastos: [Gasto] = []
    @State var listaIngresos: [Ingreso] = []
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 28/255, green: 19/255, blue: 63/255), Color(red: 101/255, green: 144/255, blue: 157/255)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    Spacer().frame(height: 30)
                    
                    // LOGO
                    Image("icono")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                    
                    // TÍTULO
                    Text("UniGastos")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer().frame(height: 20)
                    
                    // TARJETA LOGIN
                    VStack(spacing: 20) {
                        
                        Text("Registro")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Usuario")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        // TEXTFIELD
                        TextField("", text: $usuario)
                            .padding()
                            .frame(height: 65)
                            .foregroundStyle(Color.black)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(35)
                            .padding(.horizontal, 10)
                            .font(.system(size: 22))
                        
                        // BOTÓN
                        Button(action: {

                            if !usuario.isEmpty {

                                SQLiteManager.shared.crearUsuario(nombre: usuario)

                                SQLiteManager.shared.iniciarSesion(nombre: usuario)

                                irHome = true
                            }

                        }) {
                            Text("Crea Cuenta")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Cuentas guardadas")
                                .foregroundColor(.white)
                                .font(.headline)

                            ForEach(usuariosGuardados, id: \.self) { user in

                                Button {

                                    usuario = user

                                    SQLiteManager.shared.iniciarSesion(nombre: user)

                                    listaGastos = SQLiteManager.shared.obtenerGastos()

                                    listaIngresos = SQLiteManager.shared.obtenerIngresos()

                                    irHome = true

                                } label: {

                                    HStack {

                                        Image(systemName: "person.circle.fill")

                                        Text(user)

                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.top, 10)
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
            .navigationDestination(isPresented: $irHome) {
                HomeView(nombre: usuario, ingresos: $listaIngresos, gastos: $listaGastos)
            }
            // ON APPEAR AGREGADO
            .onAppear {

                usuariosGuardados = SQLiteManager.shared.obtenerUsuarios()

                usuario = SQLiteManager.shared.obtenerUsuarioActivo()

                if !usuario.isEmpty {

                    listaGastos = SQLiteManager.shared.obtenerGastos()

                    listaIngresos = SQLiteManager.shared.obtenerIngresos()

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
    @State private var refreshID = UUID()
    
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
        let _ = print("Usuario actual:", nombre)
        MainLayout(
            nombre: nombre,
            ingresos: $ingresos,
            gastos: $gastos
        ) {
            // TARJETA BALANCE
            VStack {
                Text("Saldo Actual:")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                
                Text("$\(String(format: "%.0f", balance))")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 35)
            .background(
                Color(red: 31/255, green: 18/255, blue: 84/255)
            )
            .cornerRadius(35)
            .padding(.top, 10)
            
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
                    .frame(height: 320)
                    .padding()
                    
                    VStack(spacing: 8) {
                        
                        Text("Ingreso \(String(format: "%.1f", (totalIngresos / total) * 100))%")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text("Gastos \(String(format: "%.1f", (totalGastos / total) * 100))%")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(.bottom)
                }
                else {
                    Text("Sin datos")
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
        .id(nombre)
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
    
    var body: some View {
        
        VStack {
            
            BalanceCard2(
                monto: String(format: "%.0f",
                              gastos.reduce(0){$0 + $1.cantidad})
            )
            
            VStack {
                
                if gastos.isEmpty {
                    
                    Text("Sin datos de gastos")
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
            .frame(height: 300)
            
            .padding(.horizontal)
            
            Button(action: {
                mostrarForm = true
            }) {
                
                AddButton(titulo: "Gasto")
            }
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

            EditarGastoView(gasto: gasto) {

                gastos = SQLiteManager.shared.obtenerGastos()
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
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    // TARJETA
                    VStack(spacing: 20) {

                        // SOLO MOSTRAR CONCEPTO EN GASTOS
                        if esGasto {

                            TextField("Concepto", text: $concepto)
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white.opacity(0.95))
                                .cornerRadius(18)
                                .font(.system(size: 20))
                        }

                        // MONTO
                        TextField("Cantidad", text: $monto)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(18)
                            .font(.system(size: 20))

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
                                .font(.system(size: 22, weight: .bold))
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
                                .font(.headline)
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
    @Environment(\.dismiss) var dismiss
    
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
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {

                        SQLiteManager.shared.cerrarSesion()

                        ingresos.removeAll()
                        gastos.removeAll()

                        dismiss()

                    } label: {

                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Image("icono")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color.orange)
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
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
                                .font(.system(size: 22, weight: .bold))
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
                                .font(.system(size: 22, weight: .bold))
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
                                .font(.system(size: 22, weight: .bold))
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
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    Color(red: 34/255, green: 24/255, blue: 82/255)
                )
                
                ScrollView(showsIndicators: false) {
                    
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
            }
        }
    }
}

struct BalanceCard: View {
    let monto: String
    var body: some View {
        Text("Ingreso Total: $\(monto)")
            .font(.largeTitle)
    }
}
struct BalanceCard2: View {
    let monto: String
    var body: some View {
        Text("Gasto Total: $\(monto)")
            .font(.largeTitle)
    }
}

struct HistorialRow: View {
    let titulo: String
    let monto: Double
    let fecha: Date
    
    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text("$\(monto, specifier: "%.0f")")
        }
    }
}

struct FilterButton: View {
    let text: String
    let activo: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
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
    
    var body: some View {
        
        VStack {
            
            BalanceCard(
                monto: String(format: "%.0f",
                              ingresos.reduce(0){$0 + $1.cantidad})
            )
            
            VStack {
                
                if ingresos.isEmpty {
                    
                    Text("Sin datos de ingresos")
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
            .frame(height: 300)
            
            .padding(.horizontal)
            
            Button(action: {
                mostrarForm = true
            }) {
                
                AddButton(titulo: "Ingreso")
            }
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

            EditarIngresoView(ingreso: ingreso) {

                ingresos = SQLiteManager.shared.obtenerIngresos()
            }
        }
    
    }
}

struct EditarGastoView: View {

    var gasto: Gasto
    var alActualizar: () -> Void

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

                    Text("Editar Gasto")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    TextField("Concepto", text: $concepto)
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)

                    TextField("Cantidad", text: $cantidad)
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

                            alActualizar()

                            dismiss()
                        }

                    } label: {

                        Text("Actualizar")
                            .font(.headline)
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
    var alActualizar: () -> Void

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
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    TextField("Cantidad", text: $cantidad)
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

                            alActualizar()

                            dismiss()
                        }

                    } label: {

                        Text("Actualizar")
                            .font(.headline)
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

