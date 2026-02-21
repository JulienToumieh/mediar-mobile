# Mediar
A mobile-friendly, Flutter-based frontend for the Mediar ASP.NET web-application.

Mediar is a simple application for creating, managing, and viewing family photo albums.

## Features
- Material Design
- Dynamic light/dark theme, with customizable colors
- Login/Register + JWT Authentication
- Create, edit, and delete albums
- Upload media (curently images only) to album and delete them
- User permissions restrict certain users from creating, editing, or deleting
- Basic account management (create and delete accounts)

## Screenshots
<img width="246" height="506" alt="546760659-fdd2b2d6-c072-4939-b2ad-b6e322d1ead9" src="https://github.com/user-attachments/assets/e8c027ce-02e0-43e4-af99-8a776ab76748" />
<img width="246" height="506" alt="546760669-308b77a6-82a9-40f8-b92e-53c1937f4add" src="https://github.com/user-attachments/assets/79cb81fb-ffa0-4d00-b480-acff4b6fe915" />
<img width="246" height="506" alt="546760672-45890644-6223-4ada-a09b-68e64f684fbb" src="https://github.com/user-attachments/assets/284e0d50-d8ff-4857-ba7a-96267d6d18da" />
<img width="246" height="506" alt="546760682-ebc2074e-33f4-4f72-9fa7-f65369a34bfa" src="https://github.com/user-attachments/assets/b2c2ded6-8c96-4be2-bc69-9569498dc43c" />
<img width="246" height="506" alt="546760684-116467df-b412-4da0-96df-a9a0fc246db4" src="https://github.com/user-attachments/assets/80b405b9-cc58-4277-ac08-ec5ec50a1cc3" />
<img width="246" height="506" alt="546760689-5f9b1eb4-f6b2-4a55-ad0a-9b84e5b6ecb9" src="https://github.com/user-attachments/assets/b34da7b3-3f35-4237-adaa-ffc299caa6f0" />
<img width="246" height="506" alt="546760698-ded4836f-950b-4e02-81e2-0e19f5ba1d6e" src="https://github.com/user-attachments/assets/8b382552-bd35-464b-b884-aa23f51ede22" />
<img width="246" height="506" alt="546760714-c63cff27-7e07-4ba9-8c8c-782ba27a2310" src="https://github.com/user-attachments/assets/c6459b60-7c13-408e-bbac-d6162834d044" />

## Usage
- Create an *Admin* account first, using the web-application (currently unsupported on mobile)
- The login/register pages:
    - Set the Mediar server host IP & Port number
    - Typical interfaces
- The album list page:
    - The + action button opens a form to create an album (info: name, description, and cover image upload)
    - Click on an album to open it
    - Press and hold on an album to delete it
- The album page:
    - Album details section - Contains album name, description, and date created
    - Album media section:
        - Displays a staggered gallery of images in the album
        - Click on an image to open it in the viewer
        - Press and hold on an image to delete it
    - The + action button adds a new media image (upload)
    - The pen action button edits the album's information (name, description, and cover image)
- Profile page:
    - Log out
    - View and delete user accounts (*admin* only)
    - Register a new user (only *admin* accounts can create other accounts - for example, the person who set up the server at home creates accounts for their family members and assigns their permissions)
    - Change user name & password
    - Change UI color theme (orange, blue, green, purple)
    - Permission roles:
        - **View (default)**: Can only view albums & media
        - **Edit**: View, create, and edit albums & media
        - **Delete**: View, create, edit, and delete albums & media
        - **Admin**: View, create, edit, and delete albums & media + create & delete accounts with permissions


## Technical Details
### General
- Loading animations
- Pull to refresh (from top to bottom)
- Navigator.push() for pages navigation
- Custom theme file with color change support
- Follows system dark/light theme
- Connects to API, JWT token is passed with every HTTP request
- Uses Shared Preferences to store color theme, server IP, Port, and JWT token (unsafe, for now)
- Minimal and straight-forward UI with clear text fonts, colors, and intuitive accessibility

### Login/Register Pages
- Use auth_provider (provider global state)
- Feature input validation (email format & password length in the register page)
- Forms support multiple field types (text & dropdown)
- Handle and display error messages on failures (network error, invalid credentials, email already exists, etc...

### Album List Page
- Use local state for the page
- Features "album" custom widgets
- Communicate with API to fetch albums
- Refresh when the page is back in focus (for changes)
- Display message when there are no albums created yet
- Displays a popup window with a form to create a new album, featuring the system image picker
- Displays a popup window to confirm the deletion of an album

### Album Page
- Use local state for the page
- Features "media" custom widgets
- Features a masonry grid for the media gallery (images have a fixed width, but can have different heights)
- Display a message when the album does not contain media
- Displays a popup window to edit the album details, which come pre-populated (name, description, and cover image)
- Displays a popup window to add new media to the album, featuring the system image picker
- Displays a popup window to confirm the deletion of a media item

## How To Run
### Prerequisites
- This project requires the Mediar ASP.NET API Server found [here](https://github.com/JulienToumieh/mediar-web-server).
- Flutter version 3.38.7 or later

### Known Issues
- The app can run on the web, but the media picker doesn't work there
