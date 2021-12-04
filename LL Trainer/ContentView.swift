//
//  ContentView.swift
//  LL Trainer
//
//  Created by Luca Bergesio on 17/11/21.
//

import SwiftUI
import Combine


let OLL_NUM: Int = 57
let PLL_NUM = 21
let COLUMNS = 8

struct CubeCase: Codable {
    var image: String = ""
    var enabled: Bool = true
    var counter: Int = 0
    var average: Float = 0.0
    var sum: Float = 0.0
    var sumSq: Float = 0.0
    var std: Float = 0.0
    var progressValueNormalized: Int = 0
}


struct ContentView: View {
    private var columnsOll: [GridItem] = [GridItem](repeating: GridItem(.flexible(minimum: 155, maximum: .infinity), spacing: 5), count: COLUMNS)
    
//    @State private var waitTime: String = "0"
    
    @State private var probabilityCheck = false
    
    @State private var isTimerRunning = false
    @State private var startTime =  Date()
    @State private var timerString = "0.00"
    @State private var startStopButton = "START"
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    
    @State private var currentCase = "done"
    
    @State var filename = "session.json"
    
    
    let ollProbability = [
        "oll01print": 4, "oll02print": 2, "oll03print": 1, "oll04print": 4, "oll05print": 4, "oll06print": 4,
        "oll07print": 4, "oll08print": 4, "oll09print": 4, "oll10print": 2, "oll11print": 4, "oll12print": 4,
        "oll13print": 4, "oll14print": 4, "oll15print": 4, "oll16print": 4, "oll17print": 2, "oll18print": 4,
        "oll19print": 4, "oll20print": 4, "oll21print": 4, "oll22print": 4, "oll23print": 4, "oll24print": 4,
        "oll25print": 4, "oll26print": 4, "oll27print": 4, "oll28print": 4, "oll29print": 4, "oll30print": 4,
        "oll31print": 4, "oll32print": 4, "oll33print": 4, "oll34print": 4, "oll35print": 4, "oll36print": 4,
        "oll37print": 4, "oll38print": 4, "oll39print": 4, "oll40print": 4, "oll41print": 4, "oll42print": 4,
        "oll43print": 4, "oll44print": 4, "oll45print": 4, "oll46print": 4, "oll47print": 4, "oll48print": 2,
        "oll49print": 2, "oll50print": 4, "oll51print": 4, "oll52print": 4, "oll53print": 4, "oll54print": 4,
        "oll55print": 4, "oll56print": 4, "oll57print": 4,
    ]
    
    let pllProbability = [
        "pll01": 4, "pll02": 4, "pll03": 2, "pll04": 2, "pll05": 1, "pll06": 4, "pll07": 4,
        "pll08": 4, "pll09": 4, "pll10": 4, "pll11": 4, "pll12": 4, "pll13": 4, "pll14": 4,
        "pll15": 4, "pll16": 4, "pll17": 4, "pll18": 4, "pll19": 1, "pll20": 1, "pll21": 4
    ]
    
    @State private var currentOllSet: [String]
    @State private var currentPllSet: [String]
    
    @State private var selectedTab = 0
    
    @State private var ollCases: [String: CubeCase]
    @State private var pllCases: [String: CubeCase]
    
