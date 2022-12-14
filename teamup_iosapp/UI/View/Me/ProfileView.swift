//
//  ProfileView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/29.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var userInfo = UserViewModel()!
    @State var editing = false
    @State var saving = false
    let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!
    let academyList: [Academy] = loadJSON("academies")
    // Alert
    @State var alertShown = false
    @State var alertTitle = ""
    @State var alertMsg: String?
    @State var logoutConfirmShown = false
    @State var editingAward = false
    @State var newAward = ""
    @State var editingAwardIndex = -1
    
    var body: some View {
        Form {
            Section("基本信息") {
                HStack {
                    Text("昵称")
                    if editing {
                        TextField("请输入昵称", text: $userInfo.username)
                            .textContentType(.nickname)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Spacer()
                        Text(userInfo.username)
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text("真名")
                    if editing {
                        TextField("请输入真名", text: $userInfo.realName)
                            .textContentType(.name)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Spacer()
                        Text(userInfo.realName)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("教育信息") {
                HStack {
                    Text("学号")
                    if editing {
                        TextField("请输入学号", text: $userInfo.studentId)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Spacer()
                        Text(nilOrEmpty(userInfo.studentId) ? "未填写" : userInfo.studentId)
                            .foregroundColor(.secondary)
                    }
                }
                if editing {
                    Picker("年级", selection: $userInfo.grade) {
                        ForEach(currentYear-6...currentYear, id: \.self) { i in
                            Text(String(format: "%d级", i)).tag(String(i))
                        }
                    }
                    Picker("学院", selection: $userInfo.faculty, content: {
                        ForEach(academyList, id: \.name) { section in
                            ForEach(section.children!, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                    })
                } else {
                    HStack {
                        Text("年级")
                        Spacer()
                        Text(nilOrEmpty(userInfo.grade) ? "未填写" : userInfo.grade)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("学院")
                        Spacer()
                        Text(nilOrEmpty(userInfo.faculty) ? "未填写" : userInfo.faculty)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("联系方式") {
                HStack {
                    Text("电话")
                    if editing {
                        TextField("请输入电话", text: $userInfo.phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Spacer()
                        Text(nilOrEmpty(userInfo.phone) ? "未填写" : userInfo.phone)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("自我介绍") {
                TextEditor(text: $userInfo.introduction)
                    .disabled(!editing)
            }
            
            Section("获奖经历") {
                if userInfo.awards.isEmpty && !editing {
                    Text("暂无获奖经历")
                }
                ForEach(Array(userInfo.awards.enumerated()), id: \.offset) { index, award in
                    HStack(spacing: 10) {
                        if index < 50 {
                            Image(systemName: "\(index + 1).circle")
                        } else {
                            Text("\(index + 1)")
                        }
                        Text(award)
                    }
                    .onTapGesture {
                        editingAwardIndex = index
                        newAward = award
                        editingAward = true
                    }
                }
                .onDelete { userInfo.awards.remove(atOffsets: $0) }
                .onMove { userInfo.awards.move(fromOffsets: $0, toOffset: $1) }
                .disabled(!editing)
                if editing {
                    Button("添加") {
                        editingAwardIndex = -1
                        newAward = ""
                        editingAward = true
                    }
                    .alert("编辑获奖经历", isPresented: $editingAward, actions: {
                        TextField("请填写奖项名", text: $newAward)
                        Button("确定", action: {
                            if editingAwardIndex == -1 {
                                userInfo.awards.append(newAward)
                            } else {
                                userInfo.awards[editingAwardIndex] = newAward
                            }
                        })
                        Button("取消", role: .cancel, action: {})
                    }, message: {
                        Text("请填写你的获奖经历")
                    })
                }
            }
            
            if !editing {
                Button("退出登录", role: .destructive) {
                    logoutConfirmShown = true
                }
                .confirmationDialog("确定要退出登录吗", isPresented: $logoutConfirmShown, titleVisibility: .visible) {
                    Button("退出登录", role: .destructive) {
                        UserService.logout()
                        dismiss()
                    }
                } message: {
                    Text("退出登录将清除保存在本地的所有用户信息。服务器保存上的信息不受影响")
                }
            }
        }
        .navigationTitle("个人信息")
        .navigationBarBackButtonHidden(editing)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if saving {
                    ProgressView()
                } else {
                    Button(editing ? "保存" : "编辑") {
                        if editing {
                            handleSave()
                        } else {
                            editing = true
                        }
                    }
                }
            }
            if editing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消", role: .destructive) {
                        editing = false
                        userInfo.reset()
                    }
                }
            }
        }
        .task {
            do {
                let newUserInfo = try await UserService.getUserInfoFromServer()
                userInfo.update(using: newUserInfo)
            } catch {
                showAlert(title: "获取用户信息失败", msg: error.localizedDescription)
            }
        }
        .alert(isPresented: $alertShown) {
            Alert(title: Text(alertTitle), message: Text(alertMsg ?? ""), dismissButton: .default(Text("确定")))
        }
    }
}

extension ProfileView {
    func showAlert(title: String, msg: String? = nil) {
        alertTitle = title
        alertMsg = msg
        alertShown = true
    }
    
    func handleSave() {
        saving = true
        Task {
            do {
                try await UserService.editUserInfo(newInfo: userInfo)
                editing = false
            } catch {
                showAlert(title: "保存失败", msg: error.localizedDescription)
            }
            saving = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
