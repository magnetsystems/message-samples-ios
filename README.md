<img style="margin:10px" src="https://www.magnet.com/wp-content/uploads/2015/05/sampleapps.png"
 alt="rest2mobile logo" title="MMXiOSSamples"/ width="200" align="right">

# Magnet Message iOS Sample Apps

[Magnet Message](https://www.magnet.com/developer/magnet-message/) is a powerful, open source mobile messaging framework enabling real-time user engagement for your mobile apps. Send relevant and targeted communications to customers or employees. These sample iOS apps serve as introductory sample code - get familiar with our API, extend our samples and get coding today.

## Rock Paper Scissors Lizard Spock
<img style="margin:10px" src="https://www.magnet.com/wp-content/uploads/2015/04/spock.png"
 alt="RPSLS logo" width="200"  align="right" title="RPSLS"/>

We created a Rock Paper Scissors Lizard Spock game as popularized by the show “Big Bang Theory”. If you aren’t already a fan, check out the [rules](http://www.samkass.com/theories/RPSSL.html). Install, build, run, play, repeat. Oh, and learn more about how Magnet Message handles core message passing and the publish/subscribe dynamic.

### Build Instructions

You must replace the existing Configurations.plist file in the project with your own. You can download this file on the Settings page of the Magnet Message Web Interface. After adding the file to the project just build and run!

### How it works (Technical Highlights)

RPSLS leverages the topic features of Magnet Message to keep an updated list of "available" real opponents. When the user starts the app, the code publishes to a pre-defined availability topic to say "Hey, I want to play." Upon closing the app, the code publishes to this same topic and says "I'm leaving".

When the user wants to discover opponents, the app requests the most recent posts to the availbility topic to find which users have published their availability and presents this to the user. The user can then choose which available players to invite to play and upon accepting the invitation, they both make a choice. RPSLS determines the outcome and notifies each user whether they are the VAPORIZER or the VAPORIZEE. The invitations, acceptance, and other interactive portions of the game are performed using the in-app messaging functionality of Magnet Message.

All of this functionality is accomplished through the metadata of each message payload, in which the app specifies various message types and fields which pertain to each type. This can also be accomplished by using the actual message payload and JSON marshalled objects. The payload can be ANYTHING or any protocol you desire.

Game on!


<hr>
## Soapbox
<img style="margin:10px" src="http://www.threetwelvecreative.com/Portals/207686/images/Stick-Figures-With-Megaphone-800.jpg"
 alt="soapbox logo" width="250" align="right"  title="soapbox"/>

We needed an app to address one of the the most important issues in our office – what’s for lunch? Following that, after our office was hit by a network outage in the morning that blasted productivity for unsuspecting early commuters we came up with the notion of a corporate announcements app. Something we could check to take some of the… surprises out of work. After polishing up the code, we realized it makes a pretty effective piece of sample code highlighting our Publish/Subscribe capabilities. Pull it down, customize and get everyone on the same page.

### Build Instructions

You must replace the existing Configurations.plist file in the project with your own. You can download this file on the Settings page of the Magnet Message Web Interface. After adding the file to the project just build and run!

### How it works (Technical Highlights)

SoapBox leverages the Magnet Message topic functionality to provide a channel for employees/friends to communicate effectively by publishing/subscribing/receiving simple text messages against a pre-configured set of topics or topics they choose to create.

Feature highlights: -- quick account provisioning -- retrieve all topics using topic search -- retrieve topics subscribed by the user -- retrieve topic summaries (used to show the number of postings in a certain timeframe which is, in the case of SoapBox, the last 24 hours) -- retrieve the last 25 items for a topic -- create topics -- subscribe and unsubscribe from topics -- adding tags for topics (tags can be used as search criteria)


<hr>
## Quickstart

Quickstart was created to have a simple app that could demonstrate the most basic messaging features including logging in and sending and receiving a message.

### Build Instructions

You must replace the existing Configurations.plist file in the project with your own. You can download this file on the Settings page of the Magnet Message Web Interface. After adding the file to the project just build and run!

### How it works (Technical Highlights)

Quickstart auto-creates a user and allows you to send a message to yourself by default. By sending a message to yourself you can easily see the roundtrip from device to server and back.

Feature highlights: -- quick account provisioning -- addressing and sending a message -- receiving a message and accessing its content.

## Rich messaging
RichMessaging iOS chat app to demonstrate how rich content such as images, videos, and geographical location can be delivered and received using Magnet Message. Images and videos are uploaded to Amazon S3, and the URL to the file is delivered to the recipient. This app also demonstrates Facebook integration with Magnet Message.

### Feature highlights
* Login with Facebook 
* Obtain a list of users to chat with
* One to one chat with a user
* Send and receive text, pictures, videos, or a map pointing out your current location
* Upload images and video (via Amazon S3) to be viewed by your recipient
* Obtain your current geographical location, and send the coordinates to your receipient to be viewed as a map

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

