#!/bin/sh

#  ci_post_clone.sh
#  WellnestOneUser
#
#  Created by Nihar Jagad on 27/01/23.
#  
#!/bin/sh

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install