    @State private var showingAlert = false
    
    
    init() {
        _currentOllSet = State(initialValue: Array(Array(ollProbability.keys.sorted {$0 < $1}).prefix(OLL_NUM)))
        _currentPllSet = State(initialValue: Array(Array(pllProbability.keys.sorted {$0 < $1}).prefix(PLL_NUM)))
        
        var tmp: [String: CubeCase] = [:]
        for element in ollProbability {
            tmp[element.key] = CubeCase(image: element.key)
        }
        
        _ollCases = State(initialValue: tmp)
        
        tmp = [:]
        for element in pllProbability {
            tmp[element.key] = CubeCase(image: element.key)
        }
        
        _pllCases = State(initialValue: tmp)
    }
    
    
    var body: some View {
        HStack {
            VStack {
                Image(currentCase)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .top)
                    .padding()
                Text(self.timerString)
                    .font(Font.system(size: 60, design: .monospaced))
                    .onReceive(timer) { _ in
                        if self.isTimerRunning {
                            timerString = String(format: "%.2f", (Date().timeIntervalSince( self.startTime)))
                        }
                    }
                    .padding()
                HStack {
                    Button(self.startStopButton) {
                        if !isTimerRunning {
                            if selectedTab == 0 {
                                if timerString != "0.00" {
                                    //Write previous result
                                    ollCases[currentCase]?.counter += 1
                                    ollCases[currentCase]?.average = ((Float((ollCases[currentCase]?.counter)! - 1) * (ollCases[currentCase]?.average)!) + Float(timerString)!) / Float(ollCases[currentCase]!.counter)
                                    
                                    ollCases[currentCase]?.sum += Float(timerString)!
                                    ollCases[currentCase]?.sumSq += pow(Float(timerString)!, 2)
                                    ollCases[currentCase]?.std = sqrt((ollCases[currentCase]!.sumSq - (pow(ollCases[currentCase]!.sum, 2) / Float(ollCases[currentCase]!.counter))) / Float(ollCases[currentCase]!.counter))
                                    
                                    var slowestOll: Float = 0.0
                                    for oll in ollCases.values {
                                        if oll.enabled {
                                            if oll.average > slowestOll {
                                                slowestOll = oll.average
                                            }
                                        }
                                    }
                                    if slowestOll != 0.0 {
                                        for i in ollCases.keys {
                                            ollCases[i]?.progressValueNormalized = Int(round(ollCases[i]!.average * 10 / slowestOll))
                                        }
                                    }
                                }
                                //Generate new case
                                currentCase = currentOllSet.randomElement()!
                            }    else if selectedTab == 1 {
                                if timerString != "0.00" {
                                    //Write previous result
                                    pllCases[currentCase]?.counter += 1
                                    pllCases[currentCase]?.average = ((Float((pllCases[currentCase]?.counter)! - 1) * (pllCases[currentCase]?.average)!) + Float(timerString)!) / Float(pllCases[currentCase]!.counter)
                                    
                                    pllCases[currentCase]?.sum += Float(timerString)!
                                    pllCases[currentCase]?.sumSq += pow(Float(timerString)!, 2)
                                    pllCases[currentCase]?.std = sqrt((pllCases[currentCase]!.sumSq - (pow(pllCases[currentCase]!.sum, 2) / Float(pllCases[currentCase]!.counter))) / Float(pllCases[currentCase]!.counter))
                                    
                                    var slowestPll: Float = 0.0
                                    for pll in pllCases.values {
                                        if pll.enabled {
                                            if pll.average > slowestPll {
                                                slowestPll = pll.average
                                            }
                                        }
                                    }
                                    if slowestPll != 0.0 {
                                        for i in pllCases.keys {
                                            pllCases[i]?.progressValueNormalized = Int(round(pllCases[i]!.average * 10 / slowestPll))
                                        }
                                    }
                                }
                                //Generate new case
                                currentCase = currentPllSet.randomElement()!
                            }
                            
                            //Reset timer and start
                            timerString = "0.00"
                            startTime = Date()
                            self.startStopButton = " STOP "
                        } else {
                            self.startStopButton = "START"
                        }
                        isTimerRunning.toggle()
                    }
                    .disabled(currentOllSet.count == 0)
                    .keyboardShortcut(.space, modifiers: [])
                    .focusable()
                    
                    Button("Discard") {
                        timerString = "0.00"
                    }
                    .disabled(isTimerRunning || (timerString == "0.00"))
                    .focusable()
                }
                .padding()
                
//                HStack {
//                    Text("Wait time (sec):")
//                    TextField("0", text: $waitTime)
//                        .lineLimit(1)
//                        .onReceive(Just(waitTime)) { value in
//                            let filtered = "\(value)".filter { "0123456789".contains($0) }
//                            if filtered != value {
//                                self.waitTime = "\(filtered)"
//                            }
//                            let shortString = String(value.prefix(2))
//                            if shortString != value {
//                                self.waitTime = shortString
//                            }
//                        }
//                        .fixedSize()
//                }
                
                Toggle(isOn: $probabilityCheck) {
                    Text("Correct probability. Each case has a % chance of occurring equal to that of it occurring in an actual solve.")
                        .frame(width: 200)
                }.toggleStyle(CheckboxToggleStyle())
                    .onChange(of: probabilityCheck) { value in
                        if value {
                            var newOllSet: [String] = []
                            for oll in currentOllSet {
                                for _ in 1...ollProbability[oll]! {
                                    newOllSet.append(oll)
                                }
                            }
                            currentOllSet = newOllSet
                            
                            var newPllSet: [String] = []
                            for pll in currentPllSet {
                                for _ in 1...pllProbability[pll]! {
                                    newPllSet.append(pll)
                                }
                            }
                            currentPllSet = newPllSet
                        } else {
                            currentOllSet = Array(Set(currentOllSet))
                            currentPllSet = Array(Set(currentPllSet))
                        }
                    }
                    .padding()
                
                Button("Load Session") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        self.filename = panel.url!.lastPathComponent
                        
                        
                        
                        if !FileManager.default.fileExists(atPath: panel.url!.path) {
                            fatalError("File at path \(panel.url!.path) does not exist!")
                        }
                        
                        if let data = FileManager.default.contents(atPath: panel.url!.path) {
                            let decoder = JSONDecoder()
                            do {
                                let model = try decoder.decode([String: CubeCase].self, from: data)
                                
                                for cubeCase in model.values {
                                    if cubeCase.image.contains("oll") {
                                        ollCases[cubeCase.image] = cubeCase
                                    } else {
                                        pllCases[cubeCase.image] = cubeCase
                                    }
                                }
                                
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        } else {
                            fatalError("No data at \(panel.url!.path)!")
                        }
                    }
                }
                .disabled(isTimerRunning)
                
                Button("Save Session") {
                    let savePanel = NSSavePanel()
                    savePanel.canCreateDirectories = true
                    savePanel.showsTagField = false
                    savePanel.nameFieldStringValue = filename
                    savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
                    savePanel.begin { (result) in
                        if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                            let encoder = JSONEncoder()
                            do {
                                let data = try encoder.encode(ollCases.merging(pllCases) {(current, _) in current})
                                if FileManager.default.fileExists(atPath: savePanel.url!.path) {
                                    try FileManager.default.removeItem(at: savePanel.url!)
                                }
                                FileManager.default.createFile(atPath: savePanel.url!.path, contents: data, attributes: nil)
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                }
                .disabled(isTimerRunning)
                
                Button("Clear Session") {
                    showingAlert = true
                }.alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete the current session?"),
//                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Delete")) {
                            for cubeCase in ollCases.keys {
                                ollCases[cubeCase] = CubeCase(image: cubeCase)
                            }
                            for cubeCase in pllCases.keys {
                                pllCases[cubeCase] = CubeCase(image: cubeCase)
                            }
                            
                            timerString = "0.00"
                            currentCase = "done"
                        },
                        secondaryButton: .cancel()
                    )
                }
                .disabled(isTimerRunning)
                .padding()
                
