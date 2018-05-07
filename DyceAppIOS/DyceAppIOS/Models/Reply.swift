import Foundation
import UIKit

class Reply {
    
    var uid: String
    var username: String
    var reply: String
    
    init(_uid: String, _username: String, _reply: String) {
        uid = _uid
        username = _username
        reply = _reply
    }
    
    init() {
        uid = ""
        username = ""
        reply = ""
    }
    
}
