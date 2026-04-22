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
                        
                        Button(action: { if !usuario.isEmpty { irHome = true } }) {
                            Text("ENTRAR")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
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
        ingresosFiltrados.reduce(0){$0 + $1.cantidad} - gastosFiltrados.reduce(0){$0 + $1.cantidad}
    }
    
    var body: some View {
        MainLayout(nombre: nombre, vistaActiva: "Resumen", ingresos: $ingresos, gastos: $gastos) {
            BalanceCard(monto: String(format: "%.0f", balance))
            
            ZStack {
                RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.3)).frame(height: 250)
                VStack {
                    Circle()
                        .trim(from: 0, to: balance <= 0 ? 0.01 : 0.7)
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
                            .interpolationMethod(.catmullRom).foregroundStyle(.blue).lineStyle(StrokeStyle(lineWidth: 4))
                        PointMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                            .foregroundStyle(.white).symbolSize(100)
                    }
                    .chartYAxis { AxisMarks(values: .automatic) { value in AxisGridLine().foregroundStyle(.white.opacity(0.1)); AxisValueLabel().foregroundStyle(.white) } }
                    .chartXAxis { AxisMarks { AxisValueLabel().foregroundStyle(.white) } }
                    .frame(height: 200).padding()
                }
            }.background(Color.black.opacity(0.3)).cornerRadius(25).padding(.horizontal)
            
            VStack {
                ForEach(gastos.reversed()) { g in HistorialRow(titulo: g.concepto, monto: -g.cantidad, fecha: g.fecha) }
            }.padding(.horizontal)
            
            Button(action: { mostrarForm = true }) { AddButton(titulo: "Gasto") }
        }
        .sheet(isPresented: $mostrarForm) { FormularioPro(titulo: "Nuevo Gasto", esGasto: true) { c, m in gastos.append(Gasto(fecha: Date(), concepto: c, cantidad: m)) } }
    }
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
                        BarMark(x: .value("Fecha", item.fecha), y: .value("Monto", item.cantidad))
                            .foregroundStyle(Color.blue.gradient)
                    }
                    .chartYAxis { AxisMarks { AxisValueLabel().foregroundStyle(.white) } }
                    .chartXAxis { AxisMarks { AxisValueLabel().foregroundStyle(.white) } }
                    .frame(height: 200).padding()
                }
            }.background(Color.black.opacity(0.3)).cornerRadius(25).padding(.horizontal)
            
            VStack {
                ForEach(ingresos.reversed()) { i in HistorialRow(titulo: "Ingreso", monto: i.cantidad, fecha: i.fecha) }
            }.padding(.horizontal)
            
            Button(action: { mostrarForm = true }) { AddButton(titulo: "Ingreso") }
        }
        .sheet(isPresented: $mostrarForm) { FormularioPro(titulo: "Nuevo Ingreso", esGasto: false) { _, m in ingresos.append(Ingreso(fecha: Date(), cantidad: m)) } }
    }
}

// MARK: - FORMULARIO ESTILO ORIGINAL
struct FormularioPro: View {
    let titulo: String; let esGasto: Bool
    var alGuardar: (String, Double) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var concepto = ""; @State private var monto = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 19/255, blue: 63/255).ignoresSafeArea()
            VStack(spacing: 25) {
                Capsule().fill(Color.white.opacity(0.2)).frame(width: 50, height: 5).padding(.top)
                Text(titulo).font(.title).bold().foregroundColor(.white)
                
                VStack(spacing: 20) {
                    TextField("Descripción", text: $concepto)
                        .padding().background(Color.white).cornerRadius(15).foregroundColor(.black)
                    TextField("Cantidad ($)", text: $monto)
                        .keyboardType(.decimalPad).padding().background(Color.white).cornerRadius(15).foregroundColor(.black)
                }.padding(.horizontal)
                
                Button(action: {
                    if let v = Double(monto), !concepto.isEmpty { alGuardar(concepto, v); dismiss() }
                }) {
                    Text("GUARDAR").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(15)
                }.padding(.horizontal)
                Spacer()
            }
        }
    }
}

