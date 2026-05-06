import SwiftUI
import Charts

// MARK: - MODELOS
struct Gasto: Identifiable {
    let id = UUID()
    var fecha: Date
    var concepto: String
    var cantidad: Double
}

struct Ingreso: Identifiable {
    let id = UUID()
    var fecha: Date
    var cantidad: Double
}

// MARK: - VISTA RAÍZ
struct ContentView: View {
    @State private var usuario: String = ""
    @State private var irHome = false
    @State var listaGastos: [Gasto] = []
    @State var listaIngresos: [Ingreso] = []
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 28/255, green: 19/255, blue: 63/255), Color(red: 101/255, green: 144/255, blue: 157/255)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)
                    Image("icono").resizable().scaledToFit().frame(width: 180, height: 180)
                    Text("UniGastos").font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        Text("Registro").font(.system(size: 26, weight: .medium)).foregroundColor(.white)
                        
                        TextField("Usuario", text: $usuario)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(25)
                            .padding(.horizontal, 10)
                        
                        // BOTÓN CORREGIDO
                        Button(action: {
                            if !usuario.isEmpty {
                                SQLiteManager.shared.guardarUsuario(nombre: usuario)
                                irHome = true
                            }
                        }) {
                            Text("Entrar")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                    }
                    .padding()
                    .background(Color(red: 40/255, green: 45/255, blue: 85/255))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $irHome) {
                HomeView(nombre: usuario, ingresos: $listaIngresos, gastos: $listaGastos)
            }
            // ON APPEAR AGREGADO
            .onAppear {
                usuario = SQLiteManager.shared.obtenerUsuario()
                listaGastos = SQLiteManager.shared.obtenerGastos()
                listaIngresos = SQLiteManager.shared.obtenerIngresos()
            }
        }
    }
}

// MARK: - HOME VIEW
struct HomeView: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var filtroSeleccionado = "Mes"
    
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
        MainLayout(nombre: nombre, vistaActiva: "Resumen", ingresos: $ingresos, gastos: $gastos) {
            BalanceCard(monto: String(format: "%.0f", balance))
            
            ZStack {
                RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.3)).frame(height: 250)
                VStack {
                    Circle()
                        .trim(from: 0, to: max(0.01, min(0.7, abs(balance))))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .frame(width: 150, height: 150).rotationEffect(.degrees(-90))
                    Text("Resumen \(filtroSeleccionado)").foregroundColor(.white).font(.headline).padding(.top)
                }
            }.padding(.horizontal)
            
            HStack(spacing: 15) {
                FilterButton(text: "Día", activo: filtroSeleccionado == "Día") { filtroSeleccionado = "Día" }
                FilterButton(text: "Semana", activo: filtroSeleccionado == "Semana") { filtroSeleccionado = "Semana" }
                FilterButton(text: "Mes", activo: filtroSeleccionado == "Mes") { filtroSeleccionado = "Mes" }
            }.padding()

            VStack(alignment: .leading) {
                Text("HISTORIAL RECIENTE").font(.caption).bold().foregroundColor(.white.opacity(0.6)).padding(.leading)
                ForEach(gastosFiltrados.suffix(3)) { g in HistorialRow(titulo: g.concepto, monto: -g.cantidad, fecha: g.fecha) }
                ForEach(ingresosFiltrados.suffix(3)) { i in HistorialRow(titulo: "Ingreso", monto: i.cantidad, fecha: i.fecha) }
            }.padding(.horizontal)
        }
    }
}

// MARK: - GASTOS VIEW
struct GastosView: View {
    let nombre: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    @State private var mostrarForm = false
    
