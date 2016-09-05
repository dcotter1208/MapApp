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

typealias SnapshotKey = (String?) -> Void
typealias SignUpResult = (NSError?) -> Void

class FirebaseOperation: NSObject, CLUploaderDelegate {
    
    var firebaseDatabaseRef: FIRDatabaseReference
    
    override init() {
     firebaseDatabaseRef = FIRDatabase.database().reference()
    }
    
    func getSnapshotKeyFromRef(firebaseChildRef: FIRDatabaseReference) -> String {
        let snapshotKey = "\(firebaseChildRef)".stringByReplacingOccurrencesOfString("https://mapapp-943f3.firebaseio.com/users/", withString: "")
        return snapshotKey
    }
    
    func createUserProfile(userProfile: [String: String], completion: SnapshotKey) {
        let usersRef = firebaseDatabaseRef.ref.child("users").childByAutoId()
        usersRef.setValue(userProfile)
        completion(getSnapshotKeyFromRef(usersRef))
    }
    
    //Creates a new value for a specified child
    func setValueForChild(child: String, value: [String: AnyObject]) {
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
    
    func queryChildWithoutConstrints(child: String, firebaseDataEventType: FIRDataEventType, completion: (result: FIRDataSnapshot) -> Void) {
        let childRef = firebaseDatabaseRef.child(child)
        childRef.observeEventType(firebaseDataEventType) {
            (snapshot) in
            completion(result: snapshot)
        }
    }
    
    //Accepts a query to listen for a change.
    func listenForChildNodeChanges(query: FIRDatabaseQuery, completion:(result:FIRDataSnapshot)-> Void) {
        query.observeEventType(FIRDataEventType.ChildChanged) {
            (snapshot) in
            completion(result: snapshot)
        }
    }
    
    //Accepts a query with contraints to query Firebase
    func queryChildWithConstrtaints(query:FIRDatabaseQuery, firebaseDataEventType: FIRDataEventType, observeSingleEventType: Bool, completion:(result: FIRDataSnapshot) -> Void) {
        if observeSingleEventType {
            query.observeSingleEventOfType(firebaseDataEventType, withBlock: { (snapshot) in
                completion(result: snapshot)
            })
        } else {
            query.observeEventType(firebaseDataEventType, withBlock: { (snapshot) in
                completion(result: snapshot)
            })
        }
    }
    
    func loginWithEmailAndPassword(email: String, password: String, completion: SignUpResult) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {
            (user, error) in
            guard error == nil else {
                completion(error)
                return
            }
            guard let user = user else {return}
            let results = RLMDBManager().getCurrentUserFromRealm(user.uid)
            guard results.isEmpty == false else {
                print("Made it here...")
                self.setCurrentUserWithFirebase(user)
                return
            }
            self.setCurrentUserWithRealm(results)
        })
    }
    
    private func writeCurrentUserToRealm(user: FIRUser, snapshot:FIRDataSnapshot) {
        for child in snapshot.children {
            let rlmUser = RLMUser()
            guard let email = user.email else {return}
            rlmUser.createUser(child.value["name"] as! String, email: email, userID: user.uid, snapshotKey: snapshot.key, location: child.value["location"] as! String)
            guard child.value["profileImageURL"] as! String != "" else {
                rlmUser.profileImageURL = child.value["profileImageURL"] as! String
                RLMDBManager().writeObject(rlmUser)
                return
            }
            AlamoFireOperation.downloadProfileImageWithAlamoFire(child.value["profileImageURL"] as! String, completion: {
                (image, error) in
                guard error == nil else {return}
                rlmUser.setRLMUserProfileImageAndURL(child.value["profileImageURL"] as! String, image: UIImageJPEGRepresentation(image!, 1.0)!)
                RLMDBManager().writeObject(rlmUser)
            })
        }
    }
    
    private func setCurrentUserWithFirebase(user: FIRUser) {
        let query = self.firebaseDatabaseRef.ref.child("users").queryOrderedByChild("userID").queryEqualToValue(user.uid)
        self.queryChildWithConstrtaints(query, firebaseDataEventType: .Value, observeSingleEventType: true, completion: { (result) in
            print("Snap Result: \(result)")
            CurrentUser.sharedInstance.setUserProperties(result)
            self.writeCurrentUserToRealm(user, snapshot: result)
            print("Current User Set With Firebase: \(CurrentUser.sharedInstance.name)")

        })
    }
    
    private func setCurrentUserWithRealm(results: Results<RLMUser>) {
    CurrentUser.sharedInstance.setCurrentUserProperties(results[0].name, location: results[0].location, imageURL: results[0].profileImageURL, userID: results[0].userID, snapshotKey: results[0].snapshotKey)
        
        print("Current User Set With Realm: \(CurrentUser.sharedInstance.name)")
    }
    
    /*
     Signs Up a user with an email & password account.
     If a profileImage was not chosen then it signs up a user with Firebase,
     creates the profile on Firebase with "" as the profileImageURL, saves that
     profile to Realm and then sets the CurrentUser Singleton. If there was a
     chosen profile image then all the same things occur except that it saves the image
     to Cloudinary then saves the Firebase and Realm profile with the Cloudinary URL.
 */
    func signUpWithEmailAndPassword(email:String, password: String, name: String, profileImageChoosen: Bool, profileImage: UIImage?, completion: SignUpResult) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: {
            (user, error) in
            guard error == nil else {
                //Decide Error Type here to then call appropriate alert controller.
                completion(error)
                return
            }
            switch profileImageChoosen {
            case false:
            let userProfile = ["name": name, "location": "", "profileImageURL": "", "userID": user!.uid]
            self.createUserProfile(userProfile, completion: {
                (snapshotKey) in
                let rlmUser = RLMUser()
                rlmUser.createUser(name, email: email, userID: user!.uid, snapshotKey: snapshotKey!, location: "")
                RLMDBManager().writeObject(rlmUser)
                CurrentUser.sharedInstance.setCurrentUserProperties(name, location: "", imageURL: "", userID: user!.uid, snapshotKey: snapshotKey!)
                completion(nil)
            })
            case true:
            CloudinaryOperation().uploadProfileImageToCloudinary(profileImage!, delegate: self, completion: {
                    (photoURL) in
                    let userProfile = ["name": name, "location": "", "profileImageURL": photoURL, "userID": user!.uid]
                    self.createUserProfile(userProfile, completion: {
                        (snapshotKey) in
                        let rlmUser = RLMUser()
                        rlmUser.createUser(name, email: email, userID: user!.uid, snapshotKey: snapshotKey!, location: "")
                        rlmUser.setRLMUserProfileImageAndURL(photoURL, image: UIImageJPEGRepresentation(profileImage!, 1.0)!)
                        RLMDBManager().writeObject(rlmUser)
                        CurrentUser.sharedInstance.setCurrentUserProperties(name, location: "", imageURL: photoURL, userID: user!.uid, snapshotKey: snapshotKey!)
                        CurrentUser.sharedInstance.profileImage = profileImage!
                        completion(nil)
                    })
                })
            }
        })
    }

    
}