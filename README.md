# Necklace - Audio Transcription App

Necklace is a cross-platform application that provides real-time audio transcription capabilities using OpenAI's Whisper model. The project consists of two main components: a Flutter frontend application and a FastAPI backend service.

## Project Structure

```
.
├── necklace/           # Flutter frontend application
│   ├── lib/           # Main Flutter source code
│   ├── web/           # Web platform specific code
│   ├── android/       # Android platform specific code
│   ├── ios/          # iOS platform specific code
│   ├── windows/      # Windows platform specific code
│   ├── linux/        # Linux platform specific code
│   └── macos/        # macOS platform specific code
│
└── transciberApi/     # FastAPI backend service
    ├── main.py       # Main API implementation
    └── .env          # Environment variables (not tracked in git)
```

## Features

- Real-time audio transcription using OpenAI's Whisper model
- Cross-platform support (Android, iOS, Web, Windows, Linux, macOS)
- Modern and responsive UI with animations
- WebSocket-based real-time communication
- Secure API key management

## Prerequisites

- Flutter SDK (^3.6.1)
- Python 3.x
- OpenAI API key
- Git

## Setup

### Backend Setup

1. Navigate to the `transciberApi` directory:
   ```bash
   cd transciberApi
   ```

2. Create a virtual environment and activate it:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install fastapi uvicorn python-dotenv openai python-multipart
   ```

4. Create a `.env` file with your OpenAI API key:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```

5. Start the backend server:
   ```bash
   python main.py
   ```

The API will be available at `http://localhost:8000`

### Frontend Setup

1. Navigate to the `necklace` directory:
   ```bash
   cd necklace
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## API Endpoints

- `GET /`: Health check endpoint
- `POST /transcribe`: Transcribe audio file endpoint

## Dependencies

### Backend Dependencies
- FastAPI
- OpenAI
- python-dotenv
- uvicorn
- python-multipart

### Frontend Dependencies
- Flutter SDK
- web_socket_channel
- http
- path_provider
- google_fonts
- flutter_animate
- animated_background
- glassmorphism
- loading_animation_widget

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for providing the Whisper model
- Flutter team for the amazing cross-platform framework
- All contributors and maintainers 