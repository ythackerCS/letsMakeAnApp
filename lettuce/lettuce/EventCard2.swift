//
//  EventCard2.swift
//  lettuce
//
//  Created by Alex Appel on 4/12/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import Foundation
import UIKit

class EventCard2: UITableViewCell {
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var personIcon1: UIImageView!
    @IBOutlet weak var personIcon2: UIImageView!
    @IBOutlet weak var personIcon3: UIImageView!
    @IBOutlet weak var bookmarkIcon: UIButton!
    var documentID: String!
}
