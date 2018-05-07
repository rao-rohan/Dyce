import UIKit
import Firebase
import SVProgressHUD

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var lineView3: UIView!
    
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    
    //keyboard inset
    private var bottomSafeAreaInset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            //disables password autoFill accessory views.
            emailTF.textContentType = UITextContentType("")
            usernameTF.textContentType = UITextContentType("")
            passwordTF.textContentType = UITextContentType("")
        }
        
        //sets textfield types
        emailTF.autocorrectionType = .no
        usernameTF.autocorrectionType = .no
        passwordTF.autocorrectionType = .no
        
        //sets textfield delegates
        emailTF.delegate = self
        usernameTF.delegate = self
        passwordTF.delegate = self
        
        //rounds buttons
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        
        //configs continue button
        registerBtn.addTarget(self, action: #selector(SignUpVC.register(sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        emailTF.becomeFirstResponder()
        
        //adds an observer to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
        self.view.endEditing(true);
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            //this value is the bottom safe area place value.
            bottomSafeAreaInset =  view.safeAreaInsets.bottom
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Too much memory used")
    }
    
    //MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations:  { [weak self] in
            //moves everything up accordingly
            self?.toBottom.constant = keyboardHeight + 10 - (self?.bottomSafeAreaInset)!
            }, completion: nil)
    }

    
    @objc func register(sender: UIButton){
        
        //disables the continue button until this request is handled completely
        registerBtn.isEnabled = false
        
        let greyColor = UIColor(red: (151/255), green: (151/255), blue: (151/255), alpha: 1)
        lineView1.backgroundColor = greyColor
        lineView2.backgroundColor = greyColor
        lineView3.backgroundColor = greyColor
        
        guard let email = emailTF.email, let username = usernameTF.username, let password = passwordTF.password else{
            if !emailTF.textIsAnEmail(){
                lineView1.backgroundColor = UIColor.red
            }
            if !usernameTF.textIsAUsername(){
                lineView2.backgroundColor = UIColor.red
            }
            if !passwordTF.textIsAPassword(){
                lineView3.backgroundColor = UIColor.red
            }
            return
        }
        
        //starts the activity indicator
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
                if let code = AuthErrorCode(rawValue: error._code){
                    switch code{
                    case .invalidEmail:
                        self.lineView1.backgroundColor = UIColor.red
                    case .emailAlreadyInUse:
                        self.lineView1.backgroundColor = UIColor.red
                    case .weakPassword:
                        self.lineView3.backgroundColor = UIColor.red
                    default:
                        break
                    }
                    self.registerBtn.isEnabled = true
                    SVProgressHUD.dismiss()
                    sender.shake()
                }
            }else{
                if let user = user{
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }else{
                            AppStorage.PersonalInfo.uid = user.uid
                            AppStorage.PersonalInfo.username = username
                            
                            //segue to app
                            
                        }
                    })
                }
            }
        }

    }
    
    
    
    // MARK: - Navigation
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
