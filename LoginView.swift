

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @EnvironmentObject var userManager: UserManager
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account / Sign In")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                
                Button(action: {
                    userManager.signIn(email: email, password: password)
                    if !userManager.isSignedIn {
                        showError = true
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .alert("Invalid Credentials", isPresented: $showError){
                    Button("OK", role: .cancel){}
                } message: {
                    Text("Please check your email and password.")
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                               startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
static var previews: some View {
LoginView().environmentObject(UserManager())
}
}


