//
//  UserData.swift
//  RoadTripPlaylistBuilderr
//
//  Created by Amy Saad on 4/9/25.
//

// UserData.swift
struct UserData: Codable {
    let email: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
    }
}
