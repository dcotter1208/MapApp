//
//  FirebaseOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Cloudinary
import FirebaseDatabase
import Firebase
import FirebaseAuth

enum AddOrUpdate: String {
    case add
    case update
}

typealias SnapshotKeyHandler = (String?) -> Void
typealias SignUpResult = (NSError?) -> Void
typealias LogInResult = (CurrentUser?, NSError?) -> Void
typealias CurrentUserResult = (CurrentUser) -> Void
typealias SnapshotExistsResult = (Bool) -> Void

class FirebaseOperation: NSObject, CLUploaderDelegate {
    
    let firebaseDatabaseRef = FIRDatabase.database().reference()

    //gets the snapshot key from a firebase reference.
    func getSnapshotKeyFromRef(firebaseChildRef: FIRDatabaseReference) -> String {
        let snapshotKey = "\(firebaseChildRef)".replacingOccurrences(of: "https://mapapp-943f3.firebaseio.com/users/", with: "")
        return snapshotKey
    }
    
    //Creates a user profile on Firebase.
    func createUserProfile(userProfile: [String: String], completion: SnapshotKeyHandler) {
        let usersRef = firebaseDatabaseRef.ref.child("users").childByAutoId()
        usersRef.setValue(userProfile)
        completion(getSnapshotKeyFromRef(firebaseChildRef: usersRef))
    }
    
    func addOrUpdateUserProfile(userProfile: [String: AnyObject], completion: SnapshotKeyHandler) {
        var snapshotKey = ""
        var addOrUpdate: AddOrUpdate = .add
        if CurrentUser.sharedInstance.snapshotKey != "" {
            snapshotKey = CurrentUser.sharedInstance.snapshotKey
            addOrUpdate = .update
        }
        
        switch addOrUpdate {
        case .add:
            var firebaseProfile = userProfile
            firebaseProfile.removeValue(forKey: "profileImage")
            let usersRef = firebaseDatabaseRef.ref.child("users").childByAutoId()
            usersRef.setValue(firebaseProfile)
            completion(getSnapshotKeyFromRef(firebaseChildRef: usersRef))
        case .update:
            var firebaseProfile = userProfile
            firebaseProfile.removeValue(forKey: "profileImage")
            self.updateChildValue(child: "users", childKey: snapshotKey, nodeToUpdate: firebaseProfile as [String : AnyObject])
            var newUserProfile = userProfile
            newUserProfile.updateValue(snapshotKey as AnyObject, forKey: "snapshotKey")
            let rlmUser = RLMUser().createUser(userProfile: newUserProfile)
                RLMDBManager().updateObject(rlmUser!)
        }
    }

    fileprivate func writeToRealm(userProfile: [String : AnyObject]) {
        if let realmUser = RLMUser().createUser(userProfile: userProfile) {
            RLMDBManager().writeObject(realmUser)
        }
    }
    
    //Creates a new value for a specified child
    func setValueForChild(child: String, value: [String: Any]) {
        let childRef = firebaseDatabaseRef.child(child).childByAutoId()
        childRef.setValue(value)
    }
    
    //Deletes a value for a specified child.
    func deleteValueForChild(child: String, childKey: String) {
        let childToRemove = firebaseDatabaseRef.child(child).child(childKey)
        childToRemove.removeValue()
    }
    
    //Updates a specified child node
    func updateChildValue(child: String, childKey:String, nodeToUpdate: [String: AnyObject]) {
        let childRef = firebaseDatabaseRef.child(child)
        let childUpdates = [childKey:nodeToUpdate]
        childRef.updateChildValues(childUpdates)
    }
    
    //queries a Firebase child without constraints.
    func queryChildWithoutConstraints(child: String, firebaseDataEventType: FIRDataEventType, completion: @escaping (_ result: FIRDataSnapshot) -> Void) {
        let childRef = firebaseDatabaseRef.child(child)
        childRef.observe(firebaseDataEventType) {
            (snapshot) in
            completion(snapshot)
        }
    }
    
    //Accepts a query to listen for a change.
    func listenForChildNodeChanges(query: FIRDatabaseQuery, completion:@escaping (_ result:FIRDataSnapshot)-> Void) {
        query.observe(FIRDataEventType.childChanged) {
            (snapshot) in
            completion(snapshot)
        }
    }
    
    //Accepts a query with contraints to query Firebase
    func queryChildWithConstraints(_ query:FIRDatabaseQuery, firebaseDataEventType: FIRDataEventType, observeSingleEventType: Bool, completion:@escaping (_ result: FIRDataSnapshot) -> Void) {
        if observeSingleEventType {
            query.observeSingleEvent(of: firebaseDataEventType, with: { (snapshot) in
                completion(snapshot)
            })
        } else {
            query.observe(firebaseDataEventType, with: { (snapshot) in
                completion(snapshot)
            })
        }
    }
    
