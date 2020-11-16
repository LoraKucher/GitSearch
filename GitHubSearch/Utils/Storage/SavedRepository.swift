import Foundation
import RealmSwift
import RxSwift
import RxRealm

@objcMembers
class SavedRepository: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var url: String = ""
}

class StorageRepository {
    private let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func fetchSavedRepository() -> Observable<[SavedRepository]> {
        let resultRepos = self.realm.objects(SavedRepository.self)
        let fetchedRepos = Observable.collection(from: resultRepos).map { $0.toArray() }
        return fetchedRepos
    }
    
    func saveRepository(from repo: Repository) {
        checkReposCount()
        
        let repoToSave = SavedRepository()
        repoToSave.id = repo.id
        repoToSave.name = repo.name
        repoToSave.url = repo.url
        do {
            try self.realm.write {
                self.realm.add(repoToSave)
            }
        } catch {
            preconditionFailure("Error safe")
        }
    }
    
    private func checkReposCount() {
        if self.realm.objects(SavedRepository.self).count == 20 {
            do {
                guard let object = self.realm.objects(SavedRepository.self).first else { return }
                try self.realm.write {
                    self.realm.delete(object)
                }
            } catch {
                preconditionFailure("Error safe")
            }
        }
    }
}
