# ChatKit SDK

ChatKit contains three main public classes:

 *Note : Subclass these classes if needed not their Super classes*

* **MMXChatListViewController** – displays channel summaries
    * Delegate – ChatListControllerDelegate
    * Data source – ChatViewControllerDatasource


* **MMXChatViewController** – displays chats takes in a channel or recipients and creates a channel when a message is sent
    * Delegate – ChatViewControllerDelegate
    * Data source – ChatViewControllerDatasource

* **MMXContactsPickerController** – shows a list of users
    * Delegate – ContactsControllerDelegate
    * Data source – ContactsControllerDatasource


The view controllers can be created in code or they can be created in a storyboard. In a storyboard you will need to hook up the table view outlet for **MMXChatListViewController** and **MMXContactsPickerController**, for **MMXChatViewController** you will need to hook up the collection view outlet.
Each controller has Data source and Delegate properties, these properties are how the controllers are populated and interact. They each contain default implementations that provide the default experience without customization. 

This file contains all of the delegate and data source definitions: **MMChatKitProtocols.swift**

The delegates and data sources can be subclasses of the defaults or custom designed ones.

Here are the default delegates and datasources.

* **DefaultChatListControllerDatasource.swift**
* **DefaultChatListControllerDelegate.swift**
* **DefaultChatViewControllerDatasource.swift**
* **DefaultChatViewControllerDelegate.swift**
* **DefaultContactsPickerControllerDatasource.swift**


**All data come from these classes.**

An example of a custom designed datasource is **SubscribersDatasource.swift**.
The chat view screen contains a “details” button by default. The button takes you to 
a screen where you can view the subscribers in a chat. This "details" screen is made using the contacts picker with a custom data source.  

## Feedback

We are constantly adding features and welcome feedback. 
Please, ask questions or file requests [here](https://github.com/magnetsystems/message-samples-ios/issues).

## License

Licensed under the **[Apache License, Version 2.0] [license]** (the "License");
you may not use this software except in compliance with the License.

## Copyright

Copyright © 2014 Magnet Systems, Inc. All rights reserved.

[website]: http://www.magnet.com/
[techdoc]: https://www.magnet.com/documentation-home/
[license]: http://www.apache.org/licenses/LICENSE-2.0

