import Foundation
import UIKit
import SVProgressHUD
import SCLAlertView

class ReplyContainerViewController: UIViewController, UITextFieldDelegate{
    
    var question = Question()
    
    var tableView: ReplyTableViewController?
    var keyboardHeight : CGFloat = 0
    var height : CGFloat = 0
    
    @IBOutlet weak var replyTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var flagButton: UIBarButtonItem!
    @IBOutlet weak var replyTextField: UITextField!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.replyTextField.delegate = self
        height = (self.tabBarController?.tabBar.frame.size.height)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height - height
        moveTextField(replyTextField, moveDistance: -keyboardHeight, up: true)
        // do whatever you want with this keyboard height
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        moveTextField(replyTextField, moveDistance: -keyboardHeight, up: false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        let reply = Reply()
        let alert = SCLAlertView()
        if(replyTextField.text != "") {
            reply.postID = question.postID
            reply.reply = replyTextField.text!
            reply.uid = AppStorage.PersonalInfo.uid
            reply.username = AppStorage.PersonalInfo.username
            reply.pushToFirestore()
        }
        else{
            alert.showError("Error", subTitle: "Couldn't get location!")
        }
        _ = textFieldShouldReturn(replyTextField)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "repliesTableView" {
                let detail = segue.destination as! ReplyTableViewController
                detail.question = question
                tableView = detail
            }
        }
    }
    func moveTextField(_ textField: UITextField, moveDistance: CGFloat, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = (up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
}

