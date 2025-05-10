TripTunes: Road Trip Playlist Builder
TripTunes is an iOS app that dynamically generates custom Spotify/Last.fm playlists based on
your travel route and music preferences. It also helps users discover attractions along the way,
combining music and exploration into one seamless road trip experience.
Table of Contents
●
●
●
●
●
●
●
●
●
Introduction
Team Members
Dependencies
Installation Guide
How to Run
Sample Input & Output
Credits & References
Troubleshooting / FAQ
Version History
Introduction
TripTunes enhances road trips by
●
●
●
●
●
Generating playlists based on user-defined start and end points
Suggesting music by city or genre using Last.fm
Displaying interactive route maps
Recommending nearby attractions via Google Places
Offering music playback options via Spotify or Last.fm
Team Members
Name Role Contact
Hazel Salazar Project Lead, UI Design salazar
_
hazel@wheatoncollege.edu
Amy Saad QA & Technical Writer saad
_
amy@wheatoncollege.edu
Jason
Mndolwa
Front-end/Back-end Developer mndolwa
_jason@wheatoncollege.ed
u
Dependencies
Environment
●
●
●
iOS 16+
Xcode 15+
Swift 5.9
Libraries/APIs
●
●
●
●
●
●
●
MapKit: Apple Maps rendering
Google Places API: Fetch nearby attractions
Spotify iOS SDK (future full support)
Last.fm API: Playlist generation and playback (web-based)
AVFoundation: Audio previews
URLSession or Alamofire: Networking
Apple Music API: Album art and backup links
API Keys Needed
Spotify Client ID
let spotifyClientID = "YOUR
CLIENT
_
_
ID"
Spotify Redirect URI
let spotifyRedirectURI = "YOUR
REDIRECT
_
_
URI"
Google Maps API Key
let googleAPIKey = "YOUR
GOOGLE
API
_
_
_
KEY"
How to Run
-
-
-
-
-
-
-
Open the app
Enter your start and end destinations
Tap Generate Playlist
View a custom route map with pins and attractions
Explore tracks by genre or location
Listen using Spotify or Last.fm
Save or delete playlists under your user account
Sample Input & Output
Input Example:
●
●
Start: Boston, MA
End: New York City, NY
Output:
●
●
A playlist including music trending in Boston, Providence, New Haven, NYC
Spotify and Last.fm links per track
Credits & References
Spotify Developer Docs
Last.fm API
●
●
●
●
Google Places API
Apple Developer Doc
Troubleshooting / FAQ
Q: Playlist doesn’t generate?
A: Ensure start/end locations are valid. Re-authenticate Spotify if needed.
Q: Map doesn’t show attractions?
A: Check the API key for Google Places and ensure billing is enabled.
Q: Spotify playback isn’t working?
A: Full playback requires Spotify Premium. Alternatively, use Last.fm links.
Q: Album art isn’t loading?
A: Apple Music artwork requires a valid iTunes API connection.
Version History
Version Date Features Completed
0.1 Mar 2025 Basic UI, location input, route mapping
0.5 Apr 2025 Playlist generation, attraction fetching, Last.fm integration
1.0 Apr 23,
2025
External playback, saved/deleted playlists, Google Places,
collapsible UI
1.1 May 2025 UI polish, Spotify login setup, Apple Music links, playlist runtime
summary
2.0 Future Plan In-app playback, user authentication, custom user profiles, offline
caching
