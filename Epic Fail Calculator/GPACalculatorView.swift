//
//  CalculatorView.swift
//  Epic Fail Calculator
//
//  Created by Shrish Deshpande on 19/02/24.
//

import SwiftUI
import Observation

struct GPACalculatorView: View {
    @State var subjects: [SubjectEntry] = []
    @State var selectedTemplate: SubjectTemplate = SubjectTemplate.templates[0]
    @State var results: Results? = nil
    @State var showNoSubjectsAlert: Bool = false
    
    var body: some View {
        VStack {
            Text("Epic Fail Calculator")
                .font(.largeTitle)
            
            HStack {
                Picker("Select a template", selection: $selectedTemplate) {
                    ForEach(SubjectTemplate.templates) { template in
                        Text(template.name).tag(template)
                    }
                }
                .onChange(of: selectedTemplate, initial: true) { oldValue, newValue in
                    subjects = newValue.subjects
                }
                Button("Reset") {
                    subjects = selectedTemplate.subjects
                }
            }
            
            Table($subjects) {
                TableColumn("Subject") { $entry in
                    TextField("Subject", text: $entry.name)
                        .textFieldStyle(.roundedBorder)
                }
                .alignment(.center)
                TableColumn("Credits") { $entry in
                    TextField("Credits", value: $entry.credits, formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                }
                .width(50)
                .alignment(.center)
                TableColumn("Uncertain") { $entry in
                    Toggle("", isOn: $entry.uncertain)
                }
                .width(80)
                .alignment(.center)
                TableColumn("Grade Point Max") { $entry in
                    TextField("Grade Point Max", value: $entry.gradePointMax, formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                }
                .width(100)
                .alignment(.center)
                TableColumn("Grade Point Min") { $entry in
                    if entry.uncertain {
                        TextField("Grade Point Min", value: $entry.gradePointMin, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text("N/A")
                    }
                }
                .width(100)
                .alignment(.center)
            }
            .frame(idealHeight: 300)
            
            if results != nil {
                if let results = results {
                    Text("Mean: \(String(format: "%.2f", results.mean))")
                    Text("Median: \(String(format: "%.2f", results.median))")
                    Text("Variance: \(String(format: "%.2f", results.variance))")
                    Text("Standard Deviation: \(String(format: "%.2f", results.standardDeviation))")
                    Text("All values: \(results.gpas.map { String(format: "%.2f", $0) }.joined(separator: ", "))")
                }
            }
            
            Spacer()
            
            Button("Calculate") {
                if subjects.isEmpty {
                    showNoSubjectsAlert = true
                    return
                }
                Task.init {
                    let totalCredits = subjects.reduce(0) { $0 + $1.credits }
                    let certainGradePoints = subjects.filter({ $0.certain }).reduce(0) { $0 + $1.gradePointMax * $1.credits}
                    var gradePoints: [Int] = [certainGradePoints]
                    subjects.filter({ !$0.certain }).forEach { subject in
                        var newGradePoints: [Int] = []
                        for i in subject.gradePointMin...subject.gradePointMax {
                            for gradePoint in gradePoints {
                                newGradePoints.append(gradePoint + i * subject.credits)
                            }
                        }
                        gradePoints = newGradePoints
                    }
                    
                    let gpas = gradePoints.map { Double($0) / Double(totalCredits) }.sorted()
                    let mean = gpas.reduce(0, +) / Double(gpas.count)
                    let variance = gpas.reduce(0) { $0 + pow($1 - mean, 2) } / Double(gpas.count)
                    let standardDeviation = sqrt(variance)
                    let median = gpas.count % 2 == 0 ? (gpas[gpas.count / 2 - 1] + gpas[gpas.count / 2]) / 2.0 : gpas[gpas.count / 2]
                    
                    DispatchQueue.main.async {
                        results = Results(gpas: gpas, count: gpas.count, median: median, mean: mean, variance: variance, standardDeviation: standardDeviation)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showNoSubjectsAlert) {
            VStack {
                Text("No subjects to calculate")
                Button("OK") {
                    showNoSubjectsAlert = false
                }
            }
            .padding()
        }
    }
}

struct Results {
    var gpas: [Double]
    var count: Int
    var median: Double
    var mean: Double
    var variance: Double
    var standardDeviation: Double
    var bestCase: Double {
        gpas.max()!
    }
    var worstCase: Double {
        gpas.min()!
    }
}

struct SubjectTemplate: Identifiable, Hashable {
    static let templates = [
        SubjectTemplate(name: "None", subjects: []),
        SubjectTemplate(name: "RVCE 1st year Chemistry Cycle", subjects: SubjectEntry.rvceCCycleTemplate),
        SubjectTemplate(name: "RVCE 1st year Physics Cycle", subjects: SubjectEntry.rvcePCycleTemplate),
    ]
    
    var id = UUID()
    
    var name: String
    var subjects: [SubjectEntry]
}

struct SubjectEntry: Identifiable, Hashable {
    static let rvceCCycleTemplate: [SubjectEntry] = [
        .init(name: "Chemistry", credits: 4, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Mathematics", credits: 4, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Engineering Science", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Programming Language", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Computer Aided Design", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Indian Constitution", credits: 1, gradePointMax: 10, gradePointMin: 10),
        .init(name: "English", credits: 1, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Yoga", credits: 1, gradePointMax: 10, gradePointMin: 10),
    ]
    static let rvcePCycleTemplate: [SubjectEntry] = [
        .init(name: "Physics", credits: 4, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Mathematics", credits: 4, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Engineering Science", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Emerging Technology", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Professional Core Course", credits: 3, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Kannada", credits: 1, gradePointMax: 10, gradePointMin: 10),
        .init(name: "English", credits: 1, gradePointMax: 10, gradePointMin: 10),
        .init(name: "Idea Lab", credits: 1, gradePointMax: 10, gradePointMin: 10),
    ]
    
    var id = UUID()
    
    var name: String
    var credits: Int
    var gradePointMax: Int {
        didSet {
            if gradePointMax < gradePointMin {
                gradePointMin = gradePointMax
            }
        }
    }
    var gradePointMin: Int {
        didSet {
            if gradePointMin > gradePointMax {
                gradePointMax = gradePointMin
            }
        }
    }
    var certain: Bool {
        return uncertain == false
    }
    var uncertain: Bool = false {
        didSet {
            if uncertain {
                gradePointMin = gradePointMax
            }
        }
    }
}

#Preview {
    GPACalculatorView()
}
