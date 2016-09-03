//
//  FirebaseOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

typealias SnapshotKey = (String?) -> Void
typealias SignUpResult = (NSError?) -> Void

class FirebaseOperation {
    
    var firebaseDatabaseRef: FIRDatabaseReference
    
    init() {
     firebaseDatabaseRef = FIRDatabase.database().reference()
    }
    
    func getSnapshotKeyFromRef(firebaseChildRef: FIRDatabaseReference) -> String {
        let snapshotKey = "\(firebaseChildRef)".stringByReplacingOccurrencesOfString("https://mapspotswift.firebaseio.com/users/", withString: "")
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
    
    //Signs Up a user with an email & password account.
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
            })
            case true:
            CloudinaryOperation().uploadProfileImageToCloudinary(profileImage!, completion: {
                    (photoURL) in
                    let userProfile = ["name": name, "location": "", "profileImageURL": photoURL, "userID": user!.uid]
                    self.createUserProfile(userProfile, completion: {
                        (snapshotKey) in
                        let rlmUser = RLMUser()
                        rlmUser.createUser(name, email: email, userID: user!.uid, snapshotKey: snapshotKey!, location: "")
                        rlmUser.setRLMUserProfileImageAndURL(photoURL, image: UIImageJPEGRepresentation(UIImage(), 1.0)!)
                        RLMDBManager().writeObject(rlmUser)
                    })
                })
            }
        })
    }
    
}