     //Validates if the venue exists on Firebase.
    func validateVenueUniqueness(_ venue: Venue, completion: @escaping SnapshotExistsResult) {
        let query = firebaseDatabaseRef.ref.child("venues").queryOrdered(byChild: "venueID").queryEqual(toValue: venue.venueID)
        queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) { (snapshot) in
            if snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    //Validates if the venue exists on Firebase.
    func validateFirebaseChildUniqueness(child: String, queryOrderedBy: String, equaledTo: String, completion: @escaping SnapshotExistsResult) {
        let query = firebaseDatabaseRef.ref.child(child).queryOrdered(byChild: queryOrderedBy).queryEqual(toValue: equaledTo)
        queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) { (snapshot) in
            if snapshot.exists() {
            let username = self.getSnapshotChildValueForKey(snapshot: snapshot, key: "username")
                if let existingUsername = username {
                    if self.lowerCaseStringsMatch(string1: existingUsername, string2: equaledTo) {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(true)
            }
        }
    }

    func getSnapshotChildValueForKey(snapshot: FIRDataSnapshot, key: String) -> String? {
        var value = ""
        for childSnap in snapshot.children {
            let snap = childSnap as! FIRDataSnapshot
            if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary {
                value = snapVal[key] as! String
                return value
            }
        }
        return nil
    }
    
    func lowerCaseStringsMatch (string1: String, string2: String) -> Bool {
        if string1.lowercased() == string2.lowercased() {
            return true
        } else {
            return false
        }
    }

    //MARK: Login & Signup Methods
    
    //Logs user into the app as an anonymous user.
    func loginWithAnonymousUser() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                print("Anonymous Log In Error: \(error)")
            } else {
                print("TODO: create function to set the Current User Singleton for anonymous user")
                CurrentUser.sharedInstance.userID = user!.uid
            }
        })
    }
    
    /*
     Logs a user in with Firebase using email and password. If there is no error then it gets the
     user from Realm. If there is no user profile in realm then it gets the user profile from Firebase
     and then writes the user profile to realm.
*/
  
    //WILL DELETE "WRITECURRENTUSERTOREALM"
    
    //Used to write the current user's profile to realm when it is obtained from Firebase.
    fileprivate func writeCurrentUserToRealm(user: FIRUser, snapshot:FIRDataSnapshot) {
        let snapshotDict = snapshot.value as! NSDictionary
        for child in snapshotDict {
            let snapChildDict = child.value as! NSDictionary
            let rlmUser = RLMUser()
            guard let name = snapChildDict["username"] as? String else {return}

//            let userProfile = ["username" : name, "userID" : user.uid]
//            rlmUser.createUser(name, userID: user.uid, snapshotKey: snapshot.key)

            guard snapChildDict["profileImageURL"] as! String != "" else {
                rlmUser.profileImageURL = snapChildDict["profileImageURL"] as! String
                RLMDBManager().writeObject(rlmUser)
                return
            }
            AlamoFireOperation.downloadProfileImageWithAlamoFire(URL: snapChildDict["profileImageURL"] as! String, completion: {
                (image, error) in
                guard error == nil else {return}
                rlmUser.setRLMUserProfileImageAndURL(snapChildDict["profileImageURL"] as! String, image: UIImageJPEGRepresentation(image!, 1.0)!)
                RLMDBManager().writeObject(rlmUser)
            })
        }
    }
    
    /*
     Sets the CurrentUser singleton with Firebase by querying the profile with the current user's userID.
     It then calls the writeCurrentUserToRealm func to write that profile to Realm.
 */
    fileprivate func setCurrentUserWithFirebase(_ user: FIRUser, completion: @escaping CurrentUserResult) {
        let query = self.firebaseDatabaseRef.ref.child("users").queryOrdered(byChild: "userID").queryEqual(toValue: user.uid)
        self.queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true, completion: { (result) in
            CurrentUser.sharedInstance.setCurrentUserWithFirebase(snapshot: result)
            self.writeCurrentUserToRealm(user: user, snapshot: result)
            completion(CurrentUser.sharedInstance)
        })
    }
    
    //Sets the CurrentUser singleton with realm results.
    fileprivate func setCurrentUserWithRealm(_ results: Results<RLMUser>, completion:(CurrentUserResult)) {
        CurrentUser.sharedInstance.setCurrentUserWithRealm(results: results)
        completion(CurrentUser.sharedInstance)
    }

    /*
     Signs Up a user with an email & password account.
     If a profileImage was not chosen then it signs up a user with Firebase,
     creates the profile on Firebase with "" as the profileImageURL, saves that
     profile to Realm and then sets the CurrentUser Singleton. If there was a
     chosen profile image then all the same things occur except that it saves the image
     to Cloudinary then saves the Firebase and Realm profile with the Cloudinary URL.
 */
    func signUpWithEmailAndPassword(_ email:String, password: String, name: String, profileImageChoosen: Bool, profileImage: UIImage?, completion: @escaping SignUpResult) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            (user, error) in
            guard error == nil else {
                //Decide Error Type here to then call appropriate alert controller.
                completion(error as NSError?)
                return
            }
            switch profileImageChoosen {
            case false:
            let userProfile = ["name": name, "location": "", "profileImageURL": "", "userID": user!.uid]
            self.createUserProfile(userProfile: userProfile, completion: {
                (snapshotKey) in
                let rlmUser = RLMUser()
//                rlmUser.createUser(name, userID: user!.uid, snapshotKey: snapshotKey!)
                RLMDBManager().writeObject(rlmUser)
                CurrentUser.sharedInstance.setCurrentUserProperties(name, imageURL: "", userID: user!.uid, snapshotKey: snapshotKey!)
                completion(nil)
            })
            case true:
            CloudinaryOperation().uploadImageToCloudinary(profileImage!, delegate: self, completion: {
                    (photoURL) in
                    let userProfile = ["name": name, "location": "", "profileImageURL": photoURL, "userID": user!.uid]
                    self.createUserProfile(userProfile: userProfile, completion: {
                        (snapshotKey) in
                        let rlmUser = RLMUser()
//                        rlmUser.createUser(name, userID: user!.uid, snapshotKey: snapshotKey!)
                        rlmUser.setRLMUserProfileImageAndURL(photoURL, image: UIImageJPEGRepresentation(profileImage!, 1.0)!)
                        RLMDBManager().writeObject(rlmUser)
                        CurrentUser.sharedInstance.setCurrentUserProperties(name, imageURL: photoURL, userID: user!.uid, snapshotKey: snapshotKey!)
                        CurrentUser.sharedInstance.profileImage = profileImage!
                        completion(nil)
                    })
                })
            }
        })
    }

    
}