    var body: some View {
        MainLayout(nombre: nombre, vistaActiva: "Gastos", ingresos: $ingresos, gastos: $gastos) {
            BalanceCard(monto: String(format: "%.0f", gastos.reduce(0){$0 + $1.cantidad}))
            
            VStack {
                if gastos.isEmpty {
                    Text("Sin datos de gastos").foregroundColor(.white.opacity(0.5)).frame(height: 200)
                } else {
                    Chart(gastos) { item in
                        LineMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                        PointMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                    }
                    .frame(height: 200).padding()
                }
            }.background(Color.black.opacity(0.3)).cornerRadius(25).padding(.horizontal)
            
            VStack {
                ForEach(gastos.reversed()) { g in
                    HistorialRow(titulo: g.concepto, monto: -g.cantidad, fecha: g.fecha)
                }
            }.padding(.horizontal)
            
            Button(action: { mostrarForm = true }) {
                AddButton(titulo: "Gasto")
            }
        }
        // SHEET MODIFICADO
        .sheet(isPresented: $mostrarForm) {
            FormularioPro(titulo: "Nuevo Gasto", esGasto: true) { c, m in
                let nuevo = Gasto(fecha: Date(), concepto: c, cantidad: m)
                gastos.append(nuevo)
                SQLiteManager.shared.insertarGasto(concepto: c, cantidad: m, fecha: Date())
            }
        }
    }
}

// MARK: - FORMULARIO
struct FormularioPro: View {
    let titulo: String
    let esGasto: Bool
    var alGuardar: (String, Double) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var concepto = ""
    @State private var monto = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(titulo).font(.title).bold()
            
            TextField("Descripción", text: $concepto)
                .textFieldStyle(.roundedBorder)
            
            TextField("Cantidad", text: $monto)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            
            Button("Guardar") {
                if let m = Double(monto), !concepto.isEmpty {
                    alGuardar(concepto, m)
                    dismiss()
                }
            }
        }
        .padding()
    }
}

// MARK: - COMPONENTES
struct MainLayout<Content: View>: View {
    let nombre: String
    let vistaActiva: String
    @Binding var ingresos: [Ingreso]
    @Binding var gastos: [Gasto]
    let content: Content
    
    init(nombre: String, vistaActiva: String, ingresos: Binding<[Ingreso]>, gastos: Binding<[Gasto]>, @ViewBuilder content: () -> Content) {
        self.nombre = nombre
        self.vistaActiva = vistaActiva
        self._ingresos = ingresos
        self._gastos = gastos
        self.content = content()
    }
    
    var body: some View {
        VStack {
            // HEADER
            Text("Hola, \(nombre)")
                .font(.title)
            
            // NAVBAR
            HStack {
                NavigationLink("Ingresos") {
                    IngresosView(nombre: nombre, ingresos: $ingresos, gastos: $gastos)
                }
                
                Spacer()
                
                NavigationLink("Resumen") {
                    HomeView(nombre: nombre, ingresos: $ingresos, gastos: $gastos)
                }
                
                Spacer()
                
                NavigationLink("Gastos") {
                    GastosView(nombre: nombre, ingresos: $ingresos, gastos: $gastos)
                }
            }
            .padding()
            
            Divider()
            
            // CONTENIDO
            content
        }
    }
}

struct BalanceCard: View {
    let monto: String
    var body: some View {
        Text("Balance: $\(monto)")
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
    
    var body: some View {
        MainLayout(nombre: nombre, vistaActiva: "Ingresos", ingresos: $ingresos, gastos: $gastos) {
            BalanceCard(monto: String(format: "%.0f", ingresos.reduce(0){$0 + $1.cantidad}))
            
            VStack {
                if ingresos.isEmpty {
                    Text("Sin datos de ingresos").foregroundColor(.white.opacity(0.5)).frame(height: 200)
                } else {
                    Chart(ingresos) { item in
                        LineMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                        PointMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                    }
                    .frame(height: 200).padding()
                }
            }.background(Color.black.opacity(0.3)).cornerRadius(25).padding(.horizontal)
            
            VStack {
                ForEach(ingresos.reversed()) { i in
                    HistorialRow(titulo: "Ingreso", monto: i.cantidad, fecha: i.fecha)
                }
            }.padding(.horizontal)
            
            Button(action: { mostrarForm = true }) {
                AddButton(titulo: "Ingreso")
            }
        }
        // SHEET MODIFICADO
        .sheet(isPresented: $mostrarForm) {
            FormularioPro(titulo: "Nuevo Ingreso", esGasto: false) { _, m in
                let nuevo = Ingreso(fecha: Date(), cantidad: m)
                ingresos.append(nuevo)
                SQLiteManager.shared.insertarIngreso(cantidad: m, fecha: Date())
            }
        }
    }
}

