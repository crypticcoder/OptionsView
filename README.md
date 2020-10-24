# OptionsView

OptionsView is a minimal solution to provide a drop down like functionality in iOS. It comes in neutral hues to fit into any app's color theme
and satisfies most use cases without having to touch the source. 
But you can always customize it in the source.

# Features

1. Works on iOS 9.0+
2. Swift 3.0 compatible
3. Orientation support

# Installation

Just download the source and add it to your project.

# Usage

    @IBAction func showPopover(sender: AnyObject) {
        
        let placesToVisit = ["Paris", "Rome", "Venice", "Bali", "Denver"]
        
        let optionsView = OptionsView(options: placesToVisit, selectedIndex: 2, dismissWithoutSelection: true)
        
        optionsView.showInView(view) { selectedIndex in
            print("SelectedIndex: \(selectedIndex)")
        }
        
    }

# Results

![screenshot1](https://sayeedhussain.github.io/optionsview-screenshot1.png)
![screenshot2](https://sayeedhussain.github.io/optionsview-screenshot2.png)

