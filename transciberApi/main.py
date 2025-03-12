import logging
import os

import openai
from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File
import uvicorn

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise ValueError("OPENAI_API_KEY is missing. Please check your .env file.")

logging.basicConfig(level=logging.INFO)
app = FastAPI(
    title="Audio Transcription API",
    description="This API uses OpenAI's Whisper model to transcribe audio files.",
    version="1.0.0"
)

@app.get("/", summary="Health check", description="Check if the API is running.")
async def health_check():
    return {"status": "ok"}

@app.post("/transcribe", summary="Transcribe audio file", description="Transcribes an audio file using OpenAI's Whisper model.")
async def transcribe_audio(file: UploadFile = File(...)):
    audio_content = await file.read()

    temp_filename = "temp_audio.mp3"
    with open(temp_filename, "wb") as temp_file:
        temp_file.write(audio_content)

    with open(temp_filename, "rb") as audio_file:
        response = openai.Audio.transcribe("whisper-1", audio_file)

    transcription_text = response["text"]
    logging.info(f"Transcription: {transcription_text}")
    return {"transcription": transcription_text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)