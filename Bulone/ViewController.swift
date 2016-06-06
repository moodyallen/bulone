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
    
    private lazy var viewModel = BuloneModuleModel()
    
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
        
        generateButton.title = ButtonTitle.Generating.rawValue.uppercaseString
        generateButton.enabled = false
        
        do {
            try Bulone.generateModule(viewModel)
            notifyOnSuccess()
        } catch let error as NSError {
            notifyOnError("Error generating module " + viewModel.moduleName, message: error.localizedDescription)
        }
        
    }
    
    func didTapOnChoosePathButton() {
        let path = selectPath()
        viewModel.path = path ?? ""
        choosePathButton.title = path ?? ButtonTitle.ChoosePath.rawValue.uppercaseString
    }
    
}

// MARK: Setup | Update

private extension ViewController {
    
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
        viewModel.moduleName = moduleNameTextField.stringValue
    }
    
    func updateView() {
        authorTextField.stringValue = viewModel.author
        projectNameTextField.stringValue = viewModel.projectName
        copyrightTextField.stringValue = viewModel.copyright
        moduleNameTextField.stringValue = viewModel.moduleName
    }
    
}

// MARK: Alert view

private extension ViewController {
    
    func createAlertView(title: String, infoText: String, style: NSAlertStyle) -> NSAlert {
        
        let alertView: NSAlert = NSAlert()
        alertView.messageText = title
        alertView.informativeText = infoText
        alertView.alertStyle = NSAlertStyle.CriticalAlertStyle
        
        return alertView
    }
    
    func notifyOnSuccess() {
        
        generateButton.title = ButtonTitle.Done.rawValue
        generateButton.enabled = true
        
        let alert = createAlertView(
            "Module generated",
            infoText: "Generated files located at\n" + viewModel.path + "/" + viewModel.moduleName,
            style: .InformationalAlertStyle
        )
        
        alert.addButtonWithTitle(ButtonTitle.Ok.rawValue)
        alert.addButtonWithTitle(ButtonTitle.ShowInFinder.rawValue)
        
        let res = alert.runModal()
        
        if res == NSAlertFirstButtonReturn {
            generateButton.title = ButtonTitle.Generate.rawValue.uppercaseString
            generateButton.enabled = true
            moduleNameTextField.stringValue = ""
        }
        
        if res == NSAlertSecondButtonReturn {
            let url = NSURL.fileURLWithPath(viewModel.path + "/" + viewModel.moduleName)
            NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([url])
            generateButton.title = ButtonTitle.Generate.rawValue.uppercaseString
            generateButton.enabled = true
            moduleNameTextField.stringValue = ""
        }
        
    }
    
    func notifyOnError(title: String, message: String)  {
        
        generateButton.title = ButtonTitle.Generate.rawValue.uppercaseString
        generateButton.enabled = true
        
        let alert = createAlertView(title, infoText: message, style: .CriticalAlertStyle)
        alert.addButtonWithTitle(ButtonTitle.Ok.rawValue)
        alert.runModal()
    }
    
}

// MARK: Utilities

private extension ViewController {
    
    func selectPath() -> String? {
        
        let open = NSOpenPanel()
        open.canChooseFiles = false
        open.canChooseDirectories = true
        open.canCreateDirectories = true
        open.prompt = "Select"
        
        if open.runModal() == NSModalResponseOK {
            return open.URLs.first?.path
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
            let alert = createAlertView("All fields are required", infoText: "Please fill all fields", style: .CriticalAlertStyle)
            alert.addButtonWithTitle(ButtonTitle.Ok.rawValue)
            alert.runModal()
            return false
        }
        
        if viewModel.path == "" {
            let alert = createAlertView("File path missing", infoText: "Please choose a path for files", style: .CriticalAlertStyle)
            alert.addButtonWithTitle(ButtonTitle.Ok.rawValue)
            alert.runModal()
            return false
        }
        
        return true
    }
    
}