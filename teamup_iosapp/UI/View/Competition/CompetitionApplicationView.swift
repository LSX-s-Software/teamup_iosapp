//
//  CompetitionApplicationView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import SwiftUI

struct CompetitionApplicationView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = CompetitionViewModel()
    var didCreateCompetition: ((Competition) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("比赛名称", text: $viewModel.name)
                    TextField("比赛简称", text: $viewModel.abbreviation)
                }
                
                Section("比赛介绍") {
                    TextEditor(text: $viewModel.description)
                }
                
                Section("时间节点") {
                    DatePicker("开始时间", selection: $viewModel.startTime, displayedComponents: .date)
                    DatePicker("结束时间", selection: $viewModel.endTime, in: viewModel.startTime..., displayedComponents: .date)
                }
            }
            .navigationTitle("建议新比赛")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("提交") {
                        submit()
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.abbreviation.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func submit() {
        Task {
            do {
                let result = try await CompetitionService.createCompetition(viewModel.competition)
                didCreateCompetition?(result)
                dismiss()
            } catch {
                print(error)
            }
        }
    }
}

struct CompetitionApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionApplicationView()
    }
}