// MARK: - COMPONENTES REUTILIZABLES
struct MainLayout<Content: View>: View {
    let nombre: String; let vistaActiva: String
    @Binding var ingresos: [Ingreso]; @Binding var gastos: [Gasto]; let content: Content
    
    init(nombre: String, vistaActiva: String, ingresos: Binding<[Ingreso]>, gastos: Binding<[Gasto]>, @ViewBuilder content: () -> Content) {
        self.nombre = nombre; self.vistaActiva = vistaActiva; self._ingresos = ingresos; self._gastos = gastos; self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 28/255, green: 19/255, blue: 63/255), Color(red: 101/255, green: 144/255, blue: 157/255)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Hola, \(nombre)").font(.title2).bold().foregroundColor(.white)
                    Spacer()
                    Image("icono").resizable().scaledToFit().frame(width: 40, height: 40)
                }.padding(.horizontal).padding(.top, 10)
                
                CustomNavBar(nombre: nombre, vistaActiva: vistaActiva, ingresos: $ingresos, gastos: $gastos).padding(.vertical, 15)
                ScrollView { VStack(spacing: 25) { content }.padding(.bottom, 30) }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct CustomNavBar: View {
    let nombre: String; let vistaActiva: String
    @Binding var ingresos: [Ingreso]; @Binding var gastos: [Gasto]
    var body: some View {
        HStack {
            navLink(titulo: "Ingresos", activo: vistaActiva == "Ingresos", destino: IngresosView(nombre: nombre, ingresos: $ingresos, gastos: $gastos))
            Spacer()
            navLink(titulo: "Resumen", activo: vistaActiva == "Resumen", destino: HomeView(nombre: nombre, ingresos: $ingresos, gastos: $gastos))
            Spacer()
            navLink(titulo: "Gastos", activo: vistaActiva == "Gastos", destino: GastosView(nombre: nombre, ingresos: $ingresos, gastos: $gastos))
        }.padding(.horizontal, 30)
    }
    func navLink(titulo: String, activo: Bool, destino: some View) -> some View {
        NavigationLink(destination: destino) {
            VStack {
                Text(titulo).foregroundColor(activo ? .white : .white.opacity(0.5)).bold(activo)
                if activo { Rectangle().frame(width: 40, height: 2).foregroundColor(.white) }
            }
        }
    }
}

struct BalanceCard: View {
    let monto: String
    var body: some View {
        VStack {
            Text("Balance Total").font(.caption).foregroundColor(.white.opacity(0.7))
            Text("$\(monto)").font(.system(size: 40, weight: .bold)).foregroundColor(.white)
        }.padding(20).frame(maxWidth: .infinity).background(Color.white.opacity(0.1)).cornerRadius(25).padding(.horizontal)
    }
}

struct HistorialRow: View {
    let titulo: String; let monto: Double; let fecha: Date
    var body: some View {
        HStack {
            Image(systemName: monto < 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(monto < 0 ? .blue : .white)
            VStack(alignment: .leading) {
                Text(titulo).foregroundColor(.white).font(.subheadline).bold()
                Text(fecha, format: .dateTime.day().month()).font(.caption2).foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("$\(Int(abs(monto)))").foregroundColor(.white).bold()
        }.padding().background(Color.black.opacity(0.2)).cornerRadius(15)
    }
}

struct FilterButton: View {
    let text: String; let activo: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(text).foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 8)
                .background(activo ? Color.blue : Color.white.opacity(0.2)).cornerRadius(15)
        }
    }
}

struct AddButton: View {
    let titulo: String
    var body: some View {
        VStack {
            Image(systemName: "plus.circle.fill").font(.system(size: 50)).foregroundColor(.blue)
            Text("Añadir \(titulo)").font(.caption).foregroundColor(.white)
        }
    }
}

func filtrarPorTiempo(fecha: Date, periodo: String) -> Bool {
    let cal = Calendar.current
    if periodo == "Día" { return cal.isDateInToday(fecha) }
    if periodo == "Semana" { return cal.isDate(fecha, equalTo: Date(), toGranularity: .weekOfYear) }
    return cal.isDate(fecha, equalTo: Date(), toGranularity: .month)
}

#Preview { ContentView() }
