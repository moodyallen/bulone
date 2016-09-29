//
//  ViewController.swift
//  Bulone
//
//  Created by Moody Allen on 01/03/16.
//  Copyright © 2016 Moody Allen. All rights reserved.
//

import Cocoa

enum ButtonTitle: String {
    case Generate = "Generate module"
    case ChoosePath = "Choose path"
    case ShowInFinder = "Show in finder"
    case Generating
    case Error
    case Ok
    case Done
}

class ViewController: NSViewController {
    
    @IBOutlet weak var moduleNameTextField: NSTextField!
    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var copyrightTextField: NSTextField!
    @IBOutlet weak var choosePathButton: NSButton!
    @IBOutlet weak var generateButton: NSButton!
    
    fileprivate lazy var viewModel = BuloneModuleModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateView()
    }
    
}

// MARK: Actions

extension ViewController {
    
    func didTapOnGenerateButton() {
        
        if !validateBeforeGenerate() { return }
        updateModel()
        
        generateButton.title = ButtonTitle.Generating.rawValue.uppercased()
        generateButton.isEnabled = false
        
        do {
            try Bulone.generate(from: viewModel)
            notifyOnSuccess()
        } catch let error as NSError {
            notifyOnError("Error generating module " + viewModel.name, message: error.localizedDescription)
        }
        
    }
    
    func didTapOnChoosePathButton() {
        let path = selectPath()
        viewModel.path = path ?? ""
        choosePathButton.title = path ?? ButtonTitle.ChoosePath.rawValue.uppercased()
    }
    
}

// MARK: Setup | Update

fileprivate extension ViewController {
    
    func setup() {
        generateButton.target = self
        generateButton.action = #selector(ViewController.didTapOnGenerateButton)
        choosePathButton.target = self
        choosePathButton.action = #selector(ViewController.didTapOnChoosePathButton)
    }

    func updateModel() {
        viewModel.author = authorTextField.stringValue
        viewModel.projectName = projectNameTextField.stringValue
        viewModel.copyright = copyrightTextField.stringValue
        viewModel.name = moduleNameTextField.stringValue
    }
    
    func updateView() {
        authorTextField.stringValue = viewModel.author
        projectNameTextField.stringValue = viewModel.projectName
        copyrightTextField.stringValue = viewModel.copyright
        moduleNameTextField.stringValue = viewModel.name
    }
    
}

// MARK: Alert view

fileprivate extension ViewController {
    
    func createAlertView(_ title: String, infoText: String, style: NSAlertStyle) -> NSAlert {
        
        let alertView: NSAlert = NSAlert()
        alertView.messageText = title
        alertView.informativeText = infoText
        alertView.alertStyle = NSAlertStyle.critical
        
        return alertView
    }
    
    func notifyOnSuccess() {
        
        generateButton.title = ButtonTitle.Done.rawValue
        generateButton.isEnabled = true
        
        let alert = createAlertView(
            "Module generated",
            infoText: "Generated files located at\n" + viewModel.path + "/" + viewModel.name,
            style: .informational
        )
        
        alert.addButton(withTitle: ButtonTitle.Ok.rawValue)
        alert.addButton(withTitle: ButtonTitle.ShowInFinder.rawValue)
        
        let res = alert.runModal()
        
        if res == NSAlertFirstButtonReturn {
            generateButton.title = ButtonTitle.Generate.rawValue.uppercased()
            generateButton.isEnabled = true
            moduleNameTextField.stringValue = ""
        }
        
        if res == NSAlertSecondButtonReturn {
            let url = URL(fileURLWithPath: viewModel.path + "/" + viewModel.name)
            NSWorkspace.shared().activateFileViewerSelecting([url])
            generateButton.title = ButtonTitle.Generate.rawValue.uppercased()
            generateButton.isEnabled = true
            moduleNameTextField.stringValue = ""
        }
        
    }
    
    func notifyOnError(_ title: String, message: String)  {
        
        generateButton.title = ButtonTitle.Generate.rawValue.uppercased()
        generateButton.isEnabled = true
        
        let alert = createAlertView(title, infoText: message, style: .critical)
        alert.addButton(withTitle: ButtonTitle.Ok.rawValue)
        alert.runModal()
    }
    
}

// MARK: Utilities

fileprivate extension ViewController {
    
    func selectPath() -> String? {
        
        let open = NSOpenPanel()
        open.canChooseFiles = false
        open.canChooseDirectories = true
        open.canCreateDirectories = true
        open.prompt = "Select"
        
        if open.runModal() == NSModalResponseOK {
            return open.urls.first?.path
        }
        
        return nil
    }
    
    func isAllFieldsFilled() -> Bool {
        
        let moduleName = moduleNameTextField.stringValue
        let projectName = projectNameTextField.stringValue
        let author = authorTextField.stringValue
        let copyright = copyrightTextField.stringValue
        
        return [moduleName, projectName, author, copyright]
            .filter({ $0 == "" })
            .count > 0
    }
    
    func validateBeforeGenerate() -> Bool {
        
        if isAllFieldsFilled() {
            let alert = createAlertView("All fields are required", infoText: "Please fill all fields", style: .critical)
            alert.addButton(withTitle: ButtonTitle.Ok.rawValue)
            alert.runModal()
            return false
        }
        
        if viewModel.path == "" {
            let alert = createAlertView("File path missing", infoText: "Please choose a path for files", style: .critical)
            alert.addButton(withTitle: ButtonTitle.Ok.rawValue)
            alert.runModal()
            return false
        }
        
        return true
    }
    
}