                Text("INSTRUCTIONS\n-Use the spacebar to start/stop the timer\n-The time is accepted on next start,\n  if not discarded\n-Click on a case on the right to enable/disable it")
                    .font(.caption)
                    .padding(.top, 100)
            }
            
            TabView(selection: $selectedTab) {
                LazyVGrid(columns: columnsOll) {
                    ForEach((1...OLL_NUM), id: \.self) { i in
                        let imageName = "oll\((i < 10) ? "0\(i)" : "\(i)")print"
                        CaseView(state: Binding($ollCases[imageName])!)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                ollCases[imageName]?.enabled.toggle()
                                if ollCases[imageName]!.enabled {
                                    if probabilityCheck {
                                        for _ in 1...ollProbability[imageName]! {
                                            currentOllSet.append(imageName)
                                        }
                                    } else {
                                        currentOllSet.append(imageName)
                                    }
                                } else {
                                    currentOllSet = Array(currentOllSet.filter {$0 != imageName})
                                }
                            }
                    }
                }
                .padding()
                .tabItem {
                    Text("OLL")
                }
                .onTapGesture {
                    self.selectedTab = 1
                }
                .tag(0)
                
                LazyVGrid(columns: columnsOll) {
                    ForEach((1...PLL_NUM), id: \.self) { i in
                        let imageName = "pll\((i < 10) ? "0\(i)" : "\(i)")"
                        CaseView(state: Binding($pllCases[imageName])!)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                pllCases[imageName]?.enabled.toggle()
                                if pllCases[imageName]!.enabled {
                                    if probabilityCheck {
                                        for _ in 1...pllProbability[imageName]! {
                                            currentPllSet.append(imageName)
                                        }
                                    } else {
                                        currentPllSet.append(imageName)
                                    }
                                } else {
                                    currentPllSet = Array(currentPllSet.filter {$0 != imageName})
                                }
                            }
                    }
                }
                .padding()
                .tabItem {
                    Text("PLL")
                }
                .tag(1)
                
                
//                Text("Todo")
//                    .tabItem {
//                        Text("PLL Recognition")
//                    }
//                    .tag(2)
            }
            .padding()
        }
        
        .padding(.leading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
