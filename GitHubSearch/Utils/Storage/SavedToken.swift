import Foundation
import RealmSwift
import RxSwift
import RxRealm

@objcMembers
class SavedAccessToken: Object {
    dynamic var accessToken: String = ""
    
    override class func primaryKey() -> String? {
        return "accessToken"
    }
}

class StorageAccessToken {
    private let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func fetchToken() -> SavedAccessToken? {
        return self.realm.objects(SavedAccessToken.self).first
    }
    
    func saveToken(from token: AuthTokenResponse) {
        
        let tokenToSave = SavedAccessToken()
        tokenToSave.accessToken = token.accessToken
        do {
            try self.realm.write {
                self.realm.add(tokenToSave, update: .modified)
            }
        } catch {
            preconditionFailure("Error safe")
        }
    }
}
