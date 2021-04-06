//
//  ViewController.swift
//  FloatingPlaceholderTextField
//
//  Created by Dmitry Shelonin on 04/06/2021.
//  Copyright (c) 2021 Dmitry Shelonin. All rights reserved.
//

import UIKit
import FloatingPlaceholderTextField

class ViewController: UIViewController {
    private enum Group: Int {
        case placeholder = 0
        case line
    }
    @IBOutlet private weak var textField: FloatingPlaceholderTextField!
    @IBOutlet private weak var disabledSwitch: UISwitch!
    @IBOutlet private weak var groupSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var activitySegmentedControl: UISegmentedControl!
    @IBOutlet private weak var fillingSegmentedControl: UISegmentedControl!
    @IBOutlet var colorButtons: [UIButton]!
    
    private var colorIndexes: [Group: [FloatingPlaceholderTextField.State: Int]] = [:]
    private var currentGroup: Group = .placeholder
    private var currentState: FloatingPlaceholderTextField.State {
        var state = FloatingPlaceholderTextField.State.default
        
        switch self.activitySegmentedControl.selectedSegmentIndex {
        case 0: break //inactive
        case 1: state.insert(.active) //first responder
        case 2: state.insert(.disabled)
        default: break
        }
        switch self.fillingSegmentedControl.selectedSegmentIndex {
        case 0: break
        case 1: state.insert(.filled)
        default: break
        }
        
        return state
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.textField.isEnabled = !self.disabledSwitch.isOn
        self.groupSegmentedControl.selectedSegmentIndex = self.currentGroup.rawValue
        
        self.setupAttributes()
        self.updateButtonsState()
        self.updateTextField()
    }

    @IBAction
    private func resignButtonHandler() {
        self.textField.endEditing(false)
    }
    
    @IBAction
    private func disabledSwitchHandler(_ sender: UISwitch) {
        self.textField.isEnabled = !sender.isOn
    }
    
    @IBAction
    private func groupControlHandler(_ sender: UISegmentedControl) {
        self.currentGroup = Group(rawValue: sender.selectedSegmentIndex) ?? .placeholder
        self.updateButtonsState()
    }
    
    @IBAction
    private func stateControlHandler(_ sender: UISegmentedControl) {
        self.updateButtonsState()
    }
    
    @IBAction
    private func colorButtonHandler(_ sender: UIButton) {
        guard let index = self.colorButtons.firstIndex(where: { $0 === sender }) else { return }
        self.colorIndexes[self.currentGroup]?[self.currentState] = index
        
        self.updateButtonsState()
        self.updateTextField()
    }
    
    private func attributes(with group: Group, state: FloatingPlaceholderTextField.State) -> FloatingPlaceholderTextField.Attributes {
        let index = self.colorIndexes[group]?[state] ?? 0
        let color = self.colorButtons[index].backgroundColor ?? .gray
        return [
            .font: state.contains(.active) || state.contains(.filled)
                ? UIFont.systemFont(ofSize: 12) : UIFont.systemFont(ofSize: 16),
            .foregroundColor: color
        ]
    }
    
    private func updateTextField() {
        self.colorIndexes[.placeholder]?.forEach { state, _ in
            let attributes = self.attributes(with: .placeholder, state: state)
            self.textField.setPlaceholderAttributes(attributes, for: state)
        }
        self.colorIndexes[.line]?.forEach { state, _ in
            let attributes = self.attributes(with: .line, state: state)
            let color = attributes[.foregroundColor] as? UIColor ?? .gray
            self.textField.setLineColor(color, for: state)
        }
    }
    
    private func updateButtonsState() {
        let index = self.colorIndexes[self.currentGroup]?[self.currentState] ?? 0
        for (i, button) in self.colorButtons.enumerated() {
            button.alpha = index == i ? 1 : 0.4
        }
    }
    
    private func setupAttributes() {
        self.colorIndexes = [
            .placeholder: [
                .default: 0,
                .active: 1,
                .filled: 2,
                .disabled: 3,
                [.active, .filled]: 2,
                [.disabled, .filled]: 3
            ],
            .line: [
                .default: 0,
                .active: 1,
                .filled: 2,
                .disabled: 3,
                [.active, .filled]: 2,
                [.disabled, .filled]: 3
            ]
        ]
    }
}

