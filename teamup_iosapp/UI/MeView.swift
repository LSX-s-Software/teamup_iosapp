//
//  MeView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import SwiftUI
import CachedAsyncImage

class StopWatch: ObservableObject {
    @Published var countdown = 0
    var timer = Timer()
    
    func start() {
        countdown = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.countdown -= 1
            if self.countdown == 0 {
                self.stop()
            }
        }
    }
    
    func stop() {
        timer.invalidate()
    }
}

struct MeView: View {
    struct TextFieldStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    struct NavLinkStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
    
    @State var registered = AuthService.registered
    @State var login = false
    @State var phone = ""
    @State var password = ""
    @State var code = ""
    @State var loading = false
    @ObservedObject var stopWatch = StopWatch()
    @State var alertShown = false
    @State var alertTitle = ""
    @State var alertMsg: String?
    @State var userInfo = UserService.userInfo
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .ignoresSafeArea(edges: .top)
                
                VStack {
                    // MARK: - 上部内容
                    if registered {
                        Spacer()
                            .frame(height: 28)
                        CachedAsyncImage(url: URL(string: userInfo?.avatar ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 125, height: 125)
                        .background(.white)
                        .cornerRadius(62.5)
                        .shadow(color: Color(white: 0, opacity: 0.1), radius: 15)
                        Text(userInfo?.username ?? "未填写用户名")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("\(userInfo?.faculty ?? "未填写学院") \(userInfo?.grade ?? "未填写年")级")
                            .foregroundColor(.white)
                        Spacer()
                            .frame(height: 28)
                    } else {
                        Image("Team")
                            .resizable()
                            .scaledToFit()
                            .padding(EdgeInsets(top: 40, leading: 32, bottom: 20, trailing: 32))
                        Spacer(minLength: 28)
                    }
                    
                    // MARK: - 下部内容
                    VStack {
                        if registered {
                            VStack(spacing: 16) {
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    HStack {
                                        Label("个人信息", systemImage: "person.text.rectangle")
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .modifier(NavLinkStyle())
                                }
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    HStack {
                                        Label("发布的招募", systemImage: "person.wave.2")
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .modifier(NavLinkStyle())
                                }
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    HStack {
                                        Label("我的收藏", systemImage: "star")
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .modifier(NavLinkStyle())
                                }
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    HStack {
                                        Label("设置", systemImage: "gear")
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .modifier(NavLinkStyle())
                                }
                            }
                            Spacer()
                        } else {
                            // MARK: - 注册登录
                            Text("赛道友你")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.accentColor)
                            Spacer()
                                .frame(height: 12)
                            Text("获取海量比赛资讯和组队信息，加入最适合自己的队伍，发现自己的价值")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Spacer()
                            
                            Group {
                                TextField("手机号", text: $phone)
                                    .keyboardType(.numberPad)
                                    .textContentType(.telephoneNumber)
                                    .modifier(TextFieldStyle())
                                if !login {
                                    HStack {
                                        TextField("验证码", text: $code)
                                            .keyboardType(.numberPad)
                                            .textContentType(.oneTimeCode)
                                            .modifier(TextFieldStyle())
                                        Button {
                                            handleSendVerifyCode()
                                        } label: {
                                            Text(stopWatch.countdown > 0 ? "已发送验证码(\(stopWatch.countdown))" : "获取验证码")
                                                .fontWeight(.semibold)
                                                .padding(5)
                                                .fixedSize(horizontal: true, vertical: false)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(stopWatch.countdown > 0)
                                    }
                                }
                                SecureField("密码", text: $password)
                                    .modifier(TextFieldStyle())
                            }
                            Spacer()
                                .frame(height: 20)
                            
                            Button {
                                handleLoginRegister()
                            } label: {
                                Group {
                                    if loading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(login ? "立即登录" : "立即注册")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                            HStack(spacing: 0) {
                                Text(login ? "没有账号？" : "已有账号？")
                                Button(login ? "注册" : "登录") {
                                    withAnimation {
                                        login.toggle()
                                    }
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 32, leading: 32, bottom: 12, trailing: 32))
                    .frame(maxWidth: .infinity)
                    .background(.background)
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                }
            }
        }
        .alert(alertTitle, isPresented: $alertShown, actions: {}, message: {
            if let alertMsg = alertMsg {
                Text(alertMsg)
            }
        })
    }
}

// MARK: - 事件处理
extension MeView {
    func showAlert(title: String, message: String?) {
        alertTitle = title
        alertMsg = message
        alertShown = true
    }
    
    func handleSendVerifyCode() {
        Task {
            do {
                try await AuthService.getVerifyCode(phone: phone)
                withAnimation(.easeInOut(duration: 0.2)) {
                    stopWatch.start()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func handleLoginRegister() {
        if loading { return }
        withAnimation {
            loading = true
        }
        Task {
            do {
                if login {
                    try await AuthService.login(phone: phone, password: password)
                } else {
                    try await AuthService.register(phone: phone, verifyCode: code, password: password)
                    stopWatch.stop()
                }
                userInfo = try await UserService.getUserInfoFromServer()
                withAnimation {
                    registered = true
                }
            } catch {
                showAlert(title: login ? "登录失败" : "注册失败", message: error.localizedDescription)
            }
            withAnimation {
                loading = false
            }
        }
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            MeView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
    }
}